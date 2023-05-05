// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IRestrictedWritableInternal} from "./writable/restricted/IRestrictedWritableInternal.sol";
import {IStageInternal} from "./writable/shared/IStageInternal.sol";

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
        mapping(string => IRestrictedWritableInternal.Tag) data;
    }

    // Only updated by users interactions
    struct Ledger {
        IStageInternal.Stage stage;
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
