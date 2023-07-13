// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface ISharedInternal {
    enum Status {
        NOT_STARTED,
        OPENED,
        COMPLETED,
        PAUSED
    }

    struct Tag {
        Status status;
        // contains wallet and allocation per wallet
        bytes32 merkleRoot;
        uint128 startAt;
        uint128 endAt;
        uint256 maxTagCap;
        // token of the tag, otherwise default IGO token
        address paymentToken;
    }
}
