// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ISharedInternal} from "../../shared/ISharedInternal.sol";
import {IRestrictedWritableInternal} from "./IRestrictedWritableInternal.sol";

import {IGOStorage} from "../../IGOStorage.sol";

contract RestrictedWritableInternal is IRestrictedWritableInternal {
    function _setTags(
        string[] memory tagIdentifiers_,
        ISharedInternal.Tag[] memory tags_
    ) internal {
        IGOStorage.Tags storage tags = IGOStorage.layout().tags;

        require(
            tagIdentifiers_.length == tags_.length,
            "IGOWritable: tags arrays length"
        );

        uint256 length = tagIdentifiers_.length;
        uint256 grandTotal = IGOStorage.layout().setUp.grandTotal;
        uint256 summedMaxTagCap = IGOStorage.layout().setUp.summedMaxTagCap;

        ISharedInternal.Tag memory oldTagData;

        //slither-disable-next-line uninitialized-local
        for (uint256 i; i < length; ++i) {
            oldTagData = tags.data[tagIdentifiers_[i]];
            require(_isValidTag(tags_[i]), "INVALID_TAG");

            _canPaymentTokenOrPriceBeUpdated(
                oldTagData.stage,
                oldTagData.paymentToken,
                tags_[i].paymentToken,
                oldTagData.projectTokenPrice,
                tags_[i].projectTokenPrice
            );

            /**
             * @dev if tag is new, oldTagData.maxTagCap is 0, avoid extra as
             *      subtraction only cost 3 gas
             */
            summedMaxTagCap -= oldTagData.maxTagCap;
            summedMaxTagCap += tags_[i].maxTagCap;

            _isSummedMaxTagCapLteGrandTotal(summedMaxTagCap, grandTotal);

            // if tag does not exist, push to ids
            if (oldTagData.maxTagCap == 0) tags.ids.push(tagIdentifiers_[i]);
            tags.data[tagIdentifiers_[i]] = tags_[i];
        }
        IGOStorage.layout().setUp.summedMaxTagCap = summedMaxTagCap;
    }

    function _isValidTag(
        ISharedInternal.Tag memory tag_
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
        ISharedInternal.Stage stage,
        address oldPaymentToken,
        address newPaymentToken,
        uint256 oldProjectTokenPrice,
        uint256 newProjectTokenPrice
    ) internal pure {
        if (stage == ISharedInternal.Stage.NOT_STARTED) {
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
}
