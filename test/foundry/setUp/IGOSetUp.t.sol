// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {ISignatureTransfer} from "permit2/interfaces/ISignatureTransfer.sol";

import {PermitHash} from "permit2/libraries/PermitHash.sol";

import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";
import {Permit2} from "permit2/Permit2.sol";

import {IGO} from "../../../src/IGO.sol";
import {IIGOWritableInternal} from "../../../src/writable/IIGOWritableInternal.sol";
import {IRestrictedWritableInternal} from "../../../src/writable/restricted/IRestrictedWritableInternal.sol";
import {ISharedInternal} from "../../../src/shared/ISharedInternal.sol";

import {FFI_Merkletreejs} from "../utils/FFI_Merkletreejs.sol";

contract IGOSetUp is
    Test,
    IIGOWritableInternal,
    IRestrictedWritableInternal,
    ISharedInternal,
    FFI_Merkletreejs
{
    string public mnemonic =
        "test test test test test test test test test test test junk";

    mapping(address => uint256) public privateKeyOf;

    ERC20 public token;
    IGO public instance;
    Permit2 public permit2;

    address public treasuryWallet = makeAddr("treasuryWallet");

    uint256 public grandTotal = 50_000_000 ether;
    uint256 public defaultSigDeadline = block.timestamp + 5 minutes;
    string[] public tagIdentifiers;
    Tag[] public tags;

    Allocation[] public allocations;
    BuyPermission public permission;

    function setUp() public virtual {
        permit2 = new Permit2();
        token = new ERC20("Mock", "MCK");
        instance = new IGO(
            address(token),
            address(permit2),
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
        uint256 nonce = uint256(
            bytes32(keccak256(abi.encode(allocation, amount)))
        );
        // vm.startPrank(allocation.account);
        bytes memory sig = _getPermitTransferSignature(
            _createPermit(amount, nonce),
            address(instance),
            privateKeyOf[allocation.account]
        );
        permission.signature = sig;
        permission.deadline = defaultSigDeadline;
        permission.nonce = nonce;

        vm.prank(allocation.account);
        instance.buyTokens(amount, allocation, proof, permission);
        // vm.stopPrank();
    }

    function _buyTokens(
        Allocation memory allocation,
        bytes32[] memory proof
    ) internal {
        uint256 nonce = uint256(bytes32(keccak256(abi.encode(allocation))));
        // vm.startPrank(allocation.account);
        bytes memory sig = _getPermitTransferSignature(
            _createPermit(allocation.amount, nonce),
            address(instance),
            privateKeyOf[allocation.account]
        );
        permission.signature = sig;
        permission.deadline = defaultSigDeadline;
        permission.nonce = nonce;

        vm.prank(allocation.account);
        instance.buyTokens(allocation.amount, allocation, proof, permission);
        // vm.stopPrank();
    }

    function _getPermitTransferSignature(
        ISignatureTransfer.PermitTransferFrom memory permit,
        address permitCaller,
        uint256 privateKey
    ) internal returns (bytes memory sig) {
        bytes32 msgHash = _msgHash(permit, permitCaller);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);
        return bytes.concat(r, s, bytes1(v));
    }

    function _msgHash(
        ISignatureTransfer.PermitTransferFrom memory permit,
        address permitCaller
    ) internal view returns (bytes32) {
        bytes32 tokenPermissionsHash = keccak256(
            abi.encode(
                PermitHash._TOKEN_PERMISSIONS_TYPEHASH,
                permit.permitted
            )
        );

        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    permit2.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            PermitHash._PERMIT_TRANSFER_FROM_TYPEHASH,
                            tokenPermissionsHash,
                            permitCaller,
                            permit.nonce,
                            permit.deadline
                        )
                    )
                )
            );
    }

    function _createPermit(
        uint256 amount,
        uint256 nonce
    ) internal view returns (ISignatureTransfer.PermitTransferFrom memory) {
        return
            ISignatureTransfer.PermitTransferFrom({
                permitted: ISignatureTransfer.TokenPermissions({
                    token: address(token),
                    amount: amount
                }),
                nonce: nonce,
                deadline: defaultSigDeadline
            });
    }

    function test() public {}
}
