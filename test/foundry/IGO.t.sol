// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import "../../src/IGO.sol";

contract IGO_Test is Test {
    IGO public instance;

    function setUp() public {
        instance = new IGO();
    }

    /*//////////////////////////////////////////////////////////////
                                 BASIC ATTRIBUTES
    //////////////////////////////////////////////////////////////*/
    function test_truthy() public {
        assertTrue(true);
    }
}
