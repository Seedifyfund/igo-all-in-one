// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Strings2} from "murky/differential_testing/test/utils/Strings2.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";

import {IGOSetUp} from "./setUp/IGOSetUp.t.sol";

contract IGO_Test_buyTokens is IGOSetUp {
    /*//////////////////////////////////////////////////////////////
                                 REVERT
    //////////////////////////////////////////////////////////////*/
    function testRevert_buyTokens_If_NotOpened() public {
        bytes32[] memory proof = new bytes32[](10);

        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritable_NotOpened.selector,
                tagIdentifiers[0],
                State.NOT_STARTED
            )
        );
        instance.buyTokens(tagIdentifiers[0], 1_000_000 ether, proof);
    }

    function testRevert_buyTokens_If_LeafNotInMerkleTree() public {
        // generate 10 leaves
        bytes32[] memory leaves = __generateLeaves_WithJS_Script(10);
        // generate merkle root and proof for leaf at index 7
        (
            bytes32 merkleRoot,
            bytes32[] memory proof
        ) = __generateMerkleRootAndProofForLeaf(leaves, 7);

        string memory tagIdentifier = tagIdentifiers[0];

        // update merkle root & state
        tags[0].merkleRoot = merkleRoot;
        tags[0].state = State.OPENED;
        instance.updateWholeTag(tagIdentifier, tags[0]);

        // msg.sender is not in any leaves of the tree so it will not generate
        // any correct proof
        for (uint256 i; i < leaves.length; ++i) {
            (, proof) = __generateMerkleRootAndProofForLeaf(leaves, i);

            vm.expectRevert("IGOWritable.buyTokens: leaf not in merkle tree");
            instance.buyTokens(tagIdentifier, 1_000 ether, proof);
        }
    }

    function testRevert_buyTokens_If_MaxTagCapReached() public {
        // generate 10 leaves
        bytes32[] memory leaves = __generateLeaves_WithJS_Script(10);
        // generate merkle root and proof for leaf at index 0
        (
            bytes32 merkleRoot,
            bytes32[] memory proof
        ) = __generateMerkleRootAndProofForLeaf(leaves, 0);

        string memory tagIdentifier = tagIdentifiers[0];

        // update merkle root & state
        tags[0].merkleRoot = merkleRoot;
        tags[0].state = State.OPENED;
        tags[0].maxTagCap = 1_000 ether;
        instance.updateWholeTag(tagIdentifier, tags[0]);

        // buy tokens
        vm.startPrank(makeAddr("address0"));
        uint256 toBuy = 1_000 ether;
        instance.buyTokens(tagIdentifier, toBuy, proof);

        // check maxTagCap reached
        Tag memory tag_ = instance.tag(tagIdentifier);
        assertEq(tag_.maxTagCap, tags[0].maxTagCap);

        // revert
        uint256 raisedAfterPurchase = instance.raisedInTag(tagIdentifier) +
            toBuy;
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritable_MaxTagCapReached.selector,
                tagIdentifier,
                tags[0].maxTagCap,
                raisedAfterPurchase - tags[0].maxTagCap
            )
        );
        instance.buyTokens(tagIdentifier, 1_000 ether, proof);
    }

    function testRevert_buyTokens_If_GrandTotalExceeded() public {
        uint256 grandTotal_ = 1_000 ether;
        instance.updateGrandTotal(grandTotal_);

        // generate 10 leaves
        bytes32[] memory leaves = __generateLeaves_WithJS_Script(10);
        // generate merkle root and proof for leaf at index 0
        (
            bytes32 merkleRoot,
            bytes32[] memory proof
        ) = __generateMerkleRootAndProofForLeaf(leaves, 0);

        // update merkle root & state for first two tag
        for (uint256 i; i < 2; ++i) {
            tags[i].merkleRoot = merkleRoot;
            tags[i].state = State.OPENED;
            tags[i].maxTagCap = 1_000 ether;
            instance.updateWholeTag(tagIdentifiers[i], tags[i]);
        }

        // buy tokens
        vm.startPrank(makeAddr("address0"));
        uint256 toBuy = 1_000 ether;
        instance.buyTokens(tagIdentifiers[1], toBuy, proof);

        // revert
        uint256 totalAfterPurchase = instance.grandTotal() + toBuy;
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritable_GrandTotalExceeded.selector,
                grandTotal_,
                totalAfterPurchase - instance.grandTotal()
            )
        );
        instance.buyTokens(tagIdentifiers[0], toBuy, proof);
    }

    function __generateLeaves_WithJS_Script(
        uint256 leavesAmount
    ) private returns (bytes32[] memory leaves) {
        address[] memory addresses = new address[](leavesAmount);
        uint256[] memory allocations = new uint256[](leavesAmount);

        for (uint256 i; i < leavesAmount; ++i) {
            addresses[i] = makeAddr(
                string.concat("address", Strings.toString(i))
            );
            allocations[i] = (i + 1) * 1_000 ether;
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
    ) private returns (bytes32 merkleRoot, bytes32[] memory proof) {
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
