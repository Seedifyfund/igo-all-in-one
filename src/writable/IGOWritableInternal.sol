// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {MerkleProof} from "openzeppelin-contracts/utils/cryptography/MerkleProof.sol";

import {IIGOWritableInternal} from "./IIGOWritableInternal.sol";

import {IGOStorage} from "../IGOStorage.sol";

contract IGOWritableInternal is IIGOWritableInternal {
    function _nextStageForTag(string memory tagId) internal {
        IGOStorage.layout().tags.data[tagId].stage = Stage(
            uint256(IGOStorage.layout().tags.data[tagId].stage) + 1
        );
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
        Stage current = IGOStorage.layout().ledger.stage;
        if (current != Stage.OPENED) {
            revert IGOWritableInternal_IGONotOpened(current);
        }
    }

    function _requireOpenedTag(string memory tagId) internal view {
        Stage current = IGOStorage.layout().tags.data[tagId].stage;
        if (current != Stage.OPENED) {
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

    function _isMaxTagAllocationGtGrandTotal(
        string calldata tagId_,
        uint256 maxTagAllocation_,
        uint256 grandTotal_
    ) internal pure returns (bool) {
        if (maxTagAllocation_ > grandTotal_) {
            revert IGOWritable_GreaterThanGrandTotal(
                tagId_,
                maxTagAllocation_,
                grandTotal_
            );
        }
        return false;
    }
}
