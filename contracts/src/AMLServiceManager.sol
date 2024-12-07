// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@eigenlayer/contracts/interfaces/IAVSDirectory.sol";
import "@eigenlayer/contracts/interfaces/IRewardsCoordinator.sol";
import "@eigenlayer/contracts/interfaces/IRegistryCoordinator.sol";
import "@eigenlayer/contracts/interfaces/IStakeRegistry.sol";
import "@eigenlayer-middleware/src/ServiceManagerBase.sol";
import "./IAMLServiceManager.sol";

/**
 * @title Primary entrypoint for procuring services from AML AVS.
 * @notice Similar to HelloWorldServiceManager but for AMLTransactionTaskManager
 */
contract AMLServiceManager is ServiceManagerBase {
    IAMLServiceManager public amlTaskManager;

    modifier onlyAMLTaskManager() {
        require(msg.sender == address(amlTaskManager), "Only AMLTaskManager");
        _;
    }

    constructor(
        IAVSDirectory _avsDirectory,
        IRewardsCoordinator _rewardsCoordinator,
        IRegistryCoordinator _registryCoordinator,
        IStakeRegistry _stakeRegistry,
        IAMLServiceManager _amlTaskManager
    )
        ServiceManagerBase(_avsDirectory, _rewardsCoordinator, _registryCoordinator, _stakeRegistry)
    {
        amlTaskManager = _amlTaskManager;
    }

    function initialize(address initialOwner, address rewardsInitiator) external initializer {
        __ServiceManagerBase_init(initialOwner, rewardsInitiator);
    }

    // Example function if needed in the future for freezing operators, etc.
    function freezeOperator(
        address operatorAddr
    ) external onlyAMLTaskManager {
        // Future slashing logic: slasher.freezeOperator(operatorAddr);
    }
}
