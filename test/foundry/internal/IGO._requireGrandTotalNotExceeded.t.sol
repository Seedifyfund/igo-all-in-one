// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp_internal} from "./setUp/IGOSetUp_internal.t.sol";

contract IGO_Test__requireGrandTotalNotExceeded is IGOSetUp_internal {
    function testRevert_requireGrandTotalNotExceeded_If_GrandTotalExceeded()
        public
    {
        uint256 exceedsBy = 3_435_032;
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritable_GrandTotalExceeded.selector,
                grandTotal,
                exceedsBy
            )
        );
        instance.exposed_requireGrandTotalNotExceeded(
            grandTotal + exceedsBy,
            grandTotal
        );
    }

    function test_requireGrandTotalNotExceeded() public {
        assertTrue(
            instance.exposed_requireGrandTotalNotExceeded(
                grandTotal,
                grandTotal
            )
        );
    }
}
