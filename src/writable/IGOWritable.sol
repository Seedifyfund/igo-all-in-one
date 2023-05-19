// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ReentrancyGuard} from "openzeppelin-contracts/security/ReentrancyGuard.sol";

import {IIGOWritable} from "./IIGOWritable.sol";
import {ISharedInternal} from "../shared/ISharedInternal.sol";

import {IGOStorage} from "../IGOStorage.sol";

import {RestrictedWritable} from "./restricted/RestrictedWritable.sol";
import {IGOWritableInternal} from "./IGOWritableInternal.sol";

contract IGOWritable is
    IIGOWritable,
    IGOWritableInternal,
    RestrictedWritable,
    ReentrancyGuard
{
    /// @inheritdoc IIGOWritable
    function buyTokens(
        uint256 amount,
        Allocation calldata allocation,
        bytes32[] calldata proof,
        BuyPermission calldata permission
    ) external override nonReentrant {
        // `Allocation` struct data in local variables (save gas)
        string calldata tagId = allocation.tagId;
        // local variables (save gas)
        ISharedInternal.Tag memory tag = IGOStorage.layout().tags.data[tagId];
        IGOStorage.SetUp memory setUp = IGOStorage.layout().setUp;
        uint256 maxTagCap = tag.maxTagCap;
        uint256 grandTotal = setUp.grandTotal;
        // check given parameters
        _requireAllocationNotExceededInTag(
            amount,
            allocation.account,
            allocation.amount,
            tagId
        );
        _requireAuthorizedAccount(allocation.account);
        _requireGrandTotalNotExceeded(amount, grandTotal);
        _requireOpenedIGO();
        _requireOpenedTag(allocation.tagId);
        _requireTagCapNotExceeded(tagId, maxTagCap, amount);
        _requireValidAllocation(allocation, proof);

        _updateStorageOnBuy(
            amount,
            tagId,
            allocation.account,
            grandTotal,
            maxTagCap
        );

        address tokenPayment = tag.tokenPayment;
        tokenPayment = tokenPayment != address(0) ? tokenPayment : setUp.token;

        _buyTokensOnce(setUp, tokenPayment, amount, permission);
    }
}
