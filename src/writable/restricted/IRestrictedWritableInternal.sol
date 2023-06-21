// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface IRestrictedWritableInternal {
    error IGOWritable_NoPaymentTokenOrPriceUpdate();
    error IGOWritable_ProjectTokenPrice_ZERO();
    error IGOWritable_SummedMaxTagCapGtGrandTotal(uint256 greaterBy);
}
