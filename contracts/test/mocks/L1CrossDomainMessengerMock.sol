// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title L1CrossDomainMessengerMock
/// @notice The L1CrossDomainMessengerMock contract is a mock contract of the official L1CrossDomainMessenger contract
contract L1CrossDomainMessengerMock {
    event MessageSent(address indexed target, bytes message, uint32 gasLimit);

    function sendMessage(address _target, bytes memory _message, uint32 _gasLimit) external {
        emit MessageSent(_target, _message, _gasLimit);
    }
}
