// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

import {IGOStorage} from "../IGOStorage.sol";

import {IIGOWritable} from "./IIGOWritable.sol";
import {IIGOWritableInternal} from "./IIGOWritableInternal.sol";

contract IGOWritable is IIGOWritable, IIGOWritableInternal, Ownable {
    function setTags(
        string[] calldata tagIdentifiers_,
        Tag[] calldata tags_
    ) external override onlyOwner {
        IGOStorage.IGOStruct storage strg = IGOStorage.layout();

        require(
            tagIdentifiers_.length == tags_.length,
            "IGOWritable: tags arrays length"
        );

        uint256 length = tagIdentifiers_.length;

        for (uint256 i; i < length; ++i) {
            strg.tagIdentifiers.push(tagIdentifiers_[i]);
            strg.tags[tagIdentifiers_[i]] = tags_[i];
        }
    }

    function updateGrandTotal(uint256 grandTotal_) external onlyOwner {
        require(grandTotal_ >= 1_000, "IGOWritable: grandTotal < 1_000");
        IGOStorage.layout().grandTotal = grandTotal_;
    }
}
