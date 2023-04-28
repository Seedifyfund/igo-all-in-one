// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp_require} from "./setUp/IGOSetUp_require.t.sol";

contract IGO_Test_requireAuthorizedAccount is IGOSetUp_require {
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
