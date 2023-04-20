// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";

import {IGO} from "../../src/IGO.sol";

import {ERC20_Mock} from "../../test/mock/ERC20_Mock.sol";

/**
* @dev forge script IGO_deploy_testnet \
        --rpc-url $BSC_RPC --broadcast \
        --verify --etherscan-api-key $BSC_KEY \
        -vvvv --optimize --optimizer-runs 20000 -w
*
* @dev If verification fails:
* forge verify-contract \
    --chain 97 \
    --num-of-optimizations 20000 \
    --compiler-version v0.8.17+commit.87f61d96 \
    --watch 0xb7DEBdA47C1014763188E69fc823B973eC1749D6 \
    IGO $BSC_KEY
*
* @dev VRFCoordinatorV2Interface: https://docs.chain.link/docs/vrf-contracts/
*/

contract IGO_deploy_testnet is Script {
    function run() external {
        ///@dev Configure .env file
        string memory SEED = vm.envString("SEED");
        uint256 privateKey = vm.deriveKey(SEED, 0); // address at index 0
        vm.startBroadcast(privateKey);

        ERC20_Mock token = new ERC20_Mock();
        IGO igo = new IGO(address(token), 1_000_000);

        vm.stopBroadcast();
    }
}
