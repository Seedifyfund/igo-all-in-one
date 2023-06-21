// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp_internal} from "./setUp/IGOSetUp_internal.t.sol";

contract IGO__Test_requireAuthorizedAccount is IGOSetUp_internal {
    function testRevert_requireAuthorizedAccount_If_NOT_AUTHORIZED() public {
        vm.startPrank(makeAddr("address23950"));
        vm.expectRevert("msg.sender: NOT_AUTHORIZED");
        instance.exposed_requireAuthorizedAccount(allocations[0].account);
    }

    function test_requireAuthorizedAccount() public {
        vm.startPrank(allocations[0].account);
        assertTrue(
            instance.exposed_requireAuthorizedAccount(allocations[0].account)
        );
    }
}
