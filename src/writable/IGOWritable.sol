// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Initializable} from "openzeppelin-contracts/proxy/utils/Initializable.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/security/ReentrancyGuard.sol";

import {IIGOWritable} from "./IIGOWritable.sol";
import {ISharedInternal} from "../shared/ISharedInternal.sol";

import {IGOStorage} from "../IGOStorage.sol";

import {RestrictedWritable} from "./restricted/RestrictedWritable.sol";
import {IGOWritableInternal} from "./IGOWritableInternal.sol";

contract IGOWritable is
    Initializable,
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

        address paymentToken = tag.paymentToken;
        paymentToken = paymentToken != address(0)
            ? paymentToken
            : setUp.paymentToken;

        _buyTokensOnce(setUp, paymentToken, amount, permission);
    }

    function initialize(
        address owner,
        address token,
        address permit2,
        address treasuryWallet,
        uint256 grandTotal_,
        string[] memory tagIds_,
        ISharedInternal.Tag[] memory tags
    ) external override initializer onlyOwner {
        require(owner != address(0), "IGOWritable__owner_ZERO_ADDRESS");
        require(token != address(0), "IGOWritable__token_ZERO_ADDRESS");
        require(permit2 != address(0), "IGOWritable__permit2_ZERO_ADDRESS");
        require(
            treasuryWallet != address(0),
            "IGOWritable__treasuryWallet_ZERO_ADDRESS"
        );
        require(grandTotal_ > 0, "IGOWritable__grandTotal_ZERO");

        _transferOwnership(owner);

        IGOStorage.SetUp storage setUp_ = IGOStorage.layout().setUp;
        setUp_.paymentToken = token;
        setUp_.permit2 = permit2;
        setUp_.treasuryWallet = treasuryWallet;
        setUp_.grandTotal = grandTotal_;

        _setTags(tagIds_, tags);
    }
}
