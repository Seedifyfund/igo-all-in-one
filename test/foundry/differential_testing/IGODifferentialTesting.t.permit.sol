// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ISignatureTransfer} from "permit2/interfaces/ISignatureTransfer.sol";

import {Strings2} from "murky/differential_testing/test/utils/Strings2.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";

import "forge-std/Test.sol";

import {IIGOWritableInternal} from "../../../src/writable/IIGOWritableInternal.sol";

import {PermitSignature} from "../utils/PermitSignature.sol";

contract IGO_DifferentialTesting_permit is
    Test,
    IIGOWritableInternal,
    PermitSignature
{
    string public SEED = vm.envString("SEED");

    function setUp() public override {
        super.setUp();
    }

    function testDifferential_permitTransferFrom_CompareJSToSolidity() public {
        uint256 privateKey = vm.deriveKey(SEED, 0);
        // address addr = vm.addr(privateKey);

        ISignatureTransfer.PermitTransferFrom memory permit = _createPermit(
            address(makeAddr("token")),
            1243,
            defaultSigDeadline
        );

        bytes memory sig = _getPermitTransferSignature(
            permit,
            address(this),
            privateKey
        );

        bytes memory packedPermitTransferFrom = abi.encode(permit);
        // emit log_named_bytes("packed", packedPermitTransferFrom);

        string[] memory cmd = new string[](6);
        cmd[0] = "node";
        cmd[
            1
        ] = "test/foundry/differential_testing/permit2.permitTransferFrom.t.js";
        cmd[2] = Strings.toHexString(block.chainid);
        cmd[3] = Strings.toHexString(address(permit2));
        cmd[4] = Strings.toHexString(address(this));
        cmd[5] = Strings2.toHexString(packedPermitTransferFrom);
        bytes memory res = vm.ffi(cmd);
        // emit log_named_bytes("res", res);

        assertEq(res, sig, "js sig does not match solidity sig");
    }
}
