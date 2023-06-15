// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp_require} from "./setUp/IGOSetUp_require.t.sol";

contract IGO_Test_updateStorageOnBuy is IGOSetUp_require {
    function test_updateStorageOnBuy_CloseTagWhenEndDateReached() public {
        // block.timestamp == tag.endAt --> tag.stage = COMPLETED
        vm.warp(tags[0].endAt);
        assertTrue(
            instance.exposed_updateStorageOnBuy(
                1 ether,
                tagIdentifiers[0],
                msg.sender,
                1_000_000 ether,
                1000_000 ether
            )
        );

        Tag memory tag_ = instance.tag(tagIdentifiers[0]);
        assertEq(uint256(tag_.stage), uint256(Stage.COMPLETED));
    }
}
