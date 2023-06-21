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

        //slither-disable-next-line uninitialized-local
        for (uint256 i; i < length; ++i) {
            _canPaymentTokenOrPriceBeUpdated(
                tags.data[tagIdentifiers_[i]].stage,
                tags.data[tagIdentifiers_[i]].paymentToken,
                tags_[i].paymentToken,
                tags.data[tagIdentifiers_[i]].projectTokenPrice,
                tags_[i].projectTokenPrice
            );
            _isMaxTagAllocationGtGrandTotal(
                tagIdentifiers_[i],
                tags_[i].maxTagCap,
                grandTotal
            );
            tags.ids.push(tagIdentifiers_[i]);
            tags.data[tagIdentifiers_[i]] = tags_[i];
        }
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

    /// @dev Revert if max allocation in a tag is greater than grand total.
    function _isMaxTagAllocationGtGrandTotal(
        string memory tagId_,
        uint256 maxTagAllocation_,
        uint256 grandTotal_
    ) internal pure returns (bool) {
        if (maxTagAllocation_ > grandTotal_) {
            revert IGOWritable_GreaterThanGrandTotal(
                tagId_,
                maxTagAllocation_,
                grandTotal_
            );
        }
        return false;
    }
}
