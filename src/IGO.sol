// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOReadable} from "./readable/IGOReadable.sol";
import {IGOWritable} from "./writable/IGOWritable.sol";

contract IGO is IGOReadable, IGOWritable {}
