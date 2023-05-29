// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";

import {IGO} from "../../../src/IGO.sol";
import {IGOFactory} from "../../../src/IGOFactory.sol";
import {IIGOWritableInternal} from "../../../src/writable/IIGOWritableInternal.sol";
import {IRestrictedWritableInternal} from "../../../src/writable/restricted/IRestrictedWritableInternal.sol";
import {ISharedInternal} from "../../../src/shared/ISharedInternal.sol";

import {FFI_Merkletreejs} from "../utils/FFI_Merkletreejs.sol";
import {PermitSignature} from "../utils/PermitSignature.sol";

contract IGOSetUp is
    Test,
    IIGOWritableInternal,
    IRestrictedWritableInternal,
    ISharedInternal,
    PermitSignature,
    FFI_Merkletreejs
{
    string public mnemonic =
        "test test test test test test test test test test test junk";

    mapping(address => uint256) public privateKeyOf;

    IGOFactory public factory;
    IGO public instance;
    ERC20 public token;

    address public treasuryWallet = makeAddr("treasuryWallet");

    uint256 public grandTotal = 50_000_000 ether;
    string[] public tagIdentifiers;
    Tag[] public tags;

    Allocation[] public allocations;
    BuyPermission public permission;

    function setUp() public virtual override {
        super.setUp();

        factory = new IGOFactory();

        token = new ERC20("Mock", "MCK");
        address addr = factory.createIGO(
            "test",
            address(token),
            address(permit2),
            treasuryWallet,
            grandTotal,
            new string[](0),
            new Tag[](0)
        );
        instance = IGO(addr);

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
        uint256 privateKey;
        address addr;
        for (uint256 i; i < 10; ++i) {
            privateKey = vm.deriveKey(mnemonic, uint32(i));
            addr = vm.addr(privateKey);
            privateKeyOf[addr] = privateKey;
            allocations.push(
                Allocation(
                    tagIdentifiers[i % tagIdentifiers.length],
                    addr,
                    1_000 ether
                )
            );
            vm.prank(addr);
            token.approve(address(permit2), type(uint256).max);
        }

        // mint token to first account in allocations
        deal(
            address(token),
            allocations[0].account,
            allocations[0].amount + 10_000 ether
        );
    }

    function _setUpTestData() internal {
        __setUpTestData(address(0));
    }

    function _setUpTestData(address token_) internal {
        __setUpTestData(token_);
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
        __buyTokens(address(token), amount, allocation, proof);
    }

    function _buyTokens(
        Allocation memory allocation,
        bytes32[] memory proof
    ) internal {
        __buyTokens(address(token), allocation.amount, allocation, proof);
    }

    function _buyTokensWithTagToken(
        address tagToken,
        Allocation memory allocation,
        bytes32[] memory proof
    ) internal {
        __buyTokens(tagToken, allocation.amount, allocation, proof);
    }

    function __buyTokens(
        address token_,
        uint256 amount,
        Allocation memory allocation,
        bytes32[] memory proof
    ) private {
        uint256 nonce = uint256(
            bytes32(keccak256(abi.encode(allocation, amount)))
        );
        // vm.startPrank(allocation.account);
        bytes memory sig = _getPermitTransferSignature(
            _createPermit(token_, amount, nonce),
            address(instance),
            privateKeyOf[allocation.account]
        );
        permission.signature = sig;
        permission.deadline = defaultSigDeadline;
        permission.nonce = nonce;

        vm.prank(allocation.account);
        instance.buyTokens(amount, allocation, proof, permission);
    }

    function __setUpTestData(address token_) private {
        _generateLeaves(allocations);
        _generateMerkleRootAndProofForLeaf(0);

        // update merkle root & stage
        tags[0].merkleRoot = merkleRoot;
        tags[0].stage = Stage.OPENED;
        tags[0].maxTagCap = allocations[0].amount;
        tags[0].paymentToken = token_;
        instance.updateTag(tagIdentifiers[0], tags[0]);

        instance.openIGO();
    }

    function test() public {}
}
