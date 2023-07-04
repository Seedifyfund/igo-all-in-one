pragma solidity ^0.8.17;

import "forge-std/Script.sol";

import {Token_Mock} from "../../test/mock/Token_Mock.sol";

/**
* @dev forge script Token_Mock_deploy_testnet \
        --rpc-url $BSC_RPC --broadcast \
        --verify --etherscan-api-key $BSC_KEY \
        -vvvv --optimize --optimizer-runs 20000 -w
*
* @dev If verification fails:
* forge verify-contract \
    --chain 97 \
    --num-of-optimizations 20000 \
    --compiler-version v0.8.17+commit.87f61d96 \
    --watch 0xad1b8650f8ef766046C00EBaC94E575343B5C797 \
    Token_Mock -e $BSC_KEY
*/

contract Token_Mock_deploy_testnet is Script {
    function run() external {
        string memory SEED = vm.envString("SEED");
        uint256 privateKey = vm.deriveKey(SEED, 0); // address at index 0
        vm.startBroadcast(privateKey);

        new Token_Mock();

        vm.stopBroadcast();
    }
}
