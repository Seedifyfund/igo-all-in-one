// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IIGOWritableInternal} from "./IIGOWritableInternal.sol";

interface IIGOWritable {
    function updateToken(address token_) external;

    function setTags(
        string[] calldata tagIdentifiers_,
        IIGOWritableInternal.Tag[] calldata tags_
    ) external;
}
