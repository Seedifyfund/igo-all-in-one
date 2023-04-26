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

    struct Tag {
        Stage stage;
        // contains wallet and allocation per wallet
        bytes32 merkleRoot;
        uint128 startAt;
        uint128 endAt;
        uint256 maxTagCap;
    }

    error IGOWritableInternal_IGONotOpened(Stage current);
    error IGOWritableInternal_TagNotOpened(string tagId, Stage current);
    error IGOWritable_GreaterThanGrandTotal(
        string tagId,
        uint256 maxTagAllocation,
        uint256 grandTotal
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
