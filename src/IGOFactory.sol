// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IIGOVesting} from "vesting-schedule/interfaces/IIGOVesting.sol";
import {IIGOWritable} from "./writable/IIGOWritable.sol";
import {ISharedInternal} from "./shared/ISharedInternal.sol";

import {Initializable} from "openzeppelin-contracts/proxy/utils/Initializable.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/security/ReentrancyGuard.sol";

import {IGOStorage} from "./IGOStorage.sol";

/// @dev Contract to deploy IGOs one the fly, in one transaction
contract IGOFactory is Initializable, Ownable, ReentrancyGuard {
    address public defaultIgo;
    bytes public igoCreationCode;
    address public defaultVesting;
    bytes public vestingCreationCode;
    string[] internal _igoNames;
    mapping(string => address) internal _igos;

    event DefaultIgoUpdated(
        address indexed oldDefaultIgo,
        bytes oldIgoCreationCode,
        address indexed newDefaultIgo,
        bytes indexed newIgoCreationCode
    );
    event DefaultVestingUpdated(
        address indexed oldDefaultVesting,
        bytes oldVestingCreationCode,
        address indexed newDefaultVesting,
        bytes indexed newVestingCreationCode
    );
    event IGOCreated(
        string indexed igoName,
        address indexed igo,
        address indexed vesting
    );

    function init(
        address igo_,
        bytes memory igoCreationCode_,
        address vesting_,
        bytes memory vestingCreationCode_
    ) external initializer onlyOwner {
        defaultIgo = igo_;
        igoCreationCode = igoCreationCode_;
        defaultVesting = vesting_;
        vestingCreationCode = vestingCreationCode_;
    }

    function createIGO(
        string calldata igoName,
        IGOStorage.SetUp memory setUp,
        string[] calldata tagIds,
        ISharedInternal.Tag[] calldata tags,
        IIGOVesting.ContractSetup calldata contractSetup,
        IIGOVesting.VestingSetup calldata vestingSetup
    ) external nonReentrant onlyOwner returns (address igo, address vesting) {
        require(
            address(_igos[igoName]) == address(0),
            "IGOFactory: IGO already exists"
        );

        bytes32 salt = keccak256(abi.encodePacked(_msgSender(), igoName));

        bytes memory code = igoCreationCode;
        assembly {
            igo := create2(0, add(code, 32), mload(code), salt)
        }

        code = vestingCreationCode;
        assembly {
            vesting := create2(0, add(code, 32), mload(code), salt)
        }

        setUp.vestingContract = vesting;
        setUp.summedMaxTagCap = 0;
        setUp.refundFeeDecimals = contractSetup._decimals;

        _igoNames.push(igoName);
        _igos[igoName] = igo;

        IIGOWritable(igo).initialize(_msgSender(), setUp, tagIds, tags);
        IIGOVesting(vesting).initializeCrowdfunding(
            contractSetup,
            vestingSetup
        );
        IIGOVesting(vesting).transferOwnership(igo);

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

    function updateDefaultIgo(
        address newDefaultIgo,
        bytes memory newIgoCreationCode
    ) external onlyOwner {
        require(
            newDefaultIgo != address(0),
            "IGOFactory__defaultIgo_ZERO_ADDRESS"
        );
        require(
            newIgoCreationCode.length > 0,
            "IGOFactory__defaultIgo_ZERO_CODE"
        );
        emit DefaultIgoUpdated(
            defaultIgo,
            igoCreationCode,
            newDefaultIgo,
            newIgoCreationCode
        );
        defaultIgo = newDefaultIgo;
        igoCreationCode = newIgoCreationCode;
    }

    function updateDefaultVesting(
        address newDefaultVesting,
        bytes memory newVestingCreationCode
    ) external onlyOwner {
        require(
            newDefaultVesting != address(0),
            "IGOFactory__defaultVesting_ZERO_ADDRESS"
        );
        require(
            newVestingCreationCode.length > 0,
            "IGOFactory__defaultVesting_ZERO_CODE"
        );
        emit DefaultVestingUpdated(
            defaultVesting,
            vestingCreationCode,
            newDefaultVesting,
            newVestingCreationCode
        );
        defaultVesting = newDefaultVesting;
        vestingCreationCode = newVestingCreationCode;
    }
}
