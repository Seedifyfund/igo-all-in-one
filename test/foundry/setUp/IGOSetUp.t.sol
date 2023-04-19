// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import {IGO} from "../../../src/IGO.sol";
import {IIGOWritableInternal} from "../../../src/writable/IIGOWritableInternal.sol";

contract IGOSetUp is Test, IIGOWritableInternal {
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
}
