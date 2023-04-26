// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IRestrictedWritableInternal} from "../writable/restricted/IRestrictedWritableInternal.sol";
import {IIGOWritableInternal} from "../writable/IIGOWritableInternal.sol";

interface IIGOReadable {
    function claimedBy(address account) external view returns (uint256);

    function igoStage() external view returns (IIGOWritableInternal.Stage);

    function raisedInTag(string memory tagId) external view returns (uint256);

    function setUp()
        external
        view
        returns (address token, address treasuryWallet, uint256 grandTotal);

    function tag(
        string memory tagId
    ) external view returns (IRestrictedWritableInternal.Tag memory tag);

    function tagIds() external view returns (string[] memory tagIds);

    function totalRaised() external view returns (uint256);
}
