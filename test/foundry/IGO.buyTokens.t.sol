// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp} from "./setUp/IGOSetUp.t.sol";

contract IGO_Test_buyTokens is IGOSetUp {
    /*//////////////////////////////////////////////////////////////
                                 REVERT
    //////////////////////////////////////////////////////////////*/
    function testRevert_buyTokens_If_NotOpened() public {
        bytes32[] memory proof = new bytes32[](10);

        vm.expectRevert(
            abi.encodeWithSelector(
                IGOWritable_NotOpened.selector,
                tagIdentifiers[0],
                State.NOT_STARTED
            )
        );
        instance.buyTokens(tagIdentifiers[0], 1_000_000 ether, proof);
    }
}
