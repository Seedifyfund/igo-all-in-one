// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import "../../src/IGO.sol";
import "../../src/writable/IIGOWritableInternal.sol";

contract IGO_Test is Test, IIGOWritableInternal {
    IGO public instance;

    uint256 public grandTotal = 50_000_000 ether;
    string[] public tagIdentifiers;
    Tag[] public tags;

    function setUp() public {
        instance = new IGO(grandTotal);

        tagIdentifiers.push("vpr-base");
        tagIdentifiers.push("vpr-premium1");
        tagIdentifiers.push("vpr-premium2");
        tagIdentifiers.push("igo-phase1");
        tagIdentifiers.push("igo-phase2");
        tagIdentifiers.push("igo-phase3");

        uint128 lastStart = 60;
        uint128 lastEnd = 1 hours;
        uint256 maxTagAllocation = 1_000_000 ether;

        for (uint256 i; i < tagIdentifiers.length; ++i) {
            maxTagAllocation = 1_000_000 ether * (i + 1);

            tags.push(
                Tag(
                    State.NOT_STARTED,
                    bytes32(0),
                    uint128(block.timestamp) + lastStart,
                    uint128(block.timestamp) + lastEnd,
                    maxTagAllocation
                )
            );

            lastStart = lastEnd;
            lastEnd += 1 hours;
        }

        instance.setTags(tagIdentifiers, tags);
    }

    function test_grandTotal() public {
        // check grandTotal set in constructor
        assertEq(instance.grandTotal(), grandTotal);

        instance.updateGrandTotal(1_000_000);
        assertEq(instance.grandTotal(), 1_000_000);

        vm.expectRevert("IGOWritable: grandTotal < 1_000");
        instance.updateGrandTotal(999);
    }

    /*//////////////////////////////////////////////////////////////
                                 SET TAGS
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

    function testRevert_setTags_If_tags_LengthNotEqualTo_tagIdentifiers()
        public
    {
        tags.pop();
        vm.expectRevert("IGOWritable: tags arrays length");
        instance.setTags(tagIdentifiers, tags);
    }
}
