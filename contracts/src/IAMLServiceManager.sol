// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IAMLServiceManager {
    event NewAMLTaskCreated(uint32 indexed taskIndex, AMLTask task);
    event AMLTaskResponded(uint32 indexed taskIndex, AMLTask task, address operator, bool flagged);
    event AMLTaskFinalized(uint32 indexed taskIndex, AMLTask task, bool finalFlaggedResult);

    struct AMLTask {
        bytes32 txHash;
        address from;
        address to;
        uint256 amountUSD;
        uint32 timestamp; // Unix time
    }

    function createNewAMLTask(
        bytes32 txHash,
        address from,
        address to,
        uint256 amountUSD,
        uint32 timestamp
    ) external returns (uint32);

    function respondToAMLTask(uint32 taskIndex, bool flagged) external;

    function getTaskCount() external view returns (uint32);

    function getTask(uint32 taskIndex) external view returns (AMLTask memory);

    function isTaskFinalized(uint32 taskIndex) external view returns (bool);

    function getTaskFinalResult(uint32 taskIndex) external view returns (bool);
}
