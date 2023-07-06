// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp_internal} from "./setUp/IGOSetUp_internal.t.sol";

contract IGO_Test__updateStorageOnBuy is IGOSetUp_internal {
    function test_updateStorageOnBuy_CloseTagWhenEndDateReached() public {
        // block.timestamp == tag.endAt --> tag.status = COMPLETED
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
        assertEq(uint256(tag_.status), uint256(Status.COMPLETED));
    }
}
