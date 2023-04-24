// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IIGOWritableInternal} from "./IIGOWritableInternal.sol";

import {IGOStorage} from "../IGOStorage.sol";

contract IGOWritableInternal is IIGOWritableInternal {
    modifier onlyStage(Stage stage, string memory tagId) {
        Stage expected = IGOStorage.layout().tags.data[tagId].stage;
        if (expected != stage) {
            revert IGOWritableInternal_InvalidStage(tagId, stage, expected);
        }
        _;
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
