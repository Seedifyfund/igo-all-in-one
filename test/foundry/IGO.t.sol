// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp} from "./setUp/IGOSetUp.t.sol";

contract IGO_Test is IGOSetUp {
    function test_grandTotal() public {
        // check grandTotal set in constructor
        (, , uint256 grandTotal_) = instance.setUp();
        assertEq(grandTotal_, grandTotal);

        instance.updateGrandTotal(1_000_000);
        (, , grandTotal_) = instance.setUp();
        assertEq(grandTotal_, 1_000_000);

        vm.expectRevert("IGOWritable: grandTotal < 1_000");
        instance.updateGrandTotal(999);
    }

    /*//////////////////////////////////////////////////////////////
                                 SET TAGS
    //////////////////////////////////////////////////////////////*/
    function test_setTags_CheckSavedIdentifiersAndTag() public {
        string[] memory tagIds = instance.tagIds();
        Tag memory tag;

        assertEq(tagIds.length, tagIdentifiers.length);

        for (uint256 i; i < tagIds.length; ++i) {
            assertEq(tagIds[i], tagIdentifiers[i]);
            // check tags data
            tag = instance.tag(tagIds[i]);
            assertEq(uint256(tag.stage), uint256(tags[i].stage));
            assertEq(tag.merkleRoot, tags[i].merkleRoot);
            assertEq(tag.startAt, tags[i].startAt);
            assertEq(tag.endAt, tags[i].endAt);
            assertEq(tag.maxTagCap, tags[i].maxTagCap);
        }
    }

    function testRevert_setTags_If_maxTagCap_GreaterThan_grandTotal() public {
        tags[0].maxTagCap = grandTotal + 1;
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritable_GreaterThanGrandTotal.selector,
                tagIdentifiers[0],
                tags[0].maxTagCap,
                grandTotal
            )
        );
        instance.setTags(tagIdentifiers, tags);
    }

    function testRevert_setTags_If_tagIdentifiers_LengthNotEqualTo_tags()
        public
    {
        tagIdentifiers.pop();
        vm.expectRevert("IGOWritable: tags arrays length");
        instance.setTags(tagIdentifiers, tags);
    }

    function testRevert_setTags_If_tags_LengthNotEqualTo_tagIds() public {
        tags.pop();
        vm.expectRevert("IGOWritable: tags arrays length");
        instance.setTags(tagIdentifiers, tags);
    }

    /*//////////////////////////////////////////////////////////////
                                 UPDATE TAGS
    //////////////////////////////////////////////////////////////*/
    function test_updateTag() public {
        Tag memory tag = instance.tag(tagIdentifiers[0]);
        tag.stage = Stage.OPENED;
        tag.merkleRoot = bytes32("1");
        tag.startAt = 1;
        tag.endAt = 2;
        tag.maxTagCap = 3;

        instance.updateTag(tagIdentifiers[0], tag);

        Tag memory updatedTag = instance.tag(tagIdentifiers[0]);

        assertEq(uint256(updatedTag.stage), uint256(tag.stage));
        assertEq(updatedTag.merkleRoot, tag.merkleRoot);
        assertEq(updatedTag.startAt, tag.startAt);
        assertEq(updatedTag.endAt, tag.endAt);
        assertEq(updatedTag.maxTagCap, tag.maxTagCap);
    }

    function testRevert_updateTag_If_maxTagCap_GreaterThan_grandTotal()
        public
    {
        Tag memory tag = instance.tag(tagIdentifiers[0]);
        tag.maxTagCap = grandTotal + 1;
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritable_GreaterThanGrandTotal.selector,
                tagIdentifiers[0],
                tag.maxTagCap,
                grandTotal
            )
        );
        instance.updateTag(tagIdentifiers[0], tag);
    }
}
