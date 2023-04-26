// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface IIGOWritableInternal {
    enum Stage {
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

    error IGOWritableInternal_IGONotOpened(Stage current);
    error IGOWritableInternal_TagNotOpened(string tagId, Stage current);
    error IGOWritable_AllocationExceeded(
        uint256 allocation,
        uint256 exceedsBy
    );
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
