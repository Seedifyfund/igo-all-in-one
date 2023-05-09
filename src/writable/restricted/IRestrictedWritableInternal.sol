// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface IRestrictedWritableInternal {
    error IGOWritable_GreaterThanGrandTotal(
        string tagId,
        uint256 maxTagAllocation,
        uint256 grandTotal
    );
}
