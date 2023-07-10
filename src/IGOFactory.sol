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

    IGODetail[] internal _igoDetails;
    mapping(string => address) internal _igoNames;

    address public defaultVesting;
    bytes public vestingCreationCode;

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
            address(_igoNames[igoName]) == address(0),
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

        _igoNames[igoName] = igo;
        _igoDetails.push(IGODetail(igoName, igo, vesting, setUp));

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
    )
        external
        view
        returns (
            IGODetail[] memory igos,
            uint256 lastEvaludatedIndex,
            uint256 totalItems
        )
    {
        require(from <= to, "IGOFactory_INDEXES_REVERSED");

        if (to > _igoDetails.length) to = _igoDetails.length;

        unchecked {
            igos = new IGODetail[](to - from);
            for (uint256 i = from; i < to; ++i) {
                igos[i - from] = _igoDetails[i];
            }
        }

        lastEvaludatedIndex = to;
        totalItems = _igoDetails.length;
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
