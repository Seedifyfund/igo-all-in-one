// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOStorage} from "./IGOStorage.sol";

import {IGOReadable} from "./readable/IGOReadable.sol";
import {IGOWritable} from "./writable/IGOWritable.sol";

/// @author https://github.com/Theo6890
contract IGO is IGOReadable, IGOWritable {
    constructor(
        address owner,
        address token,
        address permit2,
        address treasuryWallet,
        uint256 grandTotal_,
        string[] memory tagIds_,
        Tag[] memory tags
    ) {
        _transferOwnership(owner);

        IGOStorage.SetUp storage setUp_ = IGOStorage.layout().setUp;
        setUp_.paymentToken = token;
        setUp_.permit2 = permit2;
        setUp_.treasuryWallet = treasuryWallet;
        setUp_.grandTotal = grandTotal_;

        _setTags(tagIds_, tags);
    }
}
