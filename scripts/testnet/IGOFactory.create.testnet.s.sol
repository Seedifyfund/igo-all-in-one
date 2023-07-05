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

        address mockedToken = 0xad1b8650f8ef766046C00EBaC94E575343B5C797;

        IGOFactory factory = IGOFactory(
            0x08b0F6490085d1E845024ee8fa2c4651D77e2E6f
        );

        IGOStorage.SetUp memory igoSetUp = IGOStorage.SetUp({
            vestingContract: 0x890E2c3Cd8F041dF1a6734fD9fCf3F4AefB31B31,
            paymentToken: mockedToken,
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
                _vestedToken: mockedToken,
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
