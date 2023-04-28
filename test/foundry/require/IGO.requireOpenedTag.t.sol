// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp_require} from "./setUp/IGOSetUp_require.t.sol";

contract IGO_Test_requireOpenedTag is IGOSetUp_require {
    function testRevert_requireOpenedTag_If_NOT_STARTED() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritableInternal_TagNotOpened.selector,
                tagIdentifiers[0],
                Stage.NOT_STARTED
            )
        );
        instance.exposed_requireOpenedTag(tagIdentifiers[0]);
    }

    function testRevert_requireOpenedTag_If_PAUSED() public {
        instance.pauseTag(tagIdentifiers[0]);
        Tag memory tag_ = instance.tag(tagIdentifiers[0]);
        assertEq(uint256(tag_.stage), uint256(Stage.PAUSED));
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritableInternal_TagNotOpened.selector,
                tagIdentifiers[0],
                Stage.PAUSED
            )
        );
        instance.exposed_requireOpenedTag(tagIdentifiers[0]);
    }

    function testRevert_requireOpenedTag_If_COMPLETED() public {
        instance.exposed_closeTag(tagIdentifiers[0]);
        Tag memory tag_ = instance.tag(tagIdentifiers[0]);
        assertEq(uint256(tag_.stage), uint256(Stage.COMPLETED));
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritableInternal_TagNotOpened.selector,
                tagIdentifiers[0],
                Stage.COMPLETED
            )
        );
        instance.exposed_requireOpenedTag(tagIdentifiers[0]);
    }

    function test_requireOpenedTag() public {
        instance.openTag(tagIdentifiers[0]);
        Tag memory tag_ = instance.tag(tagIdentifiers[0]);
        assertEq(uint256(tag_.stage), uint256(Stage.OPENED));
        assertTrue(instance.exposed_requireOpenedTag(tagIdentifiers[0]));
    }
}
