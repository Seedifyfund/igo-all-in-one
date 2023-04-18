// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IIGOWritableInternal} from "../writable/IIGOWritableInternal.sol";
import {IGOStorage} from "../IGOStorage.sol";

contract IGOReadable is IIGOWritableInternal {
    function tagIdentifiers() external view returns (string[] memory tagIds) {
        tagIds = IGOStorage.layout().tagIdentifiers;
    }

    function tag(string memory tagId) external view returns (Tag memory tag) {
        tag = IGOStorage.layout().tags[tagId];
    }
}
