// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import {Strings2} from "murky/differential_testing/test/utils/Strings2.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";

import {IIGOWritableInternal} from "../../../src/writable/IIGOWritableInternal.sol";

contract FFI_Merkletreejs is Test, IIGOWritableInternal {
    function __generateLeaves_WithJS_Script(
        string[] memory tagIdentifiers,
        uint256 leavesAmount
    ) internal returns (bytes32[] memory leaves) {
        Allocation[] memory allocations = new Allocation[](leavesAmount);

        for (uint256 i; i < leavesAmount; ++i) {
            allocations[i] = Allocation(
                tagIdentifiers[i % tagIdentifiers.length],
                makeAddr(string.concat("address", Strings.toString(i))),
                1_000 ether
            );
        }

        return __generateLeaves(abi.encode(allocations));
    }

    function __generateLeaves_WithJS_Script(
        Allocation[] memory allocations
    ) internal returns (bytes32[] memory leaves) {
        return __generateLeaves(abi.encode(allocations));
    }

    function __generateLeaves(
        bytes memory packedAllocations
    ) private returns (bytes32[] memory) {
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/generateLeaves.js";
        cmd[2] = Strings2.toHexString(packedAllocations);
        bytes memory res = vm.ffi(cmd);

        return abi.decode(res, (bytes32[]));
    }

    function __generateMerkleRootAndProofForLeaf(
        bytes32[] memory leaves,
        uint256 leafIndex
    ) internal returns (bytes32 merkleRoot, bytes32[] memory proof) {
        bytes memory packed = abi.encode(leaves);

        string[] memory cmd = new string[](4);
        cmd[0] = "node";
        cmd[1] = "scripts/generateMerkleRootAndProof.js";
        cmd[2] = Strings2.toHexString(packed);
        cmd[3] = Strings.toString(leafIndex);

        bytes memory res = vm.ffi(cmd);

        (merkleRoot, proof) = abi.decode(res, (bytes32, bytes32[]));
    }
}
