// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin-upgrades/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin-upgrades/contracts/access/OwnableUpgradeable.sol";
import "@eigenlayer/contracts/permissions/Pausable.sol";
import "@eigenlayer-middleware/src/interfaces/IServiceManager.sol";
import {ECDSAStakeRegistry} from "@eigenlayer-middleware/src/unaudited/ECDSAStakeRegistry.sol";
import {IAMLServiceManager} from "./IAMLServiceManager.sol";
import {IAVSDirectory} from "@eigenlayer/contracts/interfaces/IAVSDirectory.sol";
import {IRewardsCoordinator} from "@eigenlayer/contracts/interfaces/IRewardsCoordinator.sol";
import {IDelegationManager} from "@eigenlayer/contracts/interfaces/IDelegationManager.sol";
import {IRegistryCoordinator} from "@eigenlayer-middleware/src/interfaces/IRegistryCoordinator.sol";
import {ServiceManagerBase} from "@eigenlayer-middleware/src/ServiceManagerBase.sol";

contract AMLTransactionTaskManager is
    Initializable,
    OwnableUpgradeable,
    Pausable,
    IAMLServiceManager
{
    // We will mimic HelloWorld approach: store tasks on-chain, allow operators to respond, finalize when consensus is reached.

    address public stakeRegistry;
    address public delegationManager;
    address public rewardsCoordinator;
    address public avsDirectory;

    // tasks
    uint32 public latestTaskNum;
    mapping(uint32 => AMLTask) public allTasks;

    // Track responses:
    // For each taskIndex -> array of operator responses (operator -> flagged or not)
    // We'll store them in a simple struct
    struct OperatorResponse {
        address operator;
        bool flagged;
    }
    mapping(uint32 => OperatorResponse[]) public taskResponses;

    // final result
    mapping(uint32 => bool) public taskFinalized;
    mapping(uint32 => bool) public taskFinalResult; // true if flagged, false if not

    // Minimum number of operator responses for a final decision
    uint256 public requiredOperators = 3;
    uint256 public consensusThreshold = 2; // out of 3 must agree

    // The stake registry is used to check if operator is registered
    ECDSAStakeRegistry public ecdsaStakeRegistry;

    modifier onlyAVSDirectoryOwner() {
        // In real scenario, ensure only appropriate party can pause/unpause
        require(msg.sender == owner(), "Not authorized");
        _;
    }

    modifier onlyOperator() {
        require(ecdsaStakeRegistry.operatorRegistered(msg.sender), "Operator not registered");
        _;
    }

    function initialize(
        address _avsDirectory,
        address _stakeRegistry,
        address _rewardsCoordinator,
        address _delegationManager,
        address initialOwner
    ) public initializer {
        __Ownable_init();
        __Pausable_init();
        avsDirectory = _avsDirectory;
        stakeRegistry = _stakeRegistry;
        rewardsCoordinator = _rewardsCoordinator;
        delegationManager = _delegationManager;
        ecdsaStakeRegistry = ECDSAStakeRegistry(_stakeRegistry);

        transferOwnership(initialOwner);
    }

    function createNewAMLTask(
        bytes32 txHash,
        address from,
        address to,
        uint256 amountUSD,
        uint32 timestamp
    ) external override returns (uint32) {
        AMLTask memory newTask = AMLTask({
            txHash: txHash,
            from: from,
            to: to,
            amountUSD: amountUSD,
            timestamp: timestamp
        });

        allTasks[latestTaskNum] = newTask;
        emit NewAMLTaskCreated(latestTaskNum, newTask);
        latestTaskNum += 1;
        return latestTaskNum - 1;
    }

    function respondToAMLTask(uint32 taskIndex, bool flagged) external override onlyOperator {
        require(taskIndex < latestTaskNum, "Invalid task index");
        require(!taskFinalized[taskIndex], "Task already finalized");
        AMLTask memory task = allTasks[taskIndex];
        require(task.txHash != bytes32(0), "Task does not exist");

        // Check if operator already responded
        OperatorResponse[] storage responses = taskResponses[taskIndex];
        for (uint256 i = 0; i < responses.length; i++) {
            require(responses[i].operator != msg.sender, "Operator already responded");
        }

        responses.push(OperatorResponse({operator: msg.sender, flagged: flagged}));
        emit AMLTaskResponded(taskIndex, task, msg.sender, flagged);

        // Check if we have enough responses
        if (responses.length == requiredOperators) {
            finalizeTask(taskIndex);
        }
    }

    function finalizeTask(uint32 taskIndex) internal {
        OperatorResponse[] storage responses = taskResponses[taskIndex];
        uint256 flaggedCount;
        for (uint256 i = 0; i < responses.length; i++) {
            if (responses[i].flagged) {
                flaggedCount++;
            }
        }

        bool finalResult = (flaggedCount >= consensusThreshold);
        taskFinalized[taskIndex] = true;
        taskFinalResult[taskIndex] = finalResult;
        emit AMLTaskFinalized(taskIndex, allTasks[taskIndex], finalResult);
    }

    function getTaskCount() external view override returns (uint32) {
        return latestTaskNum;
    }

    function getTask(uint32 taskIndex) external view override returns (AMLTask memory) {
        return allTasks[taskIndex];
    }

    function isTaskFinalized(uint32 taskIndex) external view override returns (bool) {
        return taskFinalized[taskIndex];
    }

    function getTaskFinalResult(uint32 taskIndex) external view override returns (bool) {
        require(taskFinalized[taskIndex], "Task not finalized");
        return taskFinalResult[taskIndex];
    }
}
