// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface IIGOWritableInternal {
    enum State {
        NOT_STARTED,
        OPENED,
        COMPLETED,
        PAUSED
    }

    struct Allocation {
        string tagId;
        address account;
        uint256 amount;
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
    error IGOWritable_NotOpened(string tagId, State state);
    // TODO: update to IGOWritable_MaxTagCapExceeded
    error IGOWritable_MaxTagCapExceeded(
        string tagId,
        uint256 maxTagCap,
        uint256 exceedsBy
    );
    error IGOWritable_GrandTotalExceeded(
        uint256 grandTotal,
        uint256 exceedsBy
    );
}
