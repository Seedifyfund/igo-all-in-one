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

    function exposed_requireAllocationNotExceededInTag(
        uint256 toBuy,
        address rewardee,
        uint256 allocated,
        string calldata tagId
    ) external view returns (bool) {
        _requireAllocationNotExceededInTag(toBuy, rewardee, allocated, tagId);
        return true;
    }

    function exposed_requireAuthorizedAccount(
        address account
    ) external view returns (bool) {
        _requireAuthorizedAccount(account);
        return true;
    }

    function exposed_requireGrandTotalNotExceeded(
        uint256 toBuy,
        uint256 grandTotal
    ) external view returns (bool) {
        _requireGrandTotalNotExceeded(toBuy, grandTotal);
        return true;
    }

    function exposed_requireOpenedIGO() external view returns (bool) {
        _requireOpenedIGO();
        return true;
    }

    function exposed_requireOpenedTag(
        string memory tagId
    ) external view returns (bool) {
        _requireOpenedTag(tagId);
        return true;
    }

    function exposed_requireTagCapNotExceeded(
        string calldata tagId,
        uint256 maxTagCap,
        uint256 toBuy
    ) external view returns (bool) {
        _requireTagCapNotExceeded(tagId, maxTagCap, toBuy);
        return true;
    }

    function exposed_requireValidAllocation(
        Allocation calldata allocation,
        bytes32[] calldata proof
    ) external view returns (bool) {
        _requireValidAllocation(allocation, proof);
        return true;
    }
}
