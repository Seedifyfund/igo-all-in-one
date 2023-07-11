// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ISharedInternal} from "../../shared/ISharedInternal.sol";
import {IRestrictedWritableInternal} from "./IRestrictedWritableInternal.sol";

import {IGOStorage} from "../../IGOStorage.sol";

contract RestrictedWritableInternal is IRestrictedWritableInternal {
    function _setTag(
        uint256 grandTotal,
        uint256 summedMaxTagCap,
        uint256 oldMaxTagCap,
        ISharedInternal.Tag calldata tag_,
        string calldata tagId_
    ) internal returns (uint256) {
        summedMaxTagCap -= oldMaxTagCap;
        summedMaxTagCap += tag_.maxTagCap;

        _isSummedMaxTagCapLteGrandTotal(summedMaxTagCap, grandTotal);

        // if tag does not exist, push to ids
        if (oldMaxTagCap == 0) IGOStorage.layout().tags.ids.push(tagId_);
        IGOStorage.layout().tags.data[tagId_] = tag_;

        return summedMaxTagCap;
    }

    function _setTags(
        string[] calldata tagIdentifiers_,
        ISharedInternal.Tag[] calldata tags_
    ) internal {
        require(
            tagIdentifiers_.length == tags_.length,
            "IGOWritable: tags arrays length"
        );

        IGOStorage.Tags storage tags = IGOStorage.layout().tags;

        uint256 length = tagIdentifiers_.length;
        uint256 grandTotal = IGOStorage.layout().setUp.grandTotal;
        uint256 summedMaxTagCap = IGOStorage.layout().setUp.summedMaxTagCap;

        ISharedInternal.Tag memory oldTagData;

        //slither-disable-next-line uninitialized-local
        for (uint256 i; i < length; ++i) {
            oldTagData = tags.data[tagIdentifiers_[i]];
            _verifyTag(tags_[i], oldTagData);

            summedMaxTagCap = _setTag(
                grandTotal,
                summedMaxTagCap,
                oldTagData.maxTagCap,
                tags_[i],
                tagIdentifiers_[i]
            );
        }
        IGOStorage.layout().setUp.summedMaxTagCap = summedMaxTagCap;
    }

    function _notEmptyTag(
        ISharedInternal.Tag calldata tag_
    ) internal view returns (bool) {
        return
            tag_.merkleRoot != bytes32(0) &&
            tag_.startAt >= block.timestamp &&
            tag_.endAt > block.timestamp &&
            tag_.maxTagCap > 0;
    }

    /**
     * @notice Token used for payment and price of token project can only
     *         be updated before a tag is opened. Even if a tag is paused
     *         these variables can not be updated anymore.
     *
     * @dev If `paymentToken` is address(0) default IGO payment token is used,
     *      see `IGOWritable.reserveAllocation` --> paymentToken.
     */
    function _canPaymentTokenOrPriceBeUpdated(
        ISharedInternal.Status status,
        address oldPaymentToken,
        address newPaymentToken,
        uint256 oldProjectTokenPrice,
        uint256 newProjectTokenPrice
    ) internal pure {
        if (status == ISharedInternal.Status.NOT_STARTED) {
            if (newProjectTokenPrice == 0) {
                revert IGOWritable_ProjectTokenPrice_ZERO();
            }
        } else {
            if (
                oldPaymentToken != newPaymentToken ||
                oldProjectTokenPrice != newProjectTokenPrice
            ) revert IGOWritable_NoPaymentTokenOrPriceUpdate();
        }
    }

    function _isSummedMaxTagCapLteGrandTotal(
        uint256 summedMaxTagCap,
        uint256 grandTotal
    ) internal pure {
        if (summedMaxTagCap > grandTotal) {
            revert IGOWritable_SummedMaxTagCapGtGrandTotal(
                summedMaxTagCap - grandTotal
            );
        }
    }

    function _verifyTag(
        ISharedInternal.Tag calldata tag_,
        ISharedInternal.Tag memory oldTag
    ) internal view {
        require(_notEmptyTag(tag_), "EMPTY_TAG");
        _canPaymentTokenOrPriceBeUpdated(
            oldTag.status,
            oldTag.paymentToken,
            tag_.paymentToken,
            oldTag.projectTokenPrice,
            tag_.projectTokenPrice
        );
    }
}
