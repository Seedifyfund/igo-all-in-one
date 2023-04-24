// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp} from "./setUp/IGOSetUp.t.sol";
import {FFI_Merkletreejs} from "./utils/FFI_Merkletreejs.sol";

contract IGO_Test_buyTokens is IGOSetUp, FFI_Merkletreejs {
    function test_token() public {
        assertEq(instance.token(), address(token));
    }

    function test_buyTokens_TokenSuccessfullyTrasfered() public {
        address buyer = makeAddr("address0");
        uint256 toBuy = 1_000 ether;
        Allocation memory allocation = Allocation({
            tagId: tagIdentifiers[0],
            account: buyer,
            amount: toBuy
        });
        deal(address(token), buyer, toBuy + 100 ether);

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
        tags[0].maxTagCap = 1_000 ether;
        instance.updateWholeTag(allocation.tagId, tags[0]);

        // buy tokens
        vm.startPrank(buyer);
        uint256 balanceBeforeBuy = token.balanceOf(buyer);
        assertEq(token.balanceOf(treasuryWallet), 0);

        token.increaseAllowance(address(instance), toBuy);
        instance.buyTokens(allocation, proof);

        uint256 balanceAfterBuy = token.balanceOf(buyer);
        assertEq(balanceAfterBuy, balanceBeforeBuy - toBuy);
        assertEq(token.balanceOf(treasuryWallet), toBuy);
    }

    //////////////// TODO: Tets success in a more complete scenario ////////////////
    /// @dev tagIdentifier must be part of leaves, to ensure `msg.sender` can only participant to computed tag
    /// grand total to 3_000,
    /// magTagCap of tagIdentifier[0] is 1_000 ether,
    /// magTagCap of tagIdentifier[1] is 2_000 ether,
    /// makeAddress('0') buys 1_000 ether in tagIdentifier[0],
    /// makeAddress('1') buy 2_000 ether in tagIdentifier[1],
    /// verify totalRaised & raisedInTag

    function test_recoverLostERC20() public {
        address sender = makeAddr("address0");
        uint256 lost = 1_000 ether;
        deal(address(token), sender, lost + 100 ether);

        vm.startPrank(sender);
        token.increaseAllowance(address(instance), lost);
        token.transfer(address(instance), lost);
        vm.stopPrank();

        assertEq(token.balanceOf(address(instance)), lost);
        assertEq(token.balanceOf(treasuryWallet), 0);

        // forge deployer is the owner
        instance.recoverLostERC20(address(token), treasuryWallet);
        assertEq(token.balanceOf(address(instance)), 0);
        assertEq(token.balanceOf(treasuryWallet), lost);
    }
}
