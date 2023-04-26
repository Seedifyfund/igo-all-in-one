// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IIGOReadable} from "../readable/IIGOReadable.sol";
import {IRestrictedWritableInternal} from "../writable/restricted/IRestrictedWritableInternal.sol";
import {IStageInternal} from "../writable/shared/IStageInternal.sol";
import {IIGOWritableInternal} from "../writable/IIGOWritableInternal.sol";

import {IGOStorage} from "../IGOStorage.sol";

contract IGOReadable is
    IIGOReadable,
    IIGOWritableInternal,
    IRestrictedWritableInternal,
    IStageInternal
{
    function claimedBy(address account) external view returns (uint256) {
        return IGOStorage.layout().ledger.claimedBy[account];
    }

    function igoStage() external view override returns (Stage) {
        return IGOStorage.layout().ledger.stage;
    }

    function raisedInTag(
        string memory tagId
    ) external view override returns (uint256) {
        return IGOStorage.layout().ledger.raisedInTag[tagId];
    }

    function setUp()
        external
        view
        returns (address token, address treasuryWallet, uint256 grandTotal)
    {
        IGOStorage.SetUp memory setUp_ = IGOStorage.layout().setUp;
        token = setUp_.token;
        treasuryWallet = setUp_.treasuryWallet;
        grandTotal = setUp_.grandTotal;
    }

    function tag(
        string memory tagId
    ) external view override returns (Tag memory tag_) {
        tag_ = IGOStorage.layout().tags.data[tagId];
    }

    function tagIds()
        external
        view
        override
        returns (string[] memory tagIds_)
    {
        tagIds_ = IGOStorage.layout().tags.ids;
    }

    function totalRaised() external view returns (uint256) {
        return IGOStorage.layout().ledger.totalRaised;
    }
}
