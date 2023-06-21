// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp_internal} from "./setUp/IGOSetUp_internal.t.sol";

contract IGO_Test__requireTagCapNotExceeded is IGOSetUp_internal {
    function testRevert_requireTagCapNotExceeded_If_MaxTagCapExceeded()
        public
    {
        uint256 exceedsBy = 1;
        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritable_MaxTagCapExceeded.selector,
                tagIdentifiers[0],
                tags[0].maxTagCap,
                exceedsBy
            )
        );
        instance.exposed_requireTagCapNotExceeded(
            tagIdentifiers[0],
            tags[0].maxTagCap,
            tags[0].maxTagCap + exceedsBy
        );
    }

    function test_requireTagCapNotExceeded() public {
        assertTrue(
            instance.exposed_requireTagCapNotExceeded(
                tagIdentifiers[0],
                tags[0].maxTagCap,
                tags[0].maxTagCap
            )
        );
    }
}
