// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ISharedInternal} from "../shared/ISharedInternal.sol";

interface IIGOWritableInternal {
    struct Allocation {
        string tagId;
        address account;
        // maximum amount the user can spend, expressed in IGOStruct.SetUp.paymentToken OR Tag.paymentToken
        uint256 maxAllocation;
        // take IGOStorage.IGOStruct.SetUp.refundFeeDecimals into account
        uint256 refundFee;
        // price per token of the project behind the IGO, expressed in
        // `IGOSTorage.SetUp.paymentToken` (any ERC20)
        uint256 igoTokenPerPaymentToken;
    }

    struct BuyPermission {
        // permit2 signature to transfer tokens from the buyer to the treasury wallet
        bytes signature;
        // deadline on the permit signature
        uint256 deadline;
        // a unique value for every token owner's signature to prevent signature replays
        uint256 nonce;
    }

    event AllocationReserved(
        string indexed tagId,
        address indexed buyer,
        uint256 indexed maxAllocation,
        address paymentToken
    );

    error IGOWritableInternal_IGONotOpened(ISharedInternal.Status current);
    error IGOWritableInternal_TagNotOpened(
        string tagId,
        ISharedInternal.Status current
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
