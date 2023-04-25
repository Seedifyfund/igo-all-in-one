// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import {Strings2} from "murky/differential_testing/test/utils/Strings2.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";

import {IIGOWritableInternal} from "../../../src/writable/IIGOWritableInternal.sol";

import {IGO} from "../../../src/IGO.sol";

contract FFI_Merkletreejs is Test, IIGOWritableInternal {
    bytes32[] public leaves;
    bytes32 public merkleRoot;
    bytes32[] public lastProof;

    function _generateLeaves(Allocation[] memory allocations) internal {
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/generateLeaves.js";
        cmd[2] = Strings2.toHexString(abi.encode(allocations));
        bytes memory res = vm.ffi(cmd);

        leaves = abi.decode(res, (bytes32[]));
    }

    function _generateMerkleRootAndProofForLeaf(uint256 leafIndex) internal {
        bytes memory packed = abi.encode(leaves);

        string[] memory cmd = new string[](4);
        cmd[0] = "node";
        cmd[1] = "scripts/generateMerkleRootAndProof.js";
        cmd[2] = Strings2.toHexString(packed);
        cmd[3] = Strings.toString(leafIndex);

        bytes memory res = vm.ffi(cmd);

        (merkleRoot, lastProof) = abi.decode(res, (bytes32, bytes32[]));
    }
}
