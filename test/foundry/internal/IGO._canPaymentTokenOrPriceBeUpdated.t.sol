// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp_internal} from "./setUp/IGOSetUp_internal.t.sol";

import {ISharedInternal} from "../../../src/shared/ISharedInternal.sol";

contract IGO_Test__canPaymentTokenOrPriceBeUpdated is IGOSetUp_internal {
    function testRevert__canPaymentTokenOrPriceBeUpdated_If_PriceZERO()
        public
    {
        vm.expectRevert(
            abi.encodeWithSelector(IGOWritable_ProjectTokenPrice_ZERO.selector)
        );
        instance.exposed_canPaymentTokenOrPriceBeUpdated(
            Status.NOT_STARTED,
            address(0),
            address(0),
            10,
            0 ether
        );
    }

    function testRevert__canPaymentTokenOrPriceBeUpdated_If_IGOLaterStage_TryUpdateTokenOrPrice()
        public
    {
        // try update token
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritable_NoPaymentTokenOrPriceUpdate.selector
            )
        );
        instance.exposed_canPaymentTokenOrPriceBeUpdated(
            Status.PAUSED,
            address(bytes20("token")),
            address(bytes20("try-update-token")),
            10 ether,
            10 ether
        );
        // try update price
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritable_NoPaymentTokenOrPriceUpdate.selector
            )
        );
        instance.exposed_canPaymentTokenOrPriceBeUpdated(
            Status.OPENED,
            address(0),
            address(0),
            10,
            0 ether
        );
        // try update token and price
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritable_NoPaymentTokenOrPriceUpdate.selector
            )
        );
        instance.exposed_canPaymentTokenOrPriceBeUpdated(
            Status.PAUSED,
            address(bytes20("token")),
            address(bytes20("try-update-token")),
            10 ether,
            89786743 ether
        );
    }

    function test__canPaymentTokenOrPriceBeUpdated_IGO_NOT_STARTED() public {
        // only price updtae
        assertTrue(
            instance.exposed_canPaymentTokenOrPriceBeUpdated(
                Status.NOT_STARTED,
                address(0),
                address(0),
                0,
                1 ether
            )
        );
        // only token update
        assertTrue(
            instance.exposed_canPaymentTokenOrPriceBeUpdated(
                Status.NOT_STARTED,
                address(0),
                address(bytes20("token")),
                1 ether,
                1 ether
            )
        );
        // update token & price
        assertTrue(
            instance.exposed_canPaymentTokenOrPriceBeUpdated(
                Status.NOT_STARTED,
                address(bytes20("token")),
                address(bytes20("token-update")),
                1 ether,
                1329 ether
            )
        );
    }

    function test__canPaymentTokenOrPriceBeUpdated_IGO_LaterStage() public {
        assertTrue(
            instance.exposed_canPaymentTokenOrPriceBeUpdated(
                Status.OPENED,
                address(bytes20("token-update")),
                address(bytes20("token-update")),
                12378 ether,
                12378 ether
            )
        );

        assertTrue(
            instance.exposed_canPaymentTokenOrPriceBeUpdated(
                Status.PAUSED,
                address(bytes20("token-update")),
                address(bytes20("token-update")),
                12378 ether,
                12378 ether
            )
        );
    }
}
