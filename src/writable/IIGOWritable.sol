// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IIGOWritableInternal} from "./IIGOWritableInternal.sol";
import {ISharedInternal} from "../shared/ISharedInternal.sol";

interface IIGOWritable {
    /**
     * @param amount Amount of tokens to buy in this transaction.
     * @param allocation Allocation reserved to a specfic tag for a wallet.
     * @param proof Merkle proof to verify the allocation.
     * @param permission Permission granted by user off-chain.
     */
    function buyTokens(
        uint256 amount,
        IIGOWritableInternal.Allocation calldata allocation,
        bytes32[] calldata proof,
        IIGOWritableInternal.BuyPermission calldata permission
    ) external;

    function initialize(
        address owner,
        address token,
        address permit2,
        address treasuryWallet,
        uint256 grandTotal_,
        string[] memory tagIds_,
        ISharedInternal.Tag[] memory tags
    ) external;
}
