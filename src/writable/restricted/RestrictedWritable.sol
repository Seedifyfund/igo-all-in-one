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
        IGOStorage.layout().ledger.status = ISharedInternal.Status.OPENED;
    }

    function pauseIGO() external override onlyOwner {
        IGOStorage.layout().ledger.status = ISharedInternal.Status.PAUSED;
    }

    function updateGrandTotal(
        uint256 grandTotal_
    ) external override onlyOwner {
        require(grandTotal_ >= 1_000, "grandTotal_LowerThan__1_000");
        _isSummedMaxTagCapLteGrandTotal(
            IGOStorage.layout().setUp.summedMaxTagCap,
            grandTotal_
        );
        IGOStorage.layout().setUp.grandTotal = grandTotal_;
    }

    /// @inheritdoc IRestrictedWritable
    function recoverLostERC20(
        address token,
        address to
    ) external override onlyOwner {
        require(token != address(0), "Token_ZERO_ADDRESS");
        uint256 amount = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(to, amount);
    }

    //////////////////////////// TAG BATCH UPDATES ////////////////////////////
    /// @inheritdoc IRestrictedWritable
    function updateSetTag(
        string calldata tagId_,
        ISharedInternal.Tag calldata tag_
    ) external override onlyOwner {
        ISharedInternal.Tag memory oldTagData = IGOStorage.layout().tags.data[
            tagId_
        ];
        require(_notEmptyTag(tag_), "EMPTY_TAG");

        IGOStorage.layout().setUp.summedMaxTagCap = _setTag(
            IGOStorage.layout().setUp.grandTotal,
            IGOStorage.layout().setUp.summedMaxTagCap,
            oldTagData.maxTagCap,
            tag_,
            tagId_
        );
    }

    /// @inheritdoc IRestrictedWritable
    function updateSetTags(
        string[] calldata tagIdentifiers_,
        ISharedInternal.Tag[] calldata tags_
    ) public override onlyOwner {
        _setTags(tagIdentifiers_, tags_);
    }

    //////////////////////////// TAG SINGLE UPDATE ////////////////////////////
    function openTag(string calldata tagId) external override onlyOwner {
        IGOStorage.layout().tags.data[tagId].status = ISharedInternal
            .Status
            .OPENED;
    }

    function pauseTag(string calldata tagId) external override onlyOwner {
        IGOStorage.layout().tags.data[tagId].status = ISharedInternal
            .Status
            .PAUSED;
    }

    function updateTagMerkleRoot(
        string calldata tagId,
        bytes32 merkleRoot
    ) external override onlyOwner {
        require(merkleRoot != bytes32(0), "MerkleRoot_EMPTY");
        IGOStorage.layout().tags.data[tagId].merkleRoot = merkleRoot;
    }

    function updateTagStartDate(
        string calldata tagId,
        uint128 startAt
    ) external override onlyOwner {
        require(startAt >= block.timestamp, "START_IN_PAST");
        IGOStorage.layout().tags.data[tagId].startAt = startAt;
    }

    function updateTagEndDate(
        string calldata tagId,
        uint128 endAt
    ) external override onlyOwner {
        require(endAt > block.timestamp, "END_IN_PAST");
        IGOStorage.layout().tags.data[tagId].endAt = endAt;
    }

    function updateTagMaxCap(
        string calldata tagId,
        uint256 maxTagCap
    ) external override onlyOwner {
        IGOStorage.SetUp memory setUp = IGOStorage.layout().setUp;
        uint256 summedMaxTagCap = setUp.summedMaxTagCap;

        summedMaxTagCap -= IGOStorage.layout().tags.data[tagId].maxTagCap;
        summedMaxTagCap += maxTagCap;

        _isSummedMaxTagCapLteGrandTotal(summedMaxTagCap, setUp.grandTotal);
        IGOStorage.layout().tags.data[tagId].maxTagCap = maxTagCap;
    }
}
