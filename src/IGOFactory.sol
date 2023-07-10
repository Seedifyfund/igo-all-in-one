// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IIGOVesting} from "vesting-schedule/interfaces/IIGOVesting.sol";
import {IGO} from "./IGO.sol";
import {ISharedInternal} from "./shared/ISharedInternal.sol";

import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/security/ReentrancyGuard.sol";

import {IGOStorage} from "./IGOStorage.sol";

/// @dev Contract to deploy IGOs one the fly, in one transaction
contract IGOFactory is Ownable, ReentrancyGuard {
    struct IGODetail {
        string name;
        address igo;
        address vesting;
        IGOStorage.SetUp setUp;
    }

    IGODetail[] public igoDetails;

    address public defaultVesting;
    bytes public vestingCreationCode;
    string[] internal _igoNames;
    mapping(string => address) internal _igos;

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

        igo = address(new IGO());

        bytes memory code = vestingCreationCode;
        assembly {
            vesting := create2(0, add(code, 32), mload(code), salt)
        }

        setUp.vestingContract = vesting;
        setUp.summedMaxTagCap = 0;
        setUp.refundFeeDecimals = contractSetup._decimals;

        _igoNames.push(igoName);
        _igos[igoName] = igo;
        igoDetails.push(IGODetail(igoName, igo, vesting, setUp));

        IGO(igo).initialize(_msgSender(), setUp, tagIds, tags);
        IIGOVesting(vesting).initializeCrowdfunding(
            contractSetup,
            vestingSetup
        );
        IIGOVesting(vesting).transferOwnership(igo);

        emit IGOCreated(igoName, igo, vesting);
    }

    function getIgosDetails(
        uint256 from,
        uint256 to
    ) external view returns (IGO[] memory igos, uint256 lastEvaludatedIndex) {
        require(from < to, "IGOFactory_INDEXES_REVERSED");
        require(to <= igoDetails.length, "IGOFactory_OUT_OF_BOUNDS");

        igos = new IGO[](to - from);
        for (uint256 i = from; i < to; ++i) {
            igos[i - from] = IGO(igoDetails[i].igo);
        }

        lastEvaludatedIndex = to;
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
