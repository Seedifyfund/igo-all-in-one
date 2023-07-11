// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import {Strings} from "openzeppelin-contracts/utils/Strings.sol";

import {IGOFactory} from "../../src/IGOFactory.sol";
import {IGOStorage} from "../../src/IGOStorage.sol";

contract IGOFactory_Mock is IGOFactory {
    function setIgoDetails(IGODetail[] memory igoDetails_) public {
        _igoDetails = igoDetails_;
    }
}

contract IGOFactory_getIgosDetails_test is Test {
    IGOFactory_Mock public factory;

    address public paymentToken = makeAddr("paymentToken");
    address public permit2 = makeAddr("permit2");

    uint256 public totalItems = 500;
    uint256 public maxLoop;

    function setUp() public {
        factory = new IGOFactory_Mock();
        factory.setIgoDetails(_generateIgoDetails(totalItems));
    }

    //////////////// DEFAULT LOOP ////////////////
    function test_getIgosDetails_100_Results_default() public {
        (, uint256 lastEvaludatedIndex, uint256 totalItems_) = factory
            .getIgosDetails(0, totalItems);

        assertEq(lastEvaludatedIndex, factory.maxLoop() - 1);
        assertEq(totalItems_, totalItems);
    }

    function test_getIgosDetails_From_50_to_149() public {
        uint256 from = 50;

        (, uint256 lastEvaludatedIndex, uint256 totalItems_) = factory
            .getIgosDetails(from, totalItems);

        assertEq(lastEvaludatedIndex, (from + factory.maxLoop()) - 1);
        assertEq(totalItems_, totalItems);
    }

    //////////////// GAS TESTS ////////////////
    function test_getIgosDetails_5_Results() public {
        maxLoop = 5;
        factory.setMaxLoop(maxLoop);

        (, uint256 lastEvaludatedIndex, uint256 totalItems_) = factory
            .getIgosDetails(0, totalItems);

        assertEq(lastEvaludatedIndex, --maxLoop);
        assertEq(totalItems_, totalItems);
    }

    function test_getIgosDetails_200_Results() public {
        maxLoop = 200;
        factory.setMaxLoop(maxLoop);

        (, uint256 lastEvaludatedIndex, uint256 totalItems_) = factory
            .getIgosDetails(0, totalItems);

        assertEq(lastEvaludatedIndex, --maxLoop);
        assertEq(totalItems_, totalItems);
    }

    function test_getIgosDetails_500_Results() public {
        maxLoop = 500;
        factory.setMaxLoop(maxLoop);

        (, uint256 lastEvaludatedIndex, uint256 totalItems_) = factory
            .getIgosDetails(0, totalItems);

        assertEq(lastEvaludatedIndex, --maxLoop);
        assertEq(totalItems_, totalItems);
    }

    function _generateIgoDetails(
        uint256 amount
    ) internal returns (IGOFactory.IGODetail[] memory generatedIgoDetails) {
        generatedIgoDetails = new IGOFactory.IGODetail[](amount);
        address igo;
        address vesting;

        for (uint256 i = 0; i < amount; i++) {
            igo = makeAddr(string.concat("igo", Strings.toString(i)));
            vesting = makeAddr(string.concat("vesting", Strings.toString(i)));

            generatedIgoDetails[i] = IGOFactory.IGODetail(
                string.concat("name-", Strings.toString(i)),
                igo,
                vesting,
                IGOStorage.SetUp(
                    vesting,
                    paymentToken,
                    permit2,
                    10_000_000 ether,
                    0 ether,
                    2
                )
            );
        }
    }
}
