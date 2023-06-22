// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";

import {IGOSetUp} from "./setUp/IGOSetUp.t.sol";

contract IGO_Test_reserveAllocation is IGOSetUp {
    address public buyer;

    function setUp() public override {
        super.setUp();
        buyer = allocations[0].account;
    }

    function test_token() public {
        (address token_, , ) = instance.setUp();
        assertEq(token_, address(token));
    }

    function test_reserveAllocation_TokenSuccessfullyTransfered() public {
        _setUpTestData();

        // before buying tokens
        uint256 balanceBeforeBuy = token.balanceOf(buyer);
        assertEq(token.balanceOf(vestingContract), 0);

        _reserveAllocation(allocations[0], lastProof);

        uint256 balanceAfterBuy = token.balanceOf(buyer);
        assertEq(
            balanceAfterBuy,
            balanceBeforeBuy - allocations[0].paymentTokenAmount
        );
        assertEq(
            token.balanceOf(vestingContract),
            allocations[0].paymentTokenAmount
        );
    }

    function test_reserveAllocation_UserBuyTheirAllocation_InMultipleTx()
        public
    {
        _setUpTestData();
        uint256 amount = allocations[0].paymentTokenAmount;
        uint256 firstPart = amount / 4;

        /////////////////// buy first 25% of allocation ///////////////////
        _reserveAllocation(firstPart, allocations[0], lastProof);
        // verify `ledger.boughtByIn[allocation.account][tagId]` has been updated
        assertEq(instance.boughtByIn(buyer, allocations[0].tagId), firstPart);
        /////////////////// buys the rest of their allocation ///////////////////
        amount -= firstPart;
        _reserveAllocation(amount, allocations[0], lastProof);
        assertEq(
            instance.boughtByIn(buyer, allocations[0].tagId),
            allocations[0].paymentTokenAmount
        );
    }

    function test_reserveAllocation_TagStageToCompleted() public {
        _setUpTestData();

        _reserveAllocation(allocations[0], lastProof);

        Tag memory tag = instance.tag(allocations[0].tagId);
        assertEq(uint256(tag.stage), uint256(Stage.COMPLETED));
    }

    function test_reserveAllocation_WithSpecificTagToken() public {
        ERC20 tagToken = new ERC20("tagToken", "TAG");
        _setUpTestData(address(tagToken));
        // mint tagToken to allocation[0].account
        deal(
            address(tagToken),
            allocations[0].account,
            allocations[0].paymentTokenAmount
        );
        assertEq(
            tagToken.balanceOf(allocations[0].account),
            allocations[0].paymentTokenAmount
        );
        // unlimited allowance to permit2
        vm.prank(allocations[0].account);
        tagToken.approve(address(permit2), type(uint256).max);

        _reserveAllocationWithTagToken(
            address(tagToken),
            allocations[0],
            lastProof
        );

        assertEq(
            tagToken.balanceOf(vestingContract),
            allocations[0].paymentTokenAmount
        );
        assertEq(tagToken.balanceOf(allocations[0].account), 0);
    }

    function test_recoverLostERC20() public {
        address sender = makeAddr("address0");
        uint256 lost = 1_000 ether;
        deal(address(token), sender, lost + 100 ether);

        vm.startPrank(sender);
        token.transfer(address(instance), lost);
        vm.stopPrank();

        assertEq(token.balanceOf(address(instance)), lost);
        assertEq(token.balanceOf(vestingContract), 0);

        // forge deployer is the owner
        instance.recoverLostERC20(address(token), vestingContract);
        assertEq(token.balanceOf(address(instance)), 0);
        assertEq(token.balanceOf(vestingContract), lost);
    }
}
