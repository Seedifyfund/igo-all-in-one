// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

import {SafeERC20} from "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";

import {IIGOWritable} from "./IIGOWritable.sol";

import {IGOStorage} from "../IGOStorage.sol";

import {RestrictedWritable} from "./restricted/RestrictedWritable.sol";
import {IGOWritableInternal} from "./IGOWritableInternal.sol";

contract IGOWritable is IIGOWritable, IGOWritableInternal, RestrictedWritable {
    using SafeERC20 for IERC20;

    function buyTokens(
        uint256 amount,
        Allocation calldata allocation,
        bytes32[] calldata proof
    ) external override {
        // `Allocation` struct data in local variables (save gas)
        string calldata tagId = allocation.tagId;
        // local variables (save gas)
        uint256 maxTagCap = IGOStorage.layout().tags.data[tagId].maxTagCap;
        uint256 grandTotal = IGOStorage.layout().setUp.grandTotal;
        // check given parameters
        _requireAllocationNotExceeded(amount, allocation);
        _requireAuthorizedAccount(allocation.account);
        _requireGrandTotalNotExceeded(amount, grandTotal);
        _requireOpenedIGO();
        _requireOpenedTag(allocation.tagId);
        _requireTagCapNotExceeded(tagId, maxTagCap, amount);
        _requireValidAllocation(allocation, proof);

        // read storage
        IGOStorage.SetUp memory setUp = IGOStorage.layout().setUp;
        IGOStorage.Ledger storage ledger = IGOStorage.layout().ledger;

        // update storage
        ledger.totalRaised += amount;
        ledger.raisedInTag[tagId] += amount;
        ledger.boughtBy[allocation.account] += amount;
        if (ledger.totalRaised == grandTotal) _closeIGO();
        if (ledger.raisedInTag[tagId] == maxTagCap) _closeTag(tagId);

        // transfer tokens
        IERC20(setUp.token).safeTransferFrom(
            msg.sender,
            setUp.treasuryWallet,
            amount
        );
    }
}
