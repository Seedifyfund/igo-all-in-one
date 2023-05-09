// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOStorage} from "./IGOStorage.sol";

import {IGOReadable} from "./readable/IGOReadable.sol";
import {IGOWritable} from "./writable/IGOWritable.sol";

/// @author https://github.com/Theo6890
contract IGO is IGOReadable, IGOWritable {
    constructor(
        address token,
        address treasuryWallet,
        uint256 grandTotal_,
        string[] memory tagIds,
        Tag[] memory tags
    ) {
        IGOStorage.SetUp storage setUp = IGOStorage.layout().setUp;
        setUp.token = token;
        setUp.treasuryWallet = treasuryWallet;
        setUp.grandTotal = grandTotal_;
        setTags(tagIds, tags);
    }
}
