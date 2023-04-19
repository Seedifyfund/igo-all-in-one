// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface IIGOWritableInternal {
    enum State {
        NOT_STARTED,
        STARTED,
        COMPLETED,
        PAUSED
    }

    struct Tag {
        State state;
        // contains wallet and allocation per wallet
        bytes32 merkleRoot;
        uint128 startAt;
        uint128 endAt;
        uint256 maxTagCap;
    }

    error IGOWritable_GreaterThanGrandTotal(
        string tagId,
        uint256 maxTagAllocation,
        uint256 grandTotal
    );
}
