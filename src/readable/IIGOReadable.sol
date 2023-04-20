// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IIGOWritableInternal} from "../writable/IIGOWritableInternal.sol";

interface IIGOReadable {
    function grandTotal() external view returns (uint256);

    function raisedInTag(string memory tagId) external view returns (uint256);

    function tagIdentifiers() external view returns (string[] memory tagIds);

    function tag(
        string memory tagId
    ) external view returns (IIGOWritableInternal.Tag memory tag);

    function token() external view returns (address);
}
