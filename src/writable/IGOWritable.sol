// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

import {MerkleProof} from "openzeppelin-contracts/utils/cryptography/MerkleProof.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {SafeERC20} from "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";

import {IIGOWritable} from "./IIGOWritable.sol";

import {IGOStorage} from "../IGOStorage.sol";

import {IGOWritableInternal} from "./IGOWritableInternal.sol";

contract IGOWritable is IIGOWritable, IGOWritableInternal, Ownable {
    using SafeERC20 for IERC20;

    function buyTokens(
        Allocation calldata allocation,
        bytes32[] calldata proof
    ) external {
        string calldata tagId = allocation.tagId;
        uint256 amount = allocation.amount;
        IGOStorage.SetUp memory setUp = IGOStorage.layout().setUp;
        IGOStorage.Tags storage tags = IGOStorage.layout().tags;
        IGOStorage.Ledger storage ledger = IGOStorage.layout().ledger;

        State state = tags.data[tagId].state;
        if (state != State.OPENED) {
            revert IGOWritable_NotOpened(tagId, state);
        }

        require(
            msg.sender == allocation.account,
            "msg.sender: NOT_AUTHORIZED"
        );

        require(
            MerkleProof.verify(
                proof,
                tags.data[tagId].merkleRoot,
                keccak256(abi.encode(allocation))
            ),
            "ALLOCATION_NOT_FOUND"
        );

        // verify maxTagCap will not be exceeded, after this purchase
        uint256 maxTagCap = tags.data[tagId].maxTagCap;
        uint256 raisedAfterPurchase = amount + ledger.raisedInTag[tagId];
        if (raisedAfterPurchase > maxTagCap) {
            revert IGOWritable_MaxTagCapExceeded(
                tagId,
                maxTagCap,
                raisedAfterPurchase - maxTagCap
            );
        }

        uint256 grandTotal = setUp.grandTotal;
        uint256 totalAfterPurchase = amount + ledger.totalRaised;
        if (totalAfterPurchase > grandTotal) {
            revert IGOWritable_GrandTotalExceeded(
                grandTotal,
                totalAfterPurchase - grandTotal
            );
        }

        // update storage
        ledger.totalRaised += amount;
        ledger.raisedInTag[tagId] += amount;

        // transfer tokens
        IERC20(setUp.token).safeTransferFrom(
            msg.sender,
            setUp.treasuryWallet,
            amount
        );
    }

    function setTags(
        string[] calldata tagIdentifiers_,
        Tag[] calldata tags_
    ) external override onlyOwner {
        IGOStorage.Tags storage tags = IGOStorage.layout().tags;

        require(
            tagIdentifiers_.length == tags_.length,
            "IGOWritable: tags arrays length"
        );

        uint256 length = tagIdentifiers_.length;
        uint256 grandTotal = IGOStorage.layout().setUp.grandTotal;

        for (uint256 i; i < length; ++i) {
            _isMaxTagAllocationGtGrandTotal(
                tagIdentifiers_[i],
                tags_[i].maxTagCap,
                grandTotal
            );
            tags.ids.push(tagIdentifiers_[i]);
            tags.data[tagIdentifiers_[i]] = tags_[i];
        }
    }

    function updateGrandTotal(uint256 grandTotal_) external onlyOwner {
        require(grandTotal_ >= 1_000, "IGOWritable: grandTotal < 1_000");
        IGOStorage.layout().setUp.grandTotal = grandTotal_;
    }

    function updateToken(address token_) external onlyOwner {
        IGOStorage.layout().setUp.token = token_;
    }

    function updateTreasuryWallet(address addr) external onlyOwner {
        IGOStorage.layout().setUp.treasuryWallet = addr;
    }

    function updateWholeTag(
        string calldata tagId_,
        Tag calldata tag_
    ) external onlyOwner {
        IGOStorage.Tags storage tags = IGOStorage.layout().tags;

        _isMaxTagAllocationGtGrandTotal(
            tagId_,
            tag_.maxTagCap,
            IGOStorage.layout().setUp.grandTotal
        );

        tags.data[tagId_] = tag_;
    }

    function recoverLostERC20(address token, address to) external onlyOwner {
        uint256 amount = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(to, amount);
    }
}
