// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IIGOWritableInternal} from "./writable/IIGOWritableInternal.sol";

library IGOStorage {
    struct IGOStruct {
        address token;
        address treasuryWallet;
        uint256 grandTotal;
        uint256 totalRaised;
        string[] tagIdentifiers;
        mapping(string => IIGOWritableInternal.Tag) tags;
        mapping(string => uint256) raisedInTag;
    }

    bytes32 public constant IGO_STORAGE = keccak256("igo.storage");

    function layout() internal pure returns (IGOStruct storage igoStruct) {
        bytes32 position = IGO_STORAGE;
        assembly {
            igoStruct.slot := position
        }
    }
}
