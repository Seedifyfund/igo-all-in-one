// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ISharedInternal} from "../shared/ISharedInternal.sol";

interface IIGOWritableInternal {
    struct Allocation {
        string tagId;
        address account;
        uint256 amount;
    }

    struct BuyPermission {
        // permit2 signature to transfer tokens from the buyer to the treasury wallet
        bytes signature;
        // deadline on the permit signature
        uint256 deadline;
        // a unique value for every token owner's signature to prevent signature replays
        uint256 nonce;
    }

    error IGOWritableInternal_IGONotOpened(ISharedInternal.Stage current);
    error IGOWritableInternal_TagNotOpened(
        string tagId,
        ISharedInternal.Stage current
    );
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
