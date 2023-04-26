// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IIGOWritableInternal} from "./writable/IIGOWritableInternal.sol";

library IGOStorage {
    // Only updated by owner
    struct SetUp {
        address token;
        address treasuryWallet;
        uint256 grandTotal;
    }

    // Updated by owner and users interactions
    struct Tags {
        string[] ids;
        mapping(string => IIGOWritableInternal.Tag) data;
    }

    // Only updated by users interactions
    struct Ledger {
        IIGOWritableInternal.Stage stage;
        uint256 totalRaised;
        mapping(string => uint256) raisedInTag;
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
