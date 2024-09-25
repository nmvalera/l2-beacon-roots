// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IL2CrossDomainMessenger
/// @notice Interface for the OP CrossDomainMessenger contract on L2
interface IL2CrossDomainMessenger {
    function xDomainMessageSender() external view returns (address);
}
