// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ISharedInternal} from "../shared/ISharedInternal.sol";

interface IIGOReadable {
    /**
     * @return Allocation amount reserved by the account in a tag, expressed
     *         in IGOStruct.SetUp.paymentToken OR Tag.paymentToken
     */
    function allocationReservedByIn(
        address account,
        string calldata tagId
    ) external view returns (uint256);

    function igoStatus() external view returns (ISharedInternal.Status);

    function raisedInTag(string memory tagId) external view returns (uint256);

    function setUp()
        external
        view
        returns (
            address vestingContract,
            address paymentToken,
            uint256 grandTotal,
            uint256 summedMaxTagCap,
            uint256 refundFeeDecimals
        );

    function tag(
        string memory tagId
    ) external view returns (ISharedInternal.Tag memory tag_);

    function tagIds() external view returns (string[] memory tagIds_);

    function totalRaised() external view returns (uint256);
}
