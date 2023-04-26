// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IRestrictedWritableInternal} from "./IRestrictedWritableInternal.sol";

interface IRestrictedWritable {
    function openIGO() external;

    function pauseIGO() external;

    function setTags(
        string[] memory tagIdentifiers_,
        IRestrictedWritableInternal.Tag[] memory tags_
    ) external;

    function updateToken(address token_) external;

    function updateTreasuryWallet(address addr) external;
}
