// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {ISignatureTransfer} from "permit2/interfaces/ISignatureTransfer.sol";

import {MerkleProof} from "openzeppelin-contracts/utils/cryptography/MerkleProof.sol";
import {SafeERC20} from "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";

import {ISharedInternal} from "../shared/ISharedInternal.sol";
import {IIGOWritableInternal} from "./IIGOWritableInternal.sol";

import {IGOStorage} from "../IGOStorage.sol";

/**
 * @notice Inherits from `ISharedInternal` will create `error[5005]: Linearization of inheritance graph impossible`
 */
contract IGOWritableInternal is IIGOWritableInternal {
    using SafeERC20 for IERC20;

    function _buyTokensOnce(
        IGOStorage.SetUp memory setUp,
        address paymentToken,
        uint256 amount,
        BuyPermission calldata permission
    ) internal {
        ISignatureTransfer permit2 = ISignatureTransfer(setUp.permit2);

        ISignatureTransfer.TokenPermissions memory permitted;
        ISignatureTransfer.PermitTransferFrom memory permit;
        ISignatureTransfer.SignatureTransferDetails memory transferDetails;

        permitted = ISignatureTransfer.TokenPermissions({
            token: paymentToken,
            amount: amount
        });
        permit = ISignatureTransfer.PermitTransferFrom({
            permitted: permitted,
            nonce: permission.nonce,
            deadline: permission.deadline
        });
        transferDetails = ISignatureTransfer.SignatureTransferDetails({
            to: setUp.treasuryWallet,
            requestedAmount: amount
        });

        permit2.permitTransferFrom(
            permit,
            transferDetails,
            msg.sender,
            permission.signature
        );
    }

    function _closeIGO() internal {
        IGOStorage.layout().ledger.stage = ISharedInternal.Stage.COMPLETED;
    }

    function _closeTag(string memory tagId) internal {
        IGOStorage.layout().tags.data[tagId].stage = ISharedInternal
            .Stage
            .COMPLETED;
    }

    function _updateStorageOnBuy(
        uint256 amount,
        string calldata tagId,
        address buyer,
        uint256 grandTotal,
        uint256 maxTagCap
    ) internal {
        IGOStorage.Ledger storage ledger = IGOStorage.layout().ledger;

        // update raised amount
        ledger.totalRaised += amount;
        ledger.raisedInTag[tagId] += amount;
        ledger.boughtByIn[buyer][tagId] += amount;
        // close if limit reached
        if (ledger.totalRaised == grandTotal) _closeIGO();
        if (ledger.raisedInTag[tagId] == maxTagCap) _closeTag(tagId);
    }

    /**
     * @dev Ensure a wallet can not more than their allocation for the
     *      given tag.
     */
    function _requireAllocationNotExceededInTag(
        uint256 toBuy,
        address rewardee,
        uint256 allocated,
        string calldata tagId
    ) internal view {
        uint256 totalAfterPurchase = toBuy +
            IGOStorage.layout().ledger.boughtByIn[rewardee][tagId];
        if (totalAfterPurchase > allocated) {
            revert IGOWritable_AllocationExceeded(
                allocated,
                totalAfterPurchase - allocated
            );
        }
    }

    /// @dev Only the `msg.sender` can buy tokens for themselves
    function _requireAuthorizedAccount(address account) internal view {
        require(account == msg.sender, "msg.sender: NOT_AUTHORIZED");
    }

    /// @dev verify `grandTotal` will not be exceeded, after purchase
    function _requireGrandTotalNotExceeded(
        uint256 toBuy,
        uint256 grandTotal
    ) internal view {
        uint256 totalAfterPurchase = toBuy +
            IGOStorage.layout().ledger.totalRaised;
        if (totalAfterPurchase > grandTotal) {
            revert IGOWritable_GrandTotalExceeded(
                grandTotal,
                totalAfterPurchase - grandTotal
            );
        }
    }

    function _requireOpenedIGO() internal view {
        ISharedInternal.Stage current = IGOStorage.layout().ledger.stage;
        if (current != ISharedInternal.Stage.OPENED) {
            revert IGOWritableInternal_IGONotOpened(current);
        }
    }

    function _requireOpenedTag(string memory tagId) internal view {
        ISharedInternal.Stage current = IGOStorage
            .layout()
            .tags
            .data[tagId]
            .stage;
        if (current != ISharedInternal.Stage.OPENED) {
            revert IGOWritableInternal_TagNotOpened(tagId, current);
        }
    }

    /// @dev verify `maxTagCap` will not be exceeded, after purchase
    function _requireTagCapNotExceeded(
        string calldata tagId,
        uint256 maxTagCap,
        uint256 toBuy
    ) internal view {
        uint256 raisedAfterPurchase = toBuy +
            IGOStorage.layout().ledger.raisedInTag[tagId];
        if (raisedAfterPurchase > maxTagCap) {
            revert IGOWritable_MaxTagCapExceeded(
                tagId,
                maxTagCap,
                raisedAfterPurchase - maxTagCap
            );
        }
    }

    function _requireValidAllocation(
        Allocation calldata allocation,
        bytes32[] calldata proof
    ) internal view {
        require(
            MerkleProof.verify(
                proof,
                IGOStorage.layout().tags.data[allocation.tagId].merkleRoot,
                keccak256(abi.encode(allocation))
            ),
            "ALLOCATION_NOT_FOUND"
        );
    }
}
