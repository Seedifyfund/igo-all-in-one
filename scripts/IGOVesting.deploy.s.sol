// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOVesting} from "vesting-schedule/IGOVesting.sol";

import "forge-std/Script.sol";

/**
* @dev forge script IGOVesting_deploy \
        --rpc-url $BSC_RPC --broadcast \
        --verify --etherscan-api-key $BSC_KEY \
        -vvvv --optimize --optimizer-runs 20000 -w
*
* @dev If verification fails:
* forge verify-contract \
    --chain 97 \
    --num-of-optimizations 20000 \
    --compiler-version v0.8.17+commit.87f61d96 \
    --watch 0x7588Bc42f6d17621B96569a48a4FDb47367f00f4 \
    IGOVesting -e $BSC_KEY
*
* @dev VRFCoordinatorV2Interface: https://docs.chain.link/docs/vrf-contracts/
*/

contract IGOVesting_deploy is Script {
    function run() external {
        ///@dev Configure .env file
        string memory SEED = vm.envString("SEED");
        uint256 privateKey = vm.deriveKey(SEED, 0); // address at index 0
        vm.startBroadcast(privateKey);

        new IGOVesting();

        vm.stopBroadcast();
    }

    function test() public {}
}
