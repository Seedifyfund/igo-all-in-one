// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

import {SafeERC20} from "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";

import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

import {ISharedInternal} from "../../shared/ISharedInternal.sol";
import {IRestrictedWritable} from "./IRestrictedWritable.sol";

import {IGOStorage} from "../../IGOStorage.sol";

import {RestrictedWritableInternal} from "./RestrictedWritableInternal.sol";

/**
 * @dev Inherits from `ISharedInternal` will create `error[5005]: Linearization of inheritance graph impossible`
 */
contract RestrictedWritable is
    IRestrictedWritable,
    RestrictedWritableInternal,
    Ownable
{
    using SafeERC20 for IERC20;

    function openIGO() external override onlyOwner {
        IGOStorage.layout().ledger.stage = ISharedInternal.Stage.OPENED;
    }

    function pauseIGO() external override onlyOwner {
        IGOStorage.layout().ledger.stage = ISharedInternal.Stage.PAUSED;
    }

    function updateGrandTotal(
        uint256 grandTotal_
    ) external override onlyOwner {
        require(grandTotal_ >= 1_000, "IGOWritable: grandTotal < 1_000");
        IGOStorage.layout().setUp.grandTotal = grandTotal_;
    }

    /// @inheritdoc IRestrictedWritable
    function updateToken(address token_) external override onlyOwner {
        IGOStorage.layout().setUp.paymentToken = token_;
    }

    function updateTreasuryWallet(address addr) external override onlyOwner {
        IGOStorage.layout().setUp.treasuryWallet = addr;
    }

    /// @inheritdoc IRestrictedWritable
    function recoverLostERC20(
        address token,
        address to
    ) external override onlyOwner {
        uint256 amount = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(to, amount);
    }

    //////////////////////////// TAG BATCH UPDATES ////////////////////////////
    /// @inheritdoc IRestrictedWritable
    function updateTag(
        string calldata tagId_,
        ISharedInternal.Tag calldata tag_
    ) external override onlyOwner {
        IGOStorage.Tags storage tags = IGOStorage.layout().tags;

        _isMaxTagAllocationGtGrandTotal(
            tagId_,
            tag_.maxTagCap,
            IGOStorage.layout().setUp.grandTotal
        );

        tags.data[tagId_] = tag_;
    }

    /// @inheritdoc IRestrictedWritable
    function setTags(
        string[] memory tagIdentifiers_,
        ISharedInternal.Tag[] memory tags_
    ) public override onlyOwner {
        _setTags(tagIdentifiers_, tags_);
    }

    //////////////////////////// TAG SINGLE UPDATE ////////////////////////////
    function openTag(string memory tagId) external override onlyOwner {
        IGOStorage.layout().tags.data[tagId].stage = ISharedInternal
            .Stage
            .OPENED;
    }

    function pauseTag(string memory tagId) external override onlyOwner {
        IGOStorage.layout().tags.data[tagId].stage = ISharedInternal
            .Stage
            .PAUSED;
    }

    function updateTagMerkleRoot(
        string memory tagId,
        bytes32 merkleRoot
    ) external override onlyOwner {
        IGOStorage.layout().tags.data[tagId].merkleRoot = merkleRoot;
    }

    function updateTagStartDate(
        string memory tagId,
        uint128 startAt
    ) external override onlyOwner {
        IGOStorage.layout().tags.data[tagId].startAt = startAt;
    }

    function updateTagEndDate(
        string memory tagId,
        uint128 endAt
    ) external override onlyOwner {
        IGOStorage.layout().tags.data[tagId].endAt = endAt;
    }

    function updateTagMaxCap(
        string memory tagId,
        uint256 maxTagCap
    ) external override onlyOwner {
        _isMaxTagAllocationGtGrandTotal(
            tagId,
            maxTagCap,
            IGOStorage.layout().setUp.grandTotal
        );
        IGOStorage.layout().tags.data[tagId].maxTagCap = maxTagCap;
    }
}
