// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IIGOWritableInternal} from "./writable/IIGOWritableInternal.sol";

library IGOStorage {
    struct IGOStruct {
        uint256 grandTotal;
        string[] tagIdentifiers;
        mapping(string => IIGOWritableInternal.Tag) tags;
    }

    bytes32 public constant IGO_STORAGE = keccak256("igo.storage");

    function layout() internal pure returns (IGOStruct storage igoStruct) {
        bytes32 position = IGO_STORAGE;
        assembly {
            igoStruct.slot := position
        }
    }
}
