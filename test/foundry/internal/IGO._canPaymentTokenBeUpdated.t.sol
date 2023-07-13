// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp_internal} from "./setUp/IGOSetUp_internal.t.sol";

import {ISharedInternal} from "../../../src/shared/ISharedInternal.sol";

contract IGO_Test__canPaymentTokenBeUpdated is IGOSetUp_internal {
    function testRevert__canPaymentTokenBeUpdated_If_IGOLaterStage() public {
        vm.expectRevert(
            abi.encodeWithSelector(IGOWritable_NoPaymentTokenUpdate.selector)
        );
        instance.exposed_canPaymentTokenBeUpdated(
            Status.PAUSED,
            address(bytes20("token")),
            address(bytes20("try-update-token"))
        );
    }

    function test__canPaymentTokenBeUpdated_IGO_NOT_STARTED() public {
        assertTrue(
            instance.exposed_canPaymentTokenBeUpdated(
                Status.NOT_STARTED,
                address(0),
                address(bytes20("token"))
            )
        );
    }

    function test__canPaymentTokenBeUpdated_IGO_LaterStage() public {
        assertTrue(
            instance.exposed_canPaymentTokenBeUpdated(
                Status.OPENED,
                address(bytes20("token-update")),
                address(bytes20("token-update"))
            )
        );
    }
}
