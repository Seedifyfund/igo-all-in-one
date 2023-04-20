// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOStorage} from "./IGOStorage.sol";

import {IGOReadable} from "./readable/IGOReadable.sol";
import {IGOWritable} from "./writable/IGOWritable.sol";

contract IGO is IGOReadable, IGOWritable {
    constructor(address token, uint256 grandTotal_) {
        IGOStorage.IGOStruct storage strg = IGOStorage.layout();
        strg.token = token;
        strg.grandTotal = grandTotal_;
    }
}
