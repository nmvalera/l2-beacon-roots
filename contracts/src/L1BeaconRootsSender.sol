// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./libraries/BeaconRoots.sol";
import "./state/BeaconRootsRingTracker.sol";
import "./interfaces/IL1CrossDomainMessenger.sol";
import "./interfaces/IL1BeaconRootsSender.sol";
import "./interfaces/IL2BeaconRoots.sol";

/// @title L1BeaconRootsSender
/// @notice The L1BeaconRootsSender contract sends the beacon chain block roots to the L2BeaconRoots contract on the L2
contract L1BeaconRootsSender is IL1BeaconRootsSender {
    /// @notice The OP L1CrossDomainMessenger contract
    address internal immutable MESSENGER;

    /// @notice The L2BeaconRoots contract on the L2
    address internal immutable L2_BEACON_ROOTS;

    /// @notice The L1 official Beacon Roots contracts storing the beacon chain block roots
    /// @dev https://eips.ethereum.org/EIPS/eip-4788
    address internal constant BEACON_ROOTS = 0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02;

    /// @notice The length of the beacon roots ring buffer.
    /// @dev https://eips.ethereum.org/EIPS/eip-4788
    uint256 internal constant BEACON_ROOTS_HISTORY_BUFFER_LENGTH = 8191;

    /// @notice The number of seconds per slot in the beacon chain (12 seconds)
    uint256 internal constant BEACON_SECONDS_PER_SLOT = 12;

    /// @notice The gas limit required for executing the L2BeaconRoots.set call on L2 varies based on whether
    ///         a beacon root has already been stored in the L2BeaconRoots ring buffer for the specified timestamp.
    ///         Most of the gas cost is due to two SSTORE operations (one for the timestamp and one for the beacon root):
    ///             - 20,000 gas each when writing to cold storage.
    ///             - 2,900 gas each when writing to warm storage.
    uint32 internal constant L2_BEACON_ROOTS_SET_GAS_LIMIT_WHEN_COLD = 50_000;
    uint32 internal constant L2_BEACON_ROOTS_SET_GAS_LIMIT_WHEN_WARM = 15_000;

    /// @param _messenger: The address of the CrossDomainMessenger contract on the L1
    /// @param _l2BeaconRoots: The address of the L2BeaconRoots contract on the L2
    constructor(address _messenger, address _l2BeaconRoots) {
        MESSENGER = _messenger;
        L2_BEACON_ROOTS = _l2BeaconRoots;
    }

    /// @inheritdoc IL1BeaconRootsSender
    function sendBlockRoot(uint256 _timestamp) public {
        uint256 currentBlockTimestamp = block.timestamp;

        // If the _timestamp is in the futre, revert.
        if (_timestamp > currentBlockTimestamp) {
            revert TimestampInTheFuture();
        }

        // If the _timestamp is not guaranteed to be within the beacon block root ring buffer, revert.
        if ((currentBlockTimestamp - _timestamp) >= (BEACON_ROOTS_HISTORY_BUFFER_LENGTH * BEACON_SECONDS_PER_SLOT)) {
            revert TimestampOutOfRing();
        }

        // Retrieve the beacon block root from the official beacon roots contract
        bytes32 beaconRoot = _getBlockRoot(_timestamp);

        // If the beacon root is missing, revert.
        if (beaconRoot == bytes32(0)) {
            revert BeaconRootMissing();
        }

        // Send the beacon block root to the L2
        _send(_timestamp, beaconRoot);
    }

    /// @inheritdoc IL1BeaconRootsSender
    function sendCurrentBlockRoot() public {
        uint256 currentBlockTimestamp = block.timestamp;

        // Retrieve the beacon block root from the official beacon roots contract
        bytes32 beaconRoot = _getBlockRoot(currentBlockTimestamp);

        // If the beacon root is missing, revert.
        if (beaconRoot == bytes32(0)) {
            revert BeaconRootMissing();
        }

        // Send the beacon block root to the L2
        _send(currentBlockTimestamp, beaconRoot);
    }

    /// @notice Retrieves a beacon block root from the official beacon roots contract (EIP-4788)
    /// @param _timestamp: The timestamp of the beacon chain block
    function _getBlockRoot(uint256 _timestamp) internal view returns (bytes32 blockRoot) {
        return BeaconRoots._get(BEACON_ROOTS, _timestamp);
    }

    /// @notice Sends a beacon block root to the L2
    /// @param _timestamp: The timestamp of the beacon chain block
    /// @param _beaconRoot: The beacon chain block root at the given timestamp
    function _send(uint256 _timestamp, bytes32 _beaconRoot) internal {
        // Check whether a beacon root has already been set in the L2BeaconRoots ring buffer for the specified timestamp.
        // It is used to adjust the gas limit required for the L2BeaconRoots.set call on L2.
        // If not previously set, the timestamp is marked accordingly.
        bool isToBeSet = BeaconRootsRingTracker._markIfNotYetMarked(_timestamp % BEACON_ROOTS_HISTORY_BUFFER_LENGTH);

        // If a beacon root has already been set in the L2BeaconRoots ring buffer for the specified timestamp,
        // a lower gas limit is used since there's no need to write to fresh storage.
        // Otherwise, the higher gas limit is applied for initial writes.
        // As more beacon roots are recorded over time, the gas limit will increasingly shift to the warm limit.
        // This approach reduces the L1 gas required to send beacon roots through the OP CrossDomainMessenger.
        uint32 gasLimit = L2_BEACON_ROOTS_SET_GAS_LIMIT_WHEN_WARM;
        if (isToBeSet) {
            gasLimit = L2_BEACON_ROOTS_SET_GAS_LIMIT_WHEN_COLD;
        }

        // Send the beacon block root to the L2
        IL1CrossDomainMessenger(MESSENGER).sendMessage(
            address(L2_BEACON_ROOTS), abi.encodeCall(IL2BeaconRoots.set, (_timestamp, _beaconRoot)), gasLimit
        );

        // Emit BlockRootSent event
        emit BlockRootSent(_timestamp, _beaconRoot);
    }

    /// @inheritdoc IL1BeaconRootsSender
    function getCrossDomainMessenger() external view returns (address) {
        return MESSENGER;
    }

    /// @inheritdoc IL1BeaconRootsSender
    function getL2BeaconRoots() external view returns (address) {
        return L2_BEACON_ROOTS;
    }
}
