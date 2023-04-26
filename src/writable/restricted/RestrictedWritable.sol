// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

import {SafeERC20} from "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";

import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

import {IRestrictedWritable} from "./IRestrictedWritable.sol";
import {IIGOWritableInternal} from "../IIGOWritableInternal.sol";

import {RestrictedWritableInternal} from "./RestrictedWritableInternal.sol";

import {IGOStorage} from "../../IGOStorage.sol";

contract RestrictedWritable is
    IRestrictedWritable,
    RestrictedWritableInternal,
    Ownable
{
    using SafeERC20 for IERC20;

    function openIGO() external override onlyOwner {
        IGOStorage.layout().ledger.stage = IIGOWritableInternal.Stage.OPENED;
    }

    function pauseIGO() external override onlyOwner {
        IGOStorage.layout().ledger.stage = IIGOWritableInternal.Stage.PAUSED;
    }

    function updateGrandTotal(uint256 grandTotal_) external onlyOwner {
        require(grandTotal_ >= 1_000, "IGOWritable: grandTotal < 1_000");
        IGOStorage.layout().setUp.grandTotal = grandTotal_;
    }

    function updateTag(
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

    function updateToken(address token_) external onlyOwner {
        IGOStorage.layout().setUp.token = token_;
    }

    function updateTreasuryWallet(address addr) external onlyOwner {
        IGOStorage.layout().setUp.treasuryWallet = addr;
    }

    function recoverLostERC20(address token, address to) external onlyOwner {
        uint256 amount = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(to, amount);
    }

    //////////////////////////// PUBLIC ////////////////////////////
    /**
     * @dev If a tag with an identifier already exists, it will be
     *      overwritten, otherwise it will be created.
     */
    function setTags(
        string[] memory tagIdentifiers_,
        Tag[] memory tags_
    ) public override onlyOwner {
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
}
