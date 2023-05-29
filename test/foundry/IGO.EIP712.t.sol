// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IERC1271} from "permit2/interfaces/IERC1271.sol";
import {ISignatureTransfer} from "permit2/interfaces/ISignatureTransfer.sol";

import {IGOSetUp} from "./setUp/IGOSetUp.t.sol";

contract IGO_EIP712_Test is IGOSetUp {
    address public buyer;
    uint256 public amount;
    uint256 public nonce;

    function setUp() public override {
        super.setUp();
        buyer = allocations[0].account;
        amount = allocations[0].amount;
        nonce = 12432523;
    }

    function test_recoverSigner() public {
        vm.startPrank(buyer);
        ISignatureTransfer.PermitTransferFrom memory permit;
        permit = _createPermit(address(token), amount, nonce);

        bytes32 msgHash = _msgHash(permit, address(this));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKeyOf[buyer],
            msgHash
        );

        address signer = ecrecover(msgHash, v, r, s);

        assertEq(signer, buyer, "different signer");
    }

    function test_permitTransferFrom() public {
        ISignatureTransfer.PermitTransferFrom memory permit;
        ISignatureTransfer.SignatureTransferDetails memory transferDetails;
        permit = _createPermit(address(token), amount, nonce);
        transferDetails = ISignatureTransfer.SignatureTransferDetails({
            to: treasuryWallet,
            requestedAmount: amount
        });

        bytes memory sig = _getPermitTransferSignature(
            permit,
            address(this),
            privateKeyOf[buyer]
        );

        permit2.permitTransferFrom(permit, transferDetails, buyer, sig);
    }
}
