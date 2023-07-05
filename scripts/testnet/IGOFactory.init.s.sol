// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";

import {IGOFactory} from "../../src/IGOFactory.sol";

/**
* @dev forge script IGOFactory_init \
        --rpc-url $FMT_RPC --broadcast \
        --verify --etherscan-api-key $FMT_KEY \
        -vvvv --optimize --optimizer-runs 20000 -w
*/

contract IGOFactory_init is Script {
    function run() external {
        ///@dev Configure .env file
        string memory SEED = vm.envString("SEED");
        uint256 privateKey = vm.deriveKey(SEED, 0); // address at index 0
        vm.startBroadcast(privateKey);

        address factoryAddr = vm.envAddress("FACTORY");
        address igoAddr = vm.envAddress("IGO");
        address vestingAddr = vm.envAddress("VESTING");

        bytes memory igoCode = vm.envBytes("IGO_CODE");
        bytes memory vestingCode = vm.envBytes("VESTING_CODE");

        IGOFactory factory = IGOFactory(factoryAddr);

        factory.init(igoAddr, igoCode, vestingAddr, vestingCode);

        vm.stopBroadcast();
    }

    function test() public {}
}
