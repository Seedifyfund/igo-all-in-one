// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp_internal} from "./setUp/IGOSetUp_internal.t.sol";

contract IGO_Test__requireOpenedIGO is IGOSetUp_internal {
    function testRevert_requireOpenedIGO_If_NOT_STARTED() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritableInternal_IGONotOpened.selector,
                Status.NOT_STARTED
            )
        );
        instance.exposed_requireOpenedIGO();
    }

    function testRevert_requireOpenedIGO_If_PAUSED() public {
        instance.pauseIGO();
        assertEq(uint256(instance.igoStatus()), uint256(Status.PAUSED));
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritableInternal_IGONotOpened.selector,
                Status.PAUSED
            )
        );
        instance.exposed_requireOpenedIGO();
    }

    function testRevert_requireOpenedIGO_If_COMPLETED() public {
        instance.exposed_closeIGO();
        assertEq(uint256(instance.igoStatus()), uint256(Status.COMPLETED));
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritableInternal_IGONotOpened.selector,
                Status.COMPLETED
            )
        );
        instance.exposed_requireOpenedIGO();
    }

    function test_requireOpenedIGO() public {
        instance.openIGO();
        assertEq(uint256(instance.igoStatus()), uint256(Status.OPENED));
        assertTrue(instance.exposed_requireOpenedIGO());
    }
}
