// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {MerkleProof} from "openzeppelin-contracts/utils/cryptography/MerkleProof.sol";
import {Strings2} from "murky/differential_testing/test/utils/Strings2.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";

import "forge-std/Test.sol";

import {IGO} from "../../src/IGO.sol";
import {IIGOWritableInternal} from "../../src/writable/IIGOWritableInternal.sol";

contract IGO_Test_merkleRoot is Test, IIGOWritableInternal {
    IGO public instance;

    uint256 public grandTotal = 50_000_000 ether;
    string[] public tagIdentifiers;
    Tag[] public tags;

    function setUp() public {
        instance = new IGO(grandTotal);

        tagIdentifiers.push("vpr-base");
        tagIdentifiers.push("vpr-premium1");
        tagIdentifiers.push("vpr-premium2");
        tagIdentifiers.push("igo-phase1");
        tagIdentifiers.push("igo-phase2");
        tagIdentifiers.push("igo-phase3");

        uint128 lastStart = 60;
        uint128 lastEnd = 1 hours;
        uint256 maxTagAllocation = 1_000_000 ether;

        for (uint256 i; i < tagIdentifiers.length; ++i) {
            maxTagAllocation = 1_000_000 ether * (i + 1);

            tags.push(
                Tag(
                    State.NOT_STARTED,
                    bytes32(0),
                    uint128(block.timestamp) + lastStart,
                    uint128(block.timestamp) + lastEnd,
                    maxTagAllocation
                )
            );

            lastStart = lastEnd;
            lastEnd += 1 hours;
        }

        instance.setTags(tagIdentifiers, tags);
    }

    function testFuzzDifferentail_generateLeaves_WithJSScript_CompareToSolidityLeaf(
        address[] memory addresses,
        uint256[] memory allocations
    ) public {
        vm.assume(addresses.length > 1);
        vm.assume(addresses.length == allocations.length);

        bytes memory packedAddresses = abi.encode(addresses);
        bytes memory packedAllocations = abi.encode(allocations);
        // emit log_named_bytes("packed", packedAddresses);
        // emit log_named_bytes("packed", packedAllocations);

        string[] memory cmd = new string[](4);
        cmd[0] = "node";
        cmd[1] = "scripts/generateLeaves.js";
        cmd[2] = Strings2.toHexString(packedAddresses);
        cmd[3] = Strings2.toHexString(packedAllocations);
        bytes memory res = vm.ffi(cmd);

        bytes32[] memory leaves = abi.decode(res, (bytes32[]));
        // emit log_named_uint("leaves.length", leaves.length);
        // emit log_named_bytes32("leaves[0]", leaves[0]);
        bytes32 leaf = keccak256(
            abi.encodePacked(addresses[0], allocations[0])
        );
        // emit log_named_bytes32("leaf - addresses[0] allocations[0]", leaf);

        uint256 loops = leaves.length > 10 ? 10 : leaves.length;

        for (uint256 i; i < loops; ++i) {
            leaf = keccak256(abi.encodePacked(addresses[i], allocations[i]));
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
