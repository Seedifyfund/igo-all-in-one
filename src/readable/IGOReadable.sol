// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IIGOReadable} from "../readable/IIGOReadable.sol";
import {IIGOWritableInternal} from "../writable/IIGOWritableInternal.sol";

import {IGOStorage} from "../IGOStorage.sol";

contract IGOReadable is IIGOReadable, IIGOWritableInternal {
    function grandTotal() external view override returns (uint256) {
        return IGOStorage.layout().setUp.grandTotal;
    }

    function raisedInTag(
        string memory tagId
    ) external view override returns (uint256) {
        return IGOStorage.layout().ledger.raisedInTag[tagId];
    }

    function tagIdentifiers()
        external
        view
        override
        returns (string[] memory tagIds)
    {
        tagIds = IGOStorage.layout().tags.ids;
    }

    function tag(
        string memory tagId
    ) external view override returns (Tag memory tag_) {
        tag_ = IGOStorage.layout().tags.data[tagId];
    }

    function token() external view override returns (address) {
        return IGOStorage.layout().setUp.token;
    }

    function treasuryWallet() external view returns (address) {
        return IGOStorage.layout().setUp.treasuryWallet;
    }
}
