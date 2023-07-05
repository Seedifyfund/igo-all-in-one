// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";

import {IIGOVesting} from "vesting-schedule/interfaces/IIGOVesting.sol";

import {ISharedInternal} from "../../src/shared/ISharedInternal.sol";
import {IGOStorage} from "../../src/IGO.sol";
import {IGOFactory} from "../../src/IGOFactory.sol";

/**
* @dev forge script IGOFactory_create_testnet \
        --rpc-url $BSC_RPC --broadcast \
        --verify --etherscan-api-key $BSC_KEY \
        -vvvv --optimize --optimizer-runs 20000 -w
*/

contract IGOFactory_createIGO_testnet is Script, ISharedInternal {
    function run() external {
        ///@dev Configure .env file
        string memory SEED = vm.envString("SEED");
        uint256 privateKey = vm.deriveKey(SEED, 0); // address at index 0
        vm.startBroadcast(privateKey);

        address factoryAddr = vm.envAddress("FACTORY");
        address vesting = vm.envAddress("VESTING");
        address token = vm.envAddress("TOKEN");

        IGOFactory factory = IGOFactory(factoryAddr);

        IGOStorage.SetUp memory igoSetUp = IGOStorage.SetUp({
            vestingContract: vesting,
            paymentToken: token,
            permit2: 0x000000000022D473030F116dDEE9F6B43aC78BA3, // bsc
            grandTotal: 1_000_000,
            summedMaxTagCap: 0,
            refundFeeDecimals: 2
        });

        IIGOVesting.ContractSetup memory contractSetup = IIGOVesting
            .ContractSetup({
                _innovator: vm.addr(privateKey),
                _paymentReceiver: vm.addr(privateKey),
                _admin: vm.addr(privateKey),
                _vestedToken: token,
                _platformFee: 0,
                _totalTokenOnSale: 0,
                _gracePeriod: 0,
                _decimals: 2
            });
        IIGOVesting.VestingSetup memory vestingSetup = IIGOVesting
            .VestingSetup({
                _startTime: 0,
                _cliff: 0,
                _duration: 0,
                _initialUnlockPercent: 0
            });

        string memory name = "test-00";

        //slither-disable-next-line unused-return
        factory.createIGO(
            name,
            igoSetUp,
            new string[](1),
            new Tag[](1),
            contractSetup,
            vestingSetup
        );

        vm.stopBroadcast();
    }

    function test() public {}
}
