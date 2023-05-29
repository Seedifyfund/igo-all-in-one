// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp_require} from "./setUp/IGOSetUp_require.t.sol";

contract IGO_Test_requireOpenedIGO is IGOSetUp_require {
    function testRevert_requireOpenedIGO_If_NOT_STARTED() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritableInternal_IGONotOpened.selector,
                Stage.NOT_STARTED
            )
        );
        instance.exposed_requireOpenedIGO();
    }

    function testRevert_requireOpenedIGO_If_PAUSED() public {
        instance.pauseIGO();
        assertEq(uint256(instance.igoStage()), uint256(Stage.PAUSED));
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritableInternal_IGONotOpened.selector,
                Stage.PAUSED
            )
        );
        instance.exposed_requireOpenedIGO();
    }

    function testRevert_requireOpenedIGO_If_COMPLETED() public {
        instance.exposed_closeIGO();
        assertEq(uint256(instance.igoStage()), uint256(Stage.COMPLETED));
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritableInternal_IGONotOpened.selector,
                Stage.COMPLETED
            )
        );
        instance.exposed_requireOpenedIGO();
    }

    function test_requireOpenedIGO() public {
        instance.openIGO();
        assertEq(uint256(instance.igoStage()), uint256(Stage.OPENED));
        assertTrue(instance.exposed_requireOpenedIGO());
    }
}
