// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp_require} from "./setUp/IGOSetUp_require.t.sol";

contract IGO_Test_requireGrandTotalNotExceeded is IGOSetUp_require {
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
