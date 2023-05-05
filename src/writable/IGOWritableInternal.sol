// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {MerkleProof} from "openzeppelin-contracts/utils/cryptography/MerkleProof.sol";

import {IStageInternal} from "./shared/IStageInternal.sol";
import {IIGOWritableInternal} from "./IIGOWritableInternal.sol";

import {IGOStorage} from "../IGOStorage.sol";

/**
 * @notice Inherits from `IStageInternal` will create `error[5005]: Linearization of inheritance graph impossible`
 */
contract IGOWritableInternal is IIGOWritableInternal {
    function _closeIGO() internal {
        IGOStorage.layout().ledger.stage = IStageInternal.Stage.COMPLETED;
    }

    function _closeTag(string memory tagId) internal {
        IGOStorage.layout().tags.data[tagId].stage = IStageInternal
            .Stage
            .COMPLETED;
    }

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
        IStageInternal.Stage current = IGOStorage.layout().ledger.stage;
        if (current != IStageInternal.Stage.OPENED) {
            revert IGOWritableInternal_IGONotOpened(current);
        }
    }

    function _requireOpenedTag(string memory tagId) internal view {
        IStageInternal.Stage current = IGOStorage
            .layout()
            .tags
            .data[tagId]
            .stage;
        if (current != IStageInternal.Stage.OPENED) {
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
