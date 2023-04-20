// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp} from "./setUp/IGOSetUp.t.sol";
import {FFI_Merkletreejs} from "./utils/FFI_Merkletreejs.sol";

contract RevertIGO_Test_buyTokens is IGOSetUp, FFI_Merkletreejs {
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

    function testRevert_buyTokens_If_UserNotAddedToMerkleTreeAtAll() public {
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

    // TODO: test merkle proof invalidity in more cases
    function testRevert_buyTokens_If_UserNotRegisteredToBuyInTagId() public {}

    function testRevert_buyTokens_If_UserNotClaimingTheRightAmount() public {}

    function testRevert_buyTokens_If_MaxTagCapExceeded() public {
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
                IGOWritable_MaxTagCapExceeded.selector,
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
}
