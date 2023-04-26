// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IIGOWritableInternal} from "./IIGOWritableInternal.sol";

interface IIGOWritable {
    function buyTokens(
        uint256 amount,
        IIGOWritableInternal.Allocation calldata allocation,
        bytes32[] calldata proof
    ) external;
}
