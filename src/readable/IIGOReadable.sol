// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ISharedInternal} from "../shared/ISharedInternal.sol";

interface IIGOReadable {
    /**
     * @return Amount of tokens bought by the account in a tag.
     */
    function boughtByIn(
        address account,
        string calldata tagId
    ) external view returns (uint256);

    function igoStage() external view returns (ISharedInternal.Stage);

    function raisedInTag(string memory tagId) external view returns (uint256);

    function setUp()
        external
        view
        returns (address token, address treasuryWallet, uint256 grandTotal);

    function tag(
        string memory tagId
    ) external view returns (ISharedInternal.Tag memory tag_);

    function tagIds() external view returns (string[] memory tagIds_);

    function totalRaised() external view returns (uint256);
}
