// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import {IIGOVesting} from "vesting-schedule/interfaces/IIGOVesting.sol";
import {IGOVesting} from "vesting-schedule/IGOVesting.sol";

import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";

import {ISharedInternal} from "../../src/shared/ISharedInternal.sol";

import {IGO} from "../../src/IGO.sol";
import {IGOStorage} from "../../src/IGOStorage.sol";
import {IGOFactory} from "../../src/IGOFactory.sol";

contract IGOFactory_test is Test, ISharedInternal {
    // permit2 from bsc testnet
    address public permit2Addr = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    IGOFactory public factory;
    IGO public instance;
    ERC20 public token;
    IGOStorage.SetUp public igoSetUp;
    IIGOVesting.ContractSetup public contractSetup;
    IIGOVesting.VestingSetup public vestingSetup;

    address public vestingContract;

    uint256 public grandTotal = 50_000_000 ether;

    function setUp() public {
        factory = new IGOFactory();
        factory.init(
            address(new IGO()),
            type(IGO).creationCode,
            address(new IGOVesting()),
            type(IGOVesting).creationCode
        );

        token = new ERC20("Mock", "MCK");

        igoSetUp = IGOStorage.SetUp(
            address(0),
            address(token),
            permit2Addr,
            grandTotal,
            0,
            0
        );
        contractSetup = IIGOVesting.ContractSetup({
            _innovator: address(0),
            _paymentReceiver: address(0),
            _admin: address(0),
            _vestedToken: address(0),
            _platformFee: 0,
            _totalTokenOnSale: 0,
            _gracePeriod: 0,
            _decimals: 2
        });
        vestingSetup = IIGOVesting.VestingSetup(0, 0, 0, 0);

        address addr;
        (addr, vestingContract) = factory.createIGO(
            "test",
            igoSetUp,
            new string[](0),
            new Tag[](0),
            contractSetup,
            vestingSetup
        );
        instance = IGO(addr);
    }

    /// @dev Check variables have updated accordingly
    function test_igoFactory() public {
        assertEq(address(instance), address(factory.igoWithName("test")));
        assertEq(factory.igoCount(), 1);
        assertEq(factory.igoNames()[0], "test");
        // string[] memory names = factory.igoNames();
    }

    function test_createIGO_CheckOwnerOf_FactoryAndDeployedIGO() public {
        assertEq(instance.owner(), factory.owner());
        assertEq(instance.owner(), address(this));
    }

    function testRevert_createIGO_If_SenderIsNotOwner() public {
        // only owner can create a new IGO
        address someone = makeAddr("someone");
        vm.startPrank(someone);
        vm.expectRevert("Ownable: caller is not the owner");
        factory.createIGO(
            "someone-test",
            igoSetUp,
            new string[](0),
            new Tag[](0),
            contractSetup,
            vestingSetup
        );
    }

    function testRevert_createIGO_If_SameName() public {
        vm.expectRevert("IGOFactory: IGO already exists");
        factory.createIGO(
            "test",
            igoSetUp,
            new string[](0),
            new Tag[](0),
            contractSetup,
            vestingSetup
        );
    }
}
