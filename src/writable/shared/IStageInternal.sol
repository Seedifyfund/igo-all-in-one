// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface IStageInternal {
    enum Stage {
        NOT_STARTED,
        OPENED,
        COMPLETED,
        PAUSED
    }
}
