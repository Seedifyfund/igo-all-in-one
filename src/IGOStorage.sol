// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ISharedInternal} from "./shared/ISharedInternal.sol";

/// @author https://github.com/Theo6890
library IGOStorage {
    // Only updated by owner
    struct SetUp {
        address vestingContract;
        address paymentToken;
        address permit2;
        uint256 grandTotal;
        // sum of maxTagCap OF all existing tags, can be lower than
        // `grandTotal` and maximum equal to `grandTotal`
        uint256 summedMaxTagCap;
        uint256 refundFeeDecimals;
    }

    // Updated by owner and users interactions
    struct Tags {
        string[] ids;
        mapping(string => ISharedInternal.Tag) data;
    }

    // Only updated by users interactions
    struct Ledger {
        ISharedInternal.Status status;
        uint256 totalRaised;
        mapping(string => uint256) raisedInTag;
        mapping(address => mapping(string => uint256)) boughtByIn;
    }

    struct IGOStruct {
        SetUp setUp;
        Tags tags;
        Ledger ledger;
    }

    bytes32 public constant IGO_STORAGE = keccak256("igo.storage");

    function layout() internal pure returns (IGOStruct storage igoStruct) {
        bytes32 position = IGO_STORAGE;
        assembly {
            igoStruct.slot := position
        }
    }
}
