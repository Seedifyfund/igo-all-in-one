// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IStageInternal} from "../shared/IStageInternal.sol";

interface IRestrictedWritableInternal {
    struct Tag {
        IStageInternal.Stage stage;
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
