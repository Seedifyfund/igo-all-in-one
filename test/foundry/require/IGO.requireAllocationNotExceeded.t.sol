// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp_require} from "./setUp/IGOSetUp_require.t.sol";

contract IGO_Test_requireAllocationNotExceededInTag is IGOSetUp_require {
    function testRevert_requireAllocationNotExceededInTag_If_AllocationExceeds()
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
        instance.exposed_requireAllocationNotExceededInTag(
            allocations[0].amount + exceedBy,
            allocations[0].account,
            allocations[0].amount,
            allocations[0].tagId
        );
    }

    function test_requireAllocationNotExceededInTag() public {
        assertTrue(
            instance.exposed_requireAllocationNotExceededInTag(
                allocations[0].amount / 4,
                allocations[0].account,
                allocations[0].amount,
                allocations[0].tagId
            )
        );
        assertTrue(
            instance.exposed_requireAllocationNotExceededInTag(
                allocations[0].amount,
                allocations[0].account,
                allocations[0].amount,
                allocations[0].tagId
            )
        );
    }
}
