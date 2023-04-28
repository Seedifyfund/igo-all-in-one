// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp} from "./setUp/IGOSetUp.t.sol";

contract RevertIGO_Test_buyTokens is IGOSetUp {
    uint256 constant amount = 10 ether;

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
            instance.buyTokens(amount, allocations[i], lastProof);
        }
    }

    // TODO: test merkle proof invalidity in more cases
    function testRevert_buyTokens_If_UserNotRegisteredToBuyInTagId() public {}
}
