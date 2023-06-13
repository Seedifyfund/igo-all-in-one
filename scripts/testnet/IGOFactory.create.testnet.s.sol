// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";

import {ISharedInternal} from "../../src/shared/ISharedInternal.sol";
import {IGO} from "../../src/IGO.sol";
import {IGOFactory} from "../../src/IGOFactory.sol";

import {Token_Mock} from "../../test/mock/Token_Mock.sol";

/**
* @dev forge script IGOFactory_create_testnet \
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

contract IGOFactory_create_testnet is Script {
    function run() external {
        ///@dev Configure .env file
        string memory SEED = vm.envString("SEED");
        uint256 privateKey = vm.deriveKey(SEED, 0); // address at index 0
        vm.startBroadcast(privateKey);

        IGOFactory factory = IGOFactory(
            0x619BE601822B5e5DBD8afCB56431D6676CcA2734
        );

        //slither-disable-next-line unused-return
        factory.createIGO(
            "test",
            address(new Token_Mock()),
            0x000000000022D473030F116dDEE9F6B43aC78BA3, // bsc
            vm.addr(privateKey),
            1_000_000,
            new string[](0),
            new ISharedInternal.Tag[](0)
        );

        vm.stopBroadcast();
    }

    function test() public {}
}
