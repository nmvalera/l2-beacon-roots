// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title L2CrossDomainMessengerMock
/// @notice The L2CrossDomainMessengerMock contract is a mock contract of the official L2CrossDomainMessenger contract
///         that simulates relaying messages to a target contracts on the L2
contract L2CrossDomainMessengerMock {
    address internal constant DEFAULT_L2_SENDER = 0x000000000000000000000000000000000000dEaD;

    /// @notice Simulated the address of the sender of the currently executing message on the other chain.
    address internal xDomainMsgSender;

    /// @notice Emitted whenever a message is successfully relayed on this chain.
    /// @param msgHash Hash of the message that was relayed.
    event RelayedMessage(bytes32 indexed msgHash);

    /// @notice Emitted whenever a message fails to be relayed on this chain.
    /// @param msgHash Hash of the message that failed to be relayed.
    event FailedRelayedMessage(bytes32 indexed msgHash);

    constructor() {
        xDomainMsgSender = DEFAULT_L2_SENDER;
    }

    /// @notice Retrieves the simulated address of the contract or wallet that initiated the currently
    ///         executing message on the other chain. This mock sets it to the address of the account
    ///         that called the `relayMessage` function.
    /// @return Simulated address of the sender of the currently executing message on the other chain.
    function xDomainMessageSender() external view returns (address) {
        return xDomainMsgSender;
    }

    /// @notice Relays a message to the target contract.
    function relayMessage(address _target, uint256 _gas, bytes memory _message) external {
        xDomainMsgSender = msg.sender;
        bool success;

        // Perform call on target contract
        assembly {
            success :=
                call(
                    _gas, // gas
                    _target, // recipient
                    0, // ether value
                    add(_message, 32), // inloc
                    mload(_message), // inlen
                    0, // outloc
                    0 // outlen
                )
        }

        xDomainMsgSender = DEFAULT_L2_SENDER;

        bytes32 messageHash =
            keccak256(abi.encodeWithSignature("relayMessage(address,address,bytes)", _target, msg.sender, _message));

        // Emit the appropriate event based on the success of the relay
        if (success) {
            emit RelayedMessage(messageHash);
        } else {
            emit FailedRelayedMessage(messageHash);
        }
    }
}
