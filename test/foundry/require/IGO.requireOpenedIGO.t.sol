// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp} from "../setUp/IGOSetUp.t.sol";

contract IGO_Test_requireOpenedIGO is IGOSetUp {
    function testRevert_requireOpenedIGO_If_IGONotOpened() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritableInternal_IGONotOpened.selector,
                Stage.NOT_STARTED
            )
        );
        instance.exposed_requireOpenedIGO();
    }

    function test_requireOpenedIGO() public {
        instance.openIGO();
        instance.exposed_requireOpenedIGO();
    }
}
