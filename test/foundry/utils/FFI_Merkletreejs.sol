// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import {Strings2} from "murky/differential_testing/test/utils/Strings2.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";

contract FFI_Merkletreejs is Test {
    function __generateLeaves_WithJS_Script(
        uint256 leavesAmount
    ) internal returns (bytes32[] memory leaves) {
        address[] memory addresses = new address[](leavesAmount);
        uint256[] memory allocations = new uint256[](leavesAmount);

        for (uint256 i; i < leavesAmount; ++i) {
            addresses[i] = makeAddr(
                string.concat("address", Strings.toString(i))
            );
            allocations[i] = 1_000 ether;
        }

        bytes memory packedAddresses = abi.encode(addresses);
        bytes memory packedAllocations = abi.encode(allocations);

        string[] memory cmd = new string[](4);
        cmd[0] = "node";
        cmd[1] = "scripts/generateLeaves.js";
        cmd[2] = Strings2.toHexString(packedAddresses);
        cmd[3] = Strings2.toHexString(packedAllocations);
        bytes memory res = vm.ffi(cmd);

        leaves = abi.decode(res, (bytes32[]));
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
