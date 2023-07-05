// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";

import {IGOFactory} from "../../src/IGOFactory.sol";

/**
* @dev forge script IGOFactory_updateDefaultVesting \
        --rpc-url $FMT_RPC --broadcast \
        -vvvv --optimize --optimizer-runs 20000 -w
*/

contract IGOFactory_updateDefaultVesting is Script {
    function run() external {
        ///@dev Configure .env file
        string memory SEED = vm.envString("SEED");
        uint256 privateKey = vm.deriveKey(SEED, 0); // address at index 0
        vm.startBroadcast(privateKey);

        address factoryAddr = vm.envAddress("FACTORY");
        address vestingAddr = vm.envAddress("VESTING");

        bytes memory vestingCode = vm.envBytes("VESTING_CODE");

        IGOFactory factory = IGOFactory(factoryAddr);

        factory.updateDefaultVesting(vestingAddr, vestingCode);

        vm.stopBroadcast();
    }

    function test() public {}
}
