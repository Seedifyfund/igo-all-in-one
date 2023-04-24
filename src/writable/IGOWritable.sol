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
        // TODO: consumes same or more gas than using allocation.amount directly?
        uint256 amount = allocation.amount;
        IGOStorage.IGOStruct storage strg = IGOStorage.layout();

        State state = strg.tags[tagId].state;
        if (state != State.OPENED) {
            revert IGOWritable_NotOpened(tagId, state);
        }

        // TODO: verify allocation.account == msg.sender

        require(
            MerkleProof.verify(
                proof,
                strg.tags[tagId].merkleRoot,
                keccak256(abi.encode(allocation))
            ),
            "ALLOCATION_NOT_FOUND"
        );

        // verify maxTagCap will not be exceeded, after this purchase
        uint256 maxTagCap = strg.tags[tagId].maxTagCap;
        uint256 raisedAfterPurchase = amount + strg.raisedInTag[tagId];
        if (raisedAfterPurchase > maxTagCap) {
            revert IGOWritable_MaxTagCapExceeded(
                tagId,
                maxTagCap,
                raisedAfterPurchase - maxTagCap
            );
        }

        uint256 grandTotal = strg.grandTotal;
        uint256 totalAfterPurchase = amount + strg.totalRaised;
        if (totalAfterPurchase > grandTotal) {
            revert IGOWritable_GrandTotalExceeded(
                grandTotal,
                totalAfterPurchase - grandTotal
            );
        }

        // update storage
        strg.totalRaised += amount;
        strg.raisedInTag[tagId] += amount;

        // transfer tokens
        IERC20(strg.token).safeTransferFrom(
            msg.sender,
            strg.treasuryWallet,
            amount
        );
    }

    function setTags(
        string[] calldata tagIdentifiers_,
        Tag[] calldata tags_
    ) external override onlyOwner {
        IGOStorage.IGOStruct storage strg = IGOStorage.layout();

        require(
            tagIdentifiers_.length == tags_.length,
            "IGOWritable: tags arrays length"
        );

        uint256 length = tagIdentifiers_.length;
        uint256 grandTotal = strg.grandTotal;

        for (uint256 i; i < length; ++i) {
            _isMaxTagAllocationGtGrandTotal(
                tagIdentifiers_[i],
                tags_[i].maxTagCap,
                grandTotal
            );
            strg.tagIdentifiers.push(tagIdentifiers_[i]);
            strg.tags[tagIdentifiers_[i]] = tags_[i];
        }
    }

    function updateGrandTotal(uint256 grandTotal_) external onlyOwner {
        require(grandTotal_ >= 1_000, "IGOWritable: grandTotal < 1_000");
        IGOStorage.layout().grandTotal = grandTotal_;
    }

    function updateToken(address token_) external onlyOwner {
        IGOStorage.layout().token = token_;
    }

    function updateTreasuryWallet(address addr) external onlyOwner {
        IGOStorage.layout().treasuryWallet = addr;
    }

    function updateWholeTag(
        string calldata tagId_,
        Tag calldata tag_
    ) external onlyOwner {
        IGOStorage.IGOStruct storage strg = IGOStorage.layout();

        _isMaxTagAllocationGtGrandTotal(
            tagId_,
            tag_.maxTagCap,
            strg.grandTotal
        );

        strg.tags[tagId_] = tag_;
    }

    function recoverLostERC20(address token, address to) external onlyOwner {
        uint256 amount = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(to, amount);
    }
}
