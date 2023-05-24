// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";

import "forge-std/Script.sol";

import {ISharedInternal} from "../../src/shared/ISharedInternal.sol";
import {IGO} from "../../src/IGO.sol";
import {IGOFactory} from "../../src/IGOFactory.sol";

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

        IGOFactory factory = new IGOFactory();

        ERC20 token = new ERC20("Mock", "MCK");
        //slither-disable-next-line unused-return
        factory.createIGO(
            "test",
            address(token),
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
