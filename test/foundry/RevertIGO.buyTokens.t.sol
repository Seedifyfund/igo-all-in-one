// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp} from "./setUp/IGOSetUp.t.sol";
import {FFI_Merkletreejs} from "./utils/FFI_Merkletreejs.sol";

contract RevertIGO_Test_buyTokens is IGOSetUp, FFI_Merkletreejs {
    Allocation[] public allocations;
    Allocation public allocation;

    function setUp() public override {
        super.setUp();
        allocation = Allocation({
            tagId: tagIdentifiers[0],
            account: msg.sender,
            amount: 1_000_000 ether
        });
    }

    /*//////////////////////////////////////////////////////////////
                                 REVERT
    //////////////////////////////////////////////////////////////*/
    function testRevert_buyTokens_If_NotOpened() public {
        bytes32[] memory proof = new bytes32[](10);

        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritable_NotOpened.selector,
                allocation.tagId,
                State.NOT_STARTED
            )
        );
        instance.buyTokens(allocation, proof);
    }

    function testRevert_buyTokens_If_UserNotAddedToMerkleTreeAtAll() public {
        allocation.amount = 1_000 ether;

        // generate 10 leaves
        bytes32[] memory leaves = __generateLeaves_WithJS_Script(
            tagIdentifiers,
            10
        );
        // generate merkle root and proof for leaf at index 7
        (
            bytes32 merkleRoot,
            bytes32[] memory proof
        ) = __generateMerkleRootAndProofForLeaf(leaves, 7);

        // update merkle root & state
        tags[0].merkleRoot = merkleRoot;
        tags[0].state = State.OPENED;
        instance.updateWholeTag(allocation.tagId, tags[0]);

        // msg.sender is not in any leaves of the tree so it will not generate
        // any correct proof
        for (uint256 i; i < leaves.length; ++i) {
            (, proof) = __generateMerkleRootAndProofForLeaf(leaves, i);

            vm.expectRevert("ALLOCATION_NOT_FOUND");
            instance.buyTokens(allocation, proof);
        }
    }

    // TODO: test merkle proof invalidity in more cases
    function testRevert_buyTokens_If_UserNotRegisteredToBuyInTagId() public {}

    function testRevert_buyTokens_If_UserNotClaimingTheRightAmount() public {}

    function testRevert_buyTokens_If_MaxTagCapExceeded() public {
        allocation.account = makeAddr("address0");
        allocation.amount = 1_000 ether;
        deal(
            address(token),
            allocation.account,
            allocation.amount + 100 ether
        );

        // generate 10 leaves
        bytes32[] memory leaves = __generateLeaves_WithJS_Script(
            tagIdentifiers,
            10
        );
        // generate merkle root and proof for leaf at index 0
        (
            bytes32 merkleRoot,
            bytes32[] memory proof
        ) = __generateMerkleRootAndProofForLeaf(leaves, 0);

        // update merkle root & state
        tags[0].merkleRoot = merkleRoot;
        tags[0].state = State.OPENED;
        tags[0].maxTagCap = allocation.amount;
        instance.updateWholeTag(allocation.tagId, tags[0]);

        // buy tokens
        vm.startPrank(allocation.account);
        token.increaseAllowance(address(instance), allocation.amount);
        instance.buyTokens(allocation, proof);

        // check maxTagCap reached
        Tag memory tag_ = instance.tag(allocation.tagId);
        assertEq(tag_.maxTagCap, tags[0].maxTagCap);

        // revert
        uint256 raisedAfterPurchase = instance.raisedInTag(allocation.tagId) +
            allocation.amount;
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritable_MaxTagCapExceeded.selector,
                allocation.tagId,
                tags[0].maxTagCap,
                raisedAfterPurchase - tags[0].maxTagCap
            )
        );
        instance.buyTokens(allocation, proof);
    }

    function testRevert_buyTokens_If_GrandTotalExceeded() public {
        uint256 grandTotal_ = 1_000 ether;
        instance.updateGrandTotal(grandTotal_);

        allocations.push(
            Allocation({
                tagId: tagIdentifiers[0],
                account: makeAddr("address0"),
                amount: grandTotal_
            })
        );
        allocations.push(
            Allocation({
                tagId: tagIdentifiers[1],
                account: makeAddr("address1"),
                amount: 1 ether
            })
        );

        deal(
            address(token),
            allocations[0].account,
            allocations[0].amount + 100 ether
        );

        // generate 10 leaves
        bytes32[] memory leaves = __generateLeaves_WithJS_Script(allocations);
        // generate merkle root and proof for leaf at index 0
        (
            bytes32 merkleRoot,
            bytes32[] memory proof0
        ) = __generateMerkleRootAndProofForLeaf(leaves, 0);
        (, bytes32[] memory proof1) = __generateMerkleRootAndProofForLeaf(
            leaves,
            1
        );

        // update merkle root & state for first two tag
        for (uint256 i; i < 2; ++i) {
            tags[i].merkleRoot = merkleRoot;
            tags[i].state = State.OPENED;
            tags[i].maxTagCap = 1_000 ether;
            instance.updateWholeTag(tagIdentifiers[i], tags[i]);
        }

        // buy tokens
        vm.startPrank(allocations[0].account);
        token.increaseAllowance(address(instance), allocations[0].amount);
        instance.buyTokens(allocations[0], proof0);

        // revert
        changePrank(allocations[1].account);
        uint256 totalAfterPurchase = instance.grandTotal() +
            allocations[1].amount;
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritable_GrandTotalExceeded.selector,
                grandTotal_,
                totalAfterPurchase - instance.grandTotal()
            )
        );
        instance.buyTokens(allocations[1], proof1);
    }
}
