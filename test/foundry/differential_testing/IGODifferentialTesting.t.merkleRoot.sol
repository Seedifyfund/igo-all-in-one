// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {MerkleProof} from "openzeppelin-contracts/utils/cryptography/MerkleProof.sol";
import {Strings2} from "murky/differential_testing/test/utils/Strings2.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";

import "forge-std/Test.sol";

import {IIGOWritableInternal} from "../../../src/writable/IIGOWritableInternal.sol";

contract IGO_DifferentialTesting_merkleRoot is Test, IIGOWritableInternal {
    function testFuzzDifferential_generateLeaves_WithJSScript_CompareToSolidityLeaf(
        Allocation[] memory allocations
    ) public {
        vm.assume(allocations.length > 1);

        uint256 size = allocations.length;
        string[5] memory tagIds = [
            "igo-phase1",
            "igo-phase2",
            "vpr-base",
            "vpr-premium1",
            "vpr-premium2"
        ];
        for (uint256 i; i < size; ++i) {
            allocations[i].tagId = tagIds[i % tagIds.length];
        }

        bytes memory packedAllocations = abi.encode(allocations);
        // emit log_named_bytes("packed", packedAllocations);

        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/generateLeaves.js";
        cmd[2] = Strings2.toHexString(packedAllocations);
        bytes memory res = vm.ffi(cmd);

        bytes32[] memory leaves = abi.decode(res, (bytes32[]));

        uint256 loops = leaves.length > 10 ? 10 : leaves.length;
        bytes32 leaf;
        for (uint256 i; i < loops; ++i) {
            leaf = keccak256(abi.encode(allocations[i]));
            assertEq(leaves[i], leaf);
        }
    }

    function testFuzzDifferential_merkleRoot_VerifyOZMerkleProofCanBeUsedWith_MerkleTreeJS(
        bytes32[] memory leaves,
        uint256 nodeIndex
    ) public {
        vm.assume(leaves.length > 1);
        vm.assume(nodeIndex < leaves.length);

        // emit log_named_uint("leaves.length", leaves.length);
        // emit log_named_bytes32("leaves[0]", leaves[0]);

        bytes memory packed = abi.encode(leaves);
        emit log_named_bytes("packed", packed);

        string[] memory cmd = new string[](4);
        cmd[0] = "node";
        cmd[1] = "scripts/generateMerkleRootAndProof.js";
        cmd[2] = Strings2.toHexString(packed);
        cmd[3] = Strings.toString(nodeIndex);
        bytes memory res = vm.ffi(cmd);

        (bytes32 root, bytes32[] memory proof) = abi.decode(
            res,
            (bytes32, bytes32[])
        );
        // emit log_named_uint("proof.length", proof.length);
        // emit log_named_bytes32("proof[0]", proof[0]);

        assertTrue(MerkleProof.verify(proof, root, leaves[nodeIndex]));
    }
}
