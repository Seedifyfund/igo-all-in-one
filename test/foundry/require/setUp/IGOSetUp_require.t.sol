// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Strings} from "openzeppelin-contracts/utils/Strings.sol";

import "forge-std/Test.sol";

import {IRestrictedWritableInternal} from "../../../../src/writable/restricted/IRestrictedWritableInternal.sol";
import {ISharedInternal} from "../../../../src/shared/ISharedInternal.sol";
import {IIGOWritableInternal} from "../../../../src/writable/IIGOWritableInternal.sol";

import {IGOWritable_Mock} from "../../../mock/IGOWritable_Mock.sol";
import {FFI_Merkletreejs} from "../../utils/FFI_Merkletreejs.sol";

contract IGOSetUp_require is
    Test,
    IRestrictedWritableInternal,
    ISharedInternal,
    IIGOWritableInternal,
    FFI_Merkletreejs
{
    IGOWritable_Mock public instance;

    address public treasuryWallet = makeAddr("treasuryWallet");
    uint256 public grandTotal = 50_000_000 ether;
    string[] public tagIdentifiers;
    Tag[] public tags;
    Allocation[] public allocations;

    function setUp() public virtual {
        instance = new IGOWritable_Mock();

        instance.updateGrandTotal(grandTotal);

        __createDefaultTags();
        instance.setTags(tagIdentifiers, tags);
        __createDefaultAllocations();
    }

    function __createDefaultTags() private {
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
                    Stage.NOT_STARTED,
                    bytes32(0),
                    uint128(block.timestamp) + lastStart,
                    uint128(block.timestamp) + lastEnd,
                    maxTagAllocation,
                    address(0)
                )
            );

            lastStart = lastEnd;
            lastEnd += 1 hours;
        }
    }

    function __createDefaultAllocations() private {
        for (uint256 i; i < 10; ++i) {
            allocations.push(
                Allocation(
                    tagIdentifiers[i % tagIdentifiers.length],
                    makeAddr(string.concat("address", Strings.toString(i))),
                    1_000 ether
                )
            );
        }
    }

    function test() public {}
}
