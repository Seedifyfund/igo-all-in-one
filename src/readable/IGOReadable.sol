// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IIGOReadable} from "../readable/IIGOReadable.sol";
import {IIGOWritableInternal} from "../writable/IIGOWritableInternal.sol";

import {IGOStorage} from "../IGOStorage.sol";

contract IGOReadable is IIGOReadable, IIGOWritableInternal {
    function tagIdentifiers()
        external
        view
        override
        returns (string[] memory tagIds)
    {
        tagIds = IGOStorage.layout().tagIdentifiers;
    }

    function tag(
        string memory tagId
    ) external view override returns (Tag memory tag) {
        tag = IGOStorage.layout().tags[tagId];
    }
}
