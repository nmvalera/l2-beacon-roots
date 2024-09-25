// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IL1CrossDomainMessenger.sol";
import "./interfaces/IL1BeaconRootsSender.sol";
import "./interfaces/IL2BeaconRoots.sol";

/// @title L1BeaconRootsSender
/// @notice The L1BeaconRootsSender contract sends the beacon chain block roots to the L2BeaconRoots contract on the L2
contract L1BeaconRootsSender is IL1BeaconRootsSender {
    /// @notice The OP L1CrossDomainMessenger contract
    address internal immutable L1_MESSENGER;

    /// @notice The L2BeaconRoots contract on the L2
    address internal immutable L2_BEACON_ROOTS;

    /// @notice The L1 official Beacon Roots contracts storing the beacon chain block roots
    /// @dev https://eips.ethereum.org/EIPS/eip-4788
    address internal constant L1_BEACON_ROOTS = 0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02;

    /// @notice The length of the beacon roots ring buffer.
    /// @dev https://eips.ethereum.org/EIPS/eip-4788
    uint256 internal constant BEACON_ROOTS_HISTORY_BUFFER_LENGTH = 8191;

    /// @notice The number of seconds per slot in the beacon chain (12 seconds)
    uint256 internal constant BEACON_SECONDS_PER_SLOT = 12;

    /// @notice The required gas limit for executing the set function on the L2BeaconRoots contract
    uint32 internal constant L2_BEACON_ROOTS_SET_GAS_LIMIT = 27_000;

    constructor(address _messenger, address _l2BeaconRoots) {
        L1_MESSENGER = _messenger;
        L2_BEACON_ROOTS = _l2BeaconRoots;
    }

    /// @inheritdoc IL1BeaconRootsSender
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

    /// @inheritdoc IL1BeaconRootsSender
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
        IL1CrossDomainMessenger(L1_MESSENGER).sendMessage(
            address(L2_BEACON_ROOTS),
            abi.encodeCall(IL2BeaconRoots.set, (_timestamp, _beaconRoot)),
            L2_BEACON_ROOTS_SET_GAS_LIMIT
        );

        // Emit BlockRootSent event
        emit BlockRootSent(_timestamp, _beaconRoot);
    }

    /// @inheritdoc IL1BeaconRootsSender
    function getCrossDomainMessenger() external view returns (address) {
        return L1_MESSENGER;
    }

    /// @inheritdoc IL1BeaconRootsSender
    function getL2BeaconRoots() external view returns (address) {
        return L2_BEACON_ROOTS;
    }
}
