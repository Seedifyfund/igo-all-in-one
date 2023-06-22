// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp_internal} from "./setUp/IGOSetUp_internal.t.sol";

contract IGO_Test__requireOpenedTag is IGOSetUp_internal {
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

    function testRevert_requireOpenedTag_If_NOT_STARTED_EndDateReachedBeforeOpening()
        public
    {
        vm.warp(tags[0].endAt);
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

    function test_requireOpenedTag_OpenTagWhen_NotStartedAndDateReached()
        public
    {
        vm.warp(tags[0].startAt);

        assertTrue(instance.exposed_requireOpenedTag(tagIdentifiers[0]));

        Tag memory tag_ = instance.tag(tagIdentifiers[0]);
        assertEq(uint256(tag_.stage), uint256(Stage.OPENED));
    }
}
