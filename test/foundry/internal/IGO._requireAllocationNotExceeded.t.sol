// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp_internal} from "./setUp/IGOSetUp_internal.t.sol";

contract IGO_Test__requireAllocationNotExceededInTag is IGOSetUp_internal {
    function testRevert_requireAllocationNotExceededInTag_If_AllocationExceeds()
        public
    {
        uint256 exceedBy = 1_000;

        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritable_AllocationExceeded.selector,
                allocations[0].maxAllocation,
                exceedBy
            )
        );
        instance.exposed_requireAllocationNotExceededInTag(
            allocations[0].maxAllocation + exceedBy,
            allocations[0].account,
            allocations[0].maxAllocation,
            allocations[0].tagId
        );
    }

    function test_requireAllocationNotExceededInTag() public {
        assertTrue(
            instance.exposed_requireAllocationNotExceededInTag(
                allocations[0].maxAllocation / 4,
                allocations[0].account,
                allocations[0].maxAllocation,
                allocations[0].tagId
            )
        );
        assertTrue(
            instance.exposed_requireAllocationNotExceededInTag(
                allocations[0].maxAllocation,
                allocations[0].account,
                allocations[0].maxAllocation,
                allocations[0].tagId
            )
        );
    }
}
