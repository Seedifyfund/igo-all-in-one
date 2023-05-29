// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/security/ReentrancyGuard.sol";

import {IIGOWritable} from "./writable/IIGOWritable.sol";
import {ISharedInternal} from "./shared/ISharedInternal.sol";

import {IGO} from "./IGO.sol";

/// @dev Contract to deploy IGOs one the fly, in one transaction
contract IGOFactory is Ownable, ReentrancyGuard {
    address public defaultIgo;
    string[] internal _igoNames;
    mapping(string => address) internal _igos;

    event DefaultIgoUpdated(address oldDefaultIgo, address newDefaultIgo);
    event IGOCreated(string indexed igoName, address indexed igo);

    constructor() {
        defaultIgo = address(new IGO());
    }

    function createIGO(
        string memory igoName,
        address token,
        address permit2,
        address treasuryWallet,
        uint256 grandTotal_,
        string[] memory tagIds_,
        ISharedInternal.Tag[] memory tags
    ) external nonReentrant onlyOwner returns (address igo) {
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

        _igoNames.push(igoName);
        _igos[igoName] = igo;

        IIGOWritable(igo).initialize(
            _msgSender(),
            token,
            permit2,
            treasuryWallet,
            grandTotal_,
            tagIds_,
            tags
        );

        emit IGOCreated(igoName, address(igo));
    }

    function igoWithName(
        string memory igoName
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
}
