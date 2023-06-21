// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp_internal} from "./setUp/IGOSetUp_internal.t.sol";

import {ISharedInternal} from "../../../src/shared/ISharedInternal.sol";

contract IGO_Test__isSummedMaxTagCapLteGrandTotal is IGOSetUp_internal {
    function testRevert__isSummedMaxTagCapLteGrandTotal_When_SummedMaxTagCap_ExceedsBy_ONE()
        public
    {
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritable_SummedMaxTagCapGtGrandTotal.selector,
                grandTotal + 1,
                grandTotal
            )
        );
        instance.exposed__isSummedMaxTagCapLteGrandTotal(
            grandTotal + 1,
            grandTotal
        );
    }

    function test__isSummedMaxTagCapLteGrandTotal() public {
        assertTrue(
            instance.exposed__isSummedMaxTagCapLteGrandTotal(
                0 ether,
                grandTotal
            )
        );
        assertTrue(
            instance.exposed__isSummedMaxTagCapLteGrandTotal(
                grandTotal / 2,
                grandTotal
            )
        );
    }
}
