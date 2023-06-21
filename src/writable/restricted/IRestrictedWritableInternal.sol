// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface IRestrictedWritableInternal {
    error IGOWritable_NoPaymentTokenOrPriceUpdate();
    error IGOWritable_ProjectTokenPrice_ZERO();
    // TODO: update parameter name: uint256 greaterBy
    error IGOWritable_SummedMaxTagCapGtGrandTotal(
        uint256 summedMaxTagCap,
        uint256 grandTotal
    );
}
