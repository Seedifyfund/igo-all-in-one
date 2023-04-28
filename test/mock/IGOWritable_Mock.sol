// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOWritable} from "../../src/writable/IGOWritable.sol";
import {IGOReadable} from "../../src/readable/IGOReadable.sol";

contract IGOWritable_Mock is IGOWritable, IGOReadable {
    function exposed_closeIGO() external {
        _closeIGO();
    }

    function exposed_closeTag(string memory tagId) external {
        _closeTag(tagId);
    }

    function exposed_requireAllocationNotExceeded(
        uint256 toBuy,
        Allocation calldata allocation
    ) external view {
        _requireAllocationNotExceeded(toBuy, allocation);
    }

    function exposed_requireAuthorizedAccount(address account) external view {
        _requireAuthorizedAccount(account);
    }

    function exposed_requireGrandTotalNotExceeded(
        uint256 toBuy,
        uint256 grandTotal
    ) external view {
        _requireGrandTotalNotExceeded(toBuy, grandTotal);
    }

    function exposed_requireOpenedIGO() external view {
        _requireOpenedIGO();
    }

    function exposed_requireOpenedTag(string memory tagId) external view {
        _requireOpenedTag(tagId);
    }

    function exposed_requireTagCapNotExceeded(
        string calldata tagId,
        uint256 maxTagCap,
        uint256 toBuy
    ) external view {
        _requireTagCapNotExceeded(tagId, maxTagCap, toBuy);
    }

    function exposed_requireValidAllocation(
        Allocation calldata allocation,
        bytes32[] calldata proof
    ) external view {
        _requireValidAllocation(allocation, proof);
    }
}
