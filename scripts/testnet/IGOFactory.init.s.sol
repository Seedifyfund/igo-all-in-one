// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOVesting} from "vesting-schedule/IGOVesting.sol";

import "forge-std/Script.sol";

import {IGO} from "../../src/IGO.sol";
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

        IGOFactory factory = IGOFactory(
            0x08b0F6490085d1E845024ee8fa2c4651D77e2E6f
        );

        factory.init(
            0xBc03b66e69806Fb86f45c10bcfEF2D7B30C31E00,
            type(IGO).creationCode,
            0x890E2c3Cd8F041dF1a6734fD9fCf3F4AefB31B31,
            type(IGOVesting).creationCode
        );

        vm.stopBroadcast();
    }

    function test() public {}
}
