// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Strings} from "openzeppelin-contracts/utils/Strings.sol";
import {Strings2} from "murky/differential_testing/test/utils/Strings2.sol";

import {IGOSetUp_require} from "./setUp/IGOSetUp_require.t.sol";

contract IGO_Test_requireValidAllocation is IGOSetUp_require {
    function testRevert_requireValidAllocation_If_EmptyProof() public {
        vm.expectRevert("ALLOCATION_NOT_FOUND");
        instance.exposed_requireValidAllocation(
            allocations[0],
            new bytes32[](10)
        );
    }

    function test_requireValidAllocation() public {
        uint256 leafIndex = 2;

        //////////// generate leaves ////////////
        bytes memory packedAllocations = abi.encode(allocations);
        // emit log_named_bytes("packed", packedAllocations);
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/generateLeaves.js";
        cmd[2] = Strings2.toHexString(packedAllocations);
        bytes memory res = vm.ffi(cmd);
        bytes32[] memory leaves = abi.decode(res, (bytes32[]));

        //////////// generate merkle tree & proof ////////////
        bytes memory packedLeaves = abi.encode(leaves);
        // emit log_named_bytes("packed", packedLeaves);
        cmd = new string[](4);
        cmd[0] = "node";
        cmd[1] = "scripts/generateMerkleRootAndProof.js";
        cmd[2] = Strings2.toHexString(packedLeaves);
        cmd[3] = Strings.toString(leafIndex);
        res = vm.ffi(cmd);
        (bytes32 root, bytes32[] memory proof) = abi.decode(
            res,
            (bytes32, bytes32[])
        );

        //////////// verify reauire is sucessful ////////////
        instance.updateTagMerkleRoot(tagIdentifiers[2], root);
        assertTrue(
            instance.exposed_requireValidAllocation(
                allocations[leafIndex],
                proof
            )
        );
    }
}
