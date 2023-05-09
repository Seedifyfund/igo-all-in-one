// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IIGOWritableInternal} from "./IIGOWritableInternal.sol";

interface IIGOWritable {
    /**
     * @param amount Amount of tokens to buy in this transaction.
     * @param allocation Allocation reserved to a specfic tag for a wallet.
     * @param proof Merkle proof to verify the allocation.
     */
    function buyTokens(
        uint256 amount,
        IIGOWritableInternal.Allocation calldata allocation,
        bytes32[] calldata proof
    ) external;
}
