// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IRestrictedWritableInternal} from "./IRestrictedWritableInternal.sol";

interface IRestrictedWritable {
    //////////////////////////// SHARED IGO DATA ////////////////////////////
    function openIGO() external;

    function pauseIGO() external;

    function updateGrandTotal(uint256 grandTotal_) external;

    function updateToken(address token_) external;

    function updateTreasuryWallet(address addr) external;

    //////////////////////////// TAG BATCH UPDATES ////////////////////////////
    function updateTag(
        string calldata tagId_,
        IRestrictedWritableInternal.Tag calldata tag_
    ) external;

    function setTags(
        string[] memory tagIdentifiers_,
        IRestrictedWritableInternal.Tag[] memory tags_
    ) external;

    //////////////////////////// TAG SINGLE UPDATE ////////////////////////////
    function openTag(string memory tagId) external;

    function pauseTag(string memory tagId) external;

    function updateTagMerkleRoot(
        string memory tagId,
        bytes32 merkleRoot
    ) external;

    function updateTagStartDate(string memory tagId, uint128 startAt) external;

    function updateTagEndDate(string memory tagId, uint128 endAt) external;

    function updateTagMaxCap(string memory tagId, uint256 maxTagCap) external;
}
