// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

import {ISharedInternal} from "./shared/ISharedInternal.sol";

import {IGO} from "./IGO.sol";

contract IGOFactory is Ownable {
    string[] internal _igoNames;
    mapping(string => IGO) internal _igos;

    function createIGO(
        string memory igoName,
        address token,
        address permit2,
        address treasuryWallet,
        uint256 grandTotal_,
        string[] memory tagIds_,
        ISharedInternal.Tag[] memory tags
    ) external returns (IGO) {
        // require(
        //     owner() == _msgSender() || address(this) == _msgSender(),
        //     "Ownable: caller is not the owner"
        // );

        require(
            address(_igos[igoName]) == address(0),
            "IGOFactory: IGO already exists"
        );

        IGO igo = new IGO(
            owner(),
            token,
            permit2,
            treasuryWallet,
            grandTotal_,
            tagIds_,
            tags
        );

        _igoNames.push(igoName);
        _igos[igoName] = igo;

        return igo;
    }

    function igoWithName(string memory igoName) external view returns (IGO) {
        return _igos[igoName];
    }

    function igoCount() external view returns (uint256) {
        return _igoNames.length;
    }

    function igoNames() external view returns (string[] memory) {
        return _igoNames;
    }
}
