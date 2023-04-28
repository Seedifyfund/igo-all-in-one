// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp_require} from "./setUp/IGOSetUp_require.t.sol";

contract IGO_Test_requireAllocationNotExceeded is IGOSetUp_require {
    function testRevert_requireAllocationNotExceeded_If_AllocationExceeds()
        public
    {
        uint256 exceedBy = 1_000;

        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritable_AllocationExceeded.selector,
                allocations[0].amount,
                exceedBy
            )
        );
        instance.exposed_requireAllocationNotExceeded(
            allocations[0].amount + exceedBy,
            allocations[0]
        );
    }

    function test_requireAllocationNotExceeded() public {
        assertTrue(
            instance.exposed_requireAllocationNotExceeded(
                allocations[0].amount / 4,
                allocations[0]
            )
        );
        assertTrue(
            instance.exposed_requireAllocationNotExceeded(
                allocations[0].amount,
                allocations[0]
            )
        );
    }
}
