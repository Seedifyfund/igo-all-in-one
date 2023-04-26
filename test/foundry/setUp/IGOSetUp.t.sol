// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Strings} from "openzeppelin-contracts/utils/Strings.sol";

import "forge-std/Test.sol";

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

import {IGO_Mock} from "../../mock/IGO_Mock.sol";
import {IIGOWritableInternal} from "../../../src/writable/IIGOWritableInternal.sol";

import {ERC20_Mock} from "../../mock/ERC20_Mock.sol";

import {FFI_Merkletreejs} from "../utils/FFI_Merkletreejs.sol";

contract IGOSetUp is Test, IIGOWritableInternal, FFI_Merkletreejs {
    ERC20_Mock public token;
    IGO_Mock public instance;

    address public treasuryWallet = makeAddr("treasuryWallet");

    uint256 public grandTotal = 50_000_000 ether;
    string[] public tagIdentifiers;
    Tag[] public tags;

    Allocation[] public allocations;

    function setUp() public virtual {
        token = new ERC20_Mock();
        instance = new IGO_Mock(
            address(token),
            treasuryWallet,
            grandTotal,
            new string[](0),
            new Tag[](0)
        );

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
                    maxTagAllocation
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

        // mint token to first account in allocations
        deal(
            address(token),
            allocations[0].account,
            allocations[0].amount + 100 ether
        );
    }

    function _setUpTestData() internal {
        _generateLeaves(allocations);
        _generateMerkleRootAndProofForLeaf(0);

        // update merkle root & stage
        tags[0].merkleRoot = merkleRoot;
        tags[0].stage = Stage.OPENED;
        tags[0].maxTagCap = allocations[0].amount;
        instance.updateTag(tagIdentifiers[0], tags[0]);

        instance.openIGO();
    }

    function _increaseMaxTagCapBy(uint256 by) internal {
        Tag memory tag_ = instance.tag(allocations[0].tagId);
        tag_.maxTagCap += by;
        instance.updateTag(allocations[0].tagId, tag_);
    }

    function _buyTokens(
        uint256 amount,
        Allocation memory allocation,
        bytes32[] memory proof
    ) internal {
        vm.startPrank(allocation.account);
        token.increaseAllowance(address(instance), allocation.amount);
        instance.buyTokens(amount, allocation, proof);
        vm.stopPrank();
    }

    function _buyTokens(
        Allocation memory allocation,
        bytes32[] memory proof
    ) internal {
        vm.startPrank(allocation.account);
        token.increaseAllowance(address(instance), allocation.amount);
        instance.buyTokens(allocation.amount, allocation, proof);
        vm.stopPrank();
    }
}
