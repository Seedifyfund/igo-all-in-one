// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ISharedInternal} from "../../shared/ISharedInternal.sol";

/// @notice Only the owner of the contract can call these methods.
interface IRestrictedWritable {
    //////////////////////////// SHARED IGO DATA ////////////////////////////
    function openIGO() external;

    function pauseIGO() external;

    function updateGrandTotal(uint256 grandTotal_) external;

    /// @notice Updates the token users will use to buy into the IGO.
    function updateToken(address token_) external;

    function updateTreasuryWallet(address addr) external;

    /// @dev Retrieve any ERC20 sent to the contract by mistake.
    function recoverLostERC20(address token, address to) external;

    //////////////////////////// TAG BATCH UPDATES ////////////////////////////
    /// @dev Update a tag and all its data.
    function updateTag(
        string calldata tagId_,
        ISharedInternal.Tag calldata tag_
    ) external;

    /**
     * @dev If a tag with an identifier already exists, it will be
     *      updated, otherwise it will be created.
     */
    function setTags(
        string[] memory tagIdentifiers_,
        ISharedInternal.Tag[] memory tags_
    ) external;

    // TODO: UX choice to make here, do we need both tag single field update and tag batch update?
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
