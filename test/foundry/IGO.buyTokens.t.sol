// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp} from "./setUp/IGOSetUp.t.sol";

contract IGO_Test is IGOSetUp {
    /*//////////////////////////////////////////////////////////////
                                 REVERT
    //////////////////////////////////////////////////////////////*/
    function test_setTags_CheckSavedIdentifiersAndTag() public {
        string[] memory tagIds = instance.tagIdentifiers();
        Tag memory tag;

        assertEq(tagIds.length, tagIdentifiers.length);

        for (uint256 i; i < tagIds.length; ++i) {
            assertEq(tagIds[i], tagIdentifiers[i]);
            // check tags data
            tag = instance.tag(tagIds[i]);
            assertEq(uint256(tag.state), uint256(tags[i].state));
            assertEq(tag.merkleRoot, tags[i].merkleRoot);
            assertEq(tag.startAt, tags[i].startAt);
            assertEq(tag.endAt, tags[i].endAt);
            assertEq(tag.maxTagCap, tags[i].maxTagCap);
        }
    }
}
