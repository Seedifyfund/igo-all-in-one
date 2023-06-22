// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";

import {IIGOVesting} from "igo-all-in-one/IIGOVesting.sol";

import {ISharedInternal} from "../../src/shared/ISharedInternal.sol";
import {IGO} from "../../src/IGO.sol";
import {IGOStorage} from "../../src/IGO.sol";
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

        IGOStorage.SetUp memory igoSetUp = IGOStorage.SetUp({
            vestingContract: address(0),
            paymentToken: address(new Token_Mock()),
            permit2: address(0x000000000022D473030F116dDEE9F6B43aC78BA3), // bsc
            grandTotal: 1_000_000,
            summedMaxTagCap: 0
        });

        IIGOVesting.ContractSetup memory contractSetup = IIGOVesting
            .ContractSetup({
                _innovator: address(0),
                _paymentReceiver: address(0),
                _vestedToken: address(0),
                _paymentToken: address(0),
                _tiers: address(0),
                _totalTokenOnSale: 0,
                _gracePeriod: 0
            });
        IIGOVesting.VestingSetup memory vestingSetup = IIGOVesting
            .VestingSetup({
                _startTime: 0,
                _cliff: 0,
                _duration: 0,
                _initialUnlockPercent: 0
            });

        //slither-disable-next-line unused-return
        factory.createIGO(
            "test",
            igoSetUp,
            new string[](0),
            new ISharedInternal.Tag[](0),
            contractSetup,
            vestingSetup
        );

        vm.stopBroadcast();
    }

    function test() public {}
}
