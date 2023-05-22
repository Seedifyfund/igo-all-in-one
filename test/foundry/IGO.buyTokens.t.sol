// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";

import {IGOSetUp} from "./setUp/IGOSetUp.t.sol";

contract IGO_Test_buyTokens is IGOSetUp {
    address public buyer;

    function setUp() public override {
        super.setUp();
        buyer = allocations[0].account;
    }

    function test_token() public {
        (address token_, , ) = instance.setUp();
        assertEq(token_, address(token));
    }

    function test_buyTokens_TokenSuccessfullyTransfered() public {
        _setUpTestData();

        // before buying tokens
        uint256 balanceBeforeBuy = token.balanceOf(buyer);
        assertEq(token.balanceOf(treasuryWallet), 0);

        _buyTokens(allocations[0], lastProof);

        uint256 balanceAfterBuy = token.balanceOf(buyer);
        assertEq(balanceAfterBuy, balanceBeforeBuy - allocations[0].amount);
        assertEq(token.balanceOf(treasuryWallet), allocations[0].amount);
    }

    function test_buyTokens_UserBuyTheirAllocation_InMultipleTx() public {
        _setUpTestData();
        uint256 amount = allocations[0].amount;
        uint256 firstPart = amount / 4;

        /////////////////// buy first 25% of allocation ///////////////////
        _buyTokens(firstPart, allocations[0], lastProof);
        // verify `ledger.boughtByIn[allocation.account][tagId]` has been updated
        assertEq(instance.boughtByIn(buyer, allocations[0].tagId), firstPart);
        /////////////////// buys the rest of their allocation ///////////////////
        amount -= firstPart;
        _buyTokens(amount, allocations[0], lastProof);
        assertEq(
            instance.boughtByIn(buyer, allocations[0].tagId),
            allocations[0].amount
        );
    }

    function test_buyTokens_TagStageToCompleted() public {
        _setUpTestData();

        _buyTokens(allocations[0], lastProof);

        Tag memory tag = instance.tag(allocations[0].tagId);
        assertEq(uint256(tag.stage), uint256(Stage.COMPLETED));
    }

    function test_buyTokens_IGOStageToCompleted() public {
        instance.updateGrandTotal(allocations[0].amount);

        _setUpTestData();
        _buyTokens(allocations[0], lastProof);

        assertEq(uint256(instance.igoStage()), uint256(Stage.COMPLETED));
    }

    function test_buyTokens_WithSpecificTagToken() public {
        ERC20 tagToken = new ERC20("tagToken", "TAG");
        _setUpTestData(address(tagToken));
        // mint tagToken to allocation[0].account
        deal(address(tagToken), allocations[0].account, allocations[0].amount);
        assertEq(
            tagToken.balanceOf(allocations[0].account),
            allocations[0].amount
        );
        // unlimited allowance to permit2
        vm.prank(allocations[0].account);
        tagToken.approve(address(permit2), type(uint256).max);

        _buyTokensWithTagToken(address(tagToken), allocations[0], lastProof);

        assertEq(tagToken.balanceOf(treasuryWallet), allocations[0].amount);
        assertEq(tagToken.balanceOf(allocations[0].account), 0);
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
