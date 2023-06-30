// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOVesting} from "vesting-schedule/IGOVesting.sol";

import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/security/ReentrancyGuard.sol";

import {IGO} from "./IGO.sol";

import {IGOStorage} from "./IGOStorage.sol";

/// @dev Contract to deploy IGOs one the fly, in one transaction
contract IGOFactory is Ownable, ReentrancyGuard {
    address public defaultIgo;
    address public defaultVesting;
    string[] internal _igoNames;
    mapping(string => address) internal _igos;

    event DefaultIgoUpdated(
        address indexed oldDefaultIgo,
        address indexed newDefaultIgo
    );
    event DefaultVestingUpdated(
        address indexed oldDefaultVesting,
        address indexed newDefaultVesting
    );
    event IGOCreated(
        string indexed igoName,
        address indexed igo,
        address indexed vesting
    );

    constructor() {
        defaultIgo = address(new IGO());
        defaultVesting = address(new IGOVesting());
    }

    function createIGO(
        string calldata igoName,
        IGOStorage.SetUp memory setUp,
        string[] calldata tagIds,
        IGO.Tag[] calldata tags,
        IGOVesting.ContractSetup calldata contractSetup,
        IGOVesting.VestingSetup calldata vestingSetup
    ) external nonReentrant onlyOwner returns (address igo, address vesting) {
        require(
            address(_igos[igoName]) == address(0),
            "IGOFactory: IGO already exists"
        );

        // slither-disable-next-line too-many-digits
        bytes memory bytecode = type(IGO).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_msgSender(), igoName));
        assembly {
            igo := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        // slither-disable-next-line too-many-digits
        bytecode = type(IGOVesting).creationCode;
        assembly {
            vesting := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        setUp.vestingContract = vesting;
        setUp.summedMaxTagCap = 0;
        setUp.refundFeeDecimals = contractSetup._decimals;

        _igoNames.push(igoName);
        _igos[igoName] = igo;

        IGO(igo).initialize(_msgSender(), setUp, tagIds, tags);
        IGOVesting(vesting).initializeCrowdfunding(
            contractSetup,
            vestingSetup
        );
        IGOVesting(vesting).transferOwnership(igo);

        emit IGOCreated(igoName, igo, vesting);
    }

    function igoWithName(
        string calldata igoName
    ) external view returns (address) {
        return _igos[igoName];
    }

    function igoCount() external view returns (uint256) {
        return _igoNames.length;
    }

    function igoNames() external view returns (string[] memory) {
        return _igoNames;
    }

    function updateDefaultIgo(address newDefaultIgo) external onlyOwner {
        require(
            newDefaultIgo != address(0),
            "IGOFactory__defaultIgo_ZERO_ADDRESS"
        );
        address oldDefaultIgo = defaultIgo;
        defaultIgo = newDefaultIgo;
        emit DefaultIgoUpdated(oldDefaultIgo, newDefaultIgo);
    }

    function updateDefaultVesting(
        address newDefaultVesting
    ) external onlyOwner {
        require(
            newDefaultVesting != address(0),
            "IGOFactory__defaultVesting_ZERO_ADDRESS"
        );
        address oldDefaultVesting = defaultVesting;
        defaultVesting = newDefaultVesting;
        emit DefaultVestingUpdated(oldDefaultVesting, newDefaultVesting);
    }
}
