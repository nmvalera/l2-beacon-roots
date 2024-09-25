// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IL1CrossDomainMessenger
/// @notice Interface of the OP CrossDomainMessenger contract on the L1
interface IL1CrossDomainMessenger {
    function sendMessage(address _target, bytes calldata _message, uint32 _gasLimit) external;
}
