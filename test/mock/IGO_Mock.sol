// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGO} from "../../src/IGO.sol";

contract IGO_Mock is IGO {
    constructor(
        address _token,
        address _treasuryWallet,
        uint256 _grandTotal
    ) IGO(_token, _treasuryWallet, _grandTotal) {}

    function exposed_requireOpenedIGO() external view {
        _requireOpenedIGO();
    }
}
