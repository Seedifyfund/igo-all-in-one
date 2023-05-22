// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import {ISignatureTransfer} from "permit2/interfaces/ISignatureTransfer.sol";

import {PermitHash} from "permit2/libraries/PermitHash.sol";

import {Permit2} from "permit2/Permit2.sol";

contract PermitSignature is Test {
    Permit2 public permit2;
    uint256 public defaultSigDeadline = block.timestamp + 5 minutes;

    function setUp() public virtual {
        permit2 = new Permit2();
    }

    function _getPermitTransferSignature(
        ISignatureTransfer.PermitTransferFrom memory permit,
        address permitCaller,
        uint256 privateKey
    ) internal view returns (bytes memory sig) {
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
        address token,
        uint256 amount,
        uint256 nonce
    ) internal view returns (ISignatureTransfer.PermitTransferFrom memory) {
        return
            ISignatureTransfer.PermitTransferFrom({
                permitted: ISignatureTransfer.TokenPermissions({
                    token: token,
                    amount: amount
                }),
                nonce: nonce,
                deadline: defaultSigDeadline
            });
    }
}
