// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./L2BeaconRoots.sol";

/// @title IL1CrossDomainMessenger
/// @notice Interface for the OP L1CrossDomainMessenger contract
interface IL1CrossDomainMessenger {
    function sendMessage(address _target, bytes calldata _message, uint32 _gasLimit) external;
}

/// @title L1BeaconRootsSender
/// @notice The L1BeaconRootsSender contract sends the beacon chain block roots to the L2BeaconRoots contract on the L2
contract L1BeaconRootsSender {
    /// @notice The OP L1CrossDomainMessenger contract
    IL1CrossDomainMessenger public immutable L1_MESSENGER;

    /// @notice The L2BeaconRoots contract on the L2
    L2BeaconRoots public immutable L2_BEACON_ROOTS;

    /// @notice The required gas limit for executing the set function on the L2BeaconRoots contract
    uint32 public constant L2_BEACON_ROOTS_SET_GAS_LIMIT = 27_000;

    /// @notice Event emitted when a block root is sent to the L2
    /// @notice The event can be emitted multiple times for the same block root
    /// @notice The event can be emitted for block roots in the past
    /// @notice The protocol does not guarantee that the event is emitted for every block root
    /// @param timestamp: The timestamp of the beacon chain block
    /// @param blockRoot: The beacon chain block root at the given timestamp
    event BlockRootSent(uint256 timestamp, bytes32 blockRoot);

    /// @notice Timestamp out of range for the the beacon roots buffer ring.
    error TimestampOutOfRing();

    /// @notice Timestamp is in the future
    error TimestampInTheFuture();

    /// @notice Beacont root is missing for the given timestamp.
    error BeaconRootMissing();

    /// @notice The L1 official Beacon Roots contracts storing the beacon chain block roots
    /// @dev https://eips.ethereum.org/EIPS/eip-4788
    address internal constant L1_BEACON_ROOTS = 0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02;

    /// @notice The length of the beacon roots ring buffer.
    /// @dev https://eips.ethereum.org/EIPS/eip-4788
    uint256 internal constant BEACON_ROOTS_HISTORY_BUFFER_LENGTH = 8191;

    /// @notice The number of seconds per slot in the beacon chain (12 seconds)
    uint256 internal constant BEACON_SECONDS_PER_SLOT = 12;

    constructor(address _messenger, address _l2BeaconRoots) {
        L1_MESSENGER = IL1CrossDomainMessenger(_messenger);
        L2_BEACON_ROOTS = L2BeaconRoots(_l2BeaconRoots);
    }

    /// @notice Sends a beacon block root to the L2
    /// @notice Retrieves the block root from the official beacon roots contract and sends it to the L2
    /// @param _timestamp: The timestamp of the beacon chain block
    function sendBlockRoot(uint256 _timestamp) public {
        uint256 currentBlockTimestamp = block.timestamp;

        // If the _timestamp is not guaranteed to be within the beacon block root ring buffer, revert.
        if (_timestamp > currentBlockTimestamp) {
            revert TimestampInTheFuture();
        }

        if ((currentBlockTimestamp - _timestamp) >= (BEACON_ROOTS_HISTORY_BUFFER_LENGTH * BEACON_SECONDS_PER_SLOT)) {
            revert TimestampOutOfRing();
        }

        bytes32 beaconRoot = _getBlockRoot(_timestamp);
        if (beaconRoot == bytes32(0)) {
            revert BeaconRootMissing();
        }

        _send(_timestamp, beaconRoot);
    }

    /// @notice Sends beacon block root of the current block to the L2
    /// @notice Retrieves the block root from the official beacon roots contract and sends it to the L2
    /// @notice The beacon block root is for the parent beacon chain slot of the current block
    function sendCurrentBlockRoot() public {
        uint256 currentBlockTimestamp = block.timestamp;

        bytes32 beaconRoot = _getBlockRoot(currentBlockTimestamp);
        if (beaconRoot == bytes32(0)) {
            revert BeaconRootMissing();
        }

        _send(currentBlockTimestamp, beaconRoot);
    }

    /// @notice Retrieves a beacon block root from the official beacon roots contract (EIP-4788)
    /// @param _timestamp: The timestamp of the beacon chain block
    function _getBlockRoot(uint256 _timestamp) internal view returns (bytes32 blockRoot) {
        (bool success, bytes memory result) = L1_BEACON_ROOTS.staticcall(abi.encode(_timestamp));
        if (success && result.length > 0) {
            return abi.decode(result, (bytes32));
        } else {
            return bytes32(0);
        }
    }

    /// @notice Sends a beacon block root to the L2
    /// @param _timestamp: The timestamp of the beacon chain block
    /// @param _beaconRoot: The beacon chain block root at the given timestamp
    function _send(uint256 _timestamp, bytes32 _beaconRoot) internal {
        // Send the block root to the L2
        L1_MESSENGER.sendMessage(
            address(L2_BEACON_ROOTS),
            abi.encodeCall(L2_BEACON_ROOTS.set, (_timestamp, _beaconRoot)),
            L2_BEACON_ROOTS_SET_GAS_LIMIT
        );

        // Emit BlockRootSent event
        emit BlockRootSent(_timestamp, _beaconRoot);
    }
}
