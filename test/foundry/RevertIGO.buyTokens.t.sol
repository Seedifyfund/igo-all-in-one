// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp} from "./setUp/IGOSetUp.t.sol";

contract RevertIGO_Test_buyTokens is IGOSetUp {
    /*//////////////////////////////////////////////////////////////
                                 REVERT
    //////////////////////////////////////////////////////////////*/
    function testRevert_buyTokens_If_TagNotOpened() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritableInternal_TagNotOpened.selector,
                allocations[0].tagId,
                Stage.NOT_STARTED
            )
        );
        instance.buyTokens(allocations[0], new bytes32[](10));
    }

    function testRevert_buyTokens_If_TagCompledted() public {
        tags[0].stage = Stage.COMPLETED;
        instance.updateWholeTag(allocations[0].tagId, tags[0]);

        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritableInternal_TagNotOpened.selector,
                allocations[0].tagId,
                Stage.COMPLETED
            )
        );
        instance.buyTokens(allocations[0], new bytes32[](10));
    }

    function testRevert_buyTokens_If_TagPaused() public {
        tags[0].stage = Stage.PAUSED;
        instance.updateWholeTag(allocations[0].tagId, tags[0]);

        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritableInternal_TagNotOpened.selector,
                allocations[0].tagId,
                Stage.PAUSED
            )
        );
        instance.buyTokens(allocations[0], new bytes32[](10));
    }

    function testRevert_buyTokens_If_MsgSenderNotAuthorized() public {
        tags[0].stage = Stage.OPENED;
        instance.updateWholeTag(allocations[0].tagId, tags[0]);

        vm.startPrank(makeAddr("address23950"));
        vm.expectRevert("msg.sender: NOT_AUTHORIZED");
        instance.buyTokens(allocations[0], new bytes32[](10));
    }

    function testRevert_buyTokens_If_UserNotAddedToMerkleTreeAtAll() public {
        _setUpTestData();

        // msg.sender is not in any leaves of the tree so all allocation
        // containing msg.sender must fail
        for (uint256 i; i < leaves.length; ++i) {
            _generateMerkleRootAndProofForLeaf(i);

            allocations[i].account = msg.sender;

            vm.prank(msg.sender);
            // reverts with "ALLOCATION_NOT_FOUND", but issue when using string
            vm.expectRevert();
            instance.buyTokens(allocations[i], lastProof);
        }
    }

    // TODO: test merkle proof invalidity in more cases
    function testRevert_buyTokens_If_UserNotRegisteredToBuyInTagId() public {}

    function testRevert_buyTokens_If_UserNotClaimingTheRightAmount() public {}

    function testRevert_buyTokens_If_MaxTagCapExceeded() public {
        _setUpTestData();
        _increaseMaxTagCapBy(1);

        // buy tokens
        _buyTokens(
            allocations[0].account,
            allocations[0].amount,
            allocations[0],
            lastProof
        );

        // check maxTagCap reached
        Tag memory tag_ = instance.tag(allocations[0].tagId);
        assertEq(tag_.maxTagCap, allocations[0].amount + 1);

        // revert
        uint256 raisedAfterPurchase = instance.raisedInTag(
            allocations[0].tagId
        ) + allocations[0].amount;
        vm.startPrank(allocations[0].account);
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritable_MaxTagCapExceeded.selector,
                allocations[0].tagId,
                tag_.maxTagCap,
                raisedAfterPurchase - tag_.maxTagCap
            )
        );
        instance.buyTokens(allocations[0], lastProof);
    }

    function testRevert_buyTokens_If_GrandTotalExceeded() public {
        _setUpTestData();
        uint256 grandTotal_ = allocations[0].amount;
        instance.updateGrandTotal(grandTotal_);

        bytes32[] memory proof0;
        bytes32[] memory proof1;
        proof0 = lastProof;
        _generateMerkleRootAndProofForLeaf(1);
        proof1 = lastProof;

        // update merkle root & state for second tag
        tags[1] = tags[0];
        instance.updateWholeTag(tagIdentifiers[1], tags[1]);

        // buy tokens
        _buyTokens(
            allocations[0].account,
            allocations[0].amount,
            allocations[0],
            proof0
        );

        // revert
        vm.startPrank(allocations[1].account);
        (, , uint256 grTotal) = instance.setUp();
        uint256 totalAfterPurchase = grTotal + allocations[1].amount;
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritable_GrandTotalExceeded.selector,
                grandTotal_,
                totalAfterPurchase - grTotal
            )
        );
        instance.buyTokens(allocations[1], proof1);
    }
}
