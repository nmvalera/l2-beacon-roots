// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title BeaconRootsBuffer Storage
/// @notice Utility to manage the BeaconRootsBuffer in storage.
/// @notice It keeps a history of beacon roots for 8191 blocks which is around 1 day.
///         The buffer enables to save gas by rewriting beaconRoots on warm storage slots.
library BeaconRootsBuffer {
    /// @notice Storage slot of the buffer
    bytes32 internal constant BUFFER_SLOT = bytes32(uint256(keccak256("beaconRoots.state.buffer")) - 1);

    /// @notice Length of the history buffer
    uint256 internal constant HISTORY_BUFFER_LENGTH = 8191;

    /// @notice Structure of the buffer in storage
    struct Slot {
        mapping(uint256 => uint256) value;
    }

    /// @notice Set a beacon root in the buffer
    /// @param _timestamp The timestamp of the beacon root
    /// @param _beaconRoot The beacon root
    function _set(uint256 _timestamp, bytes32 _beaconRoot) internal {
        bytes32 slot = BUFFER_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        uint256 timestamp_idx = _timestamp % HISTORY_BUFFER_LENGTH;
        uint256  root_idx = timestamp_idx + HISTORY_BUFFER_LENGTH;
        r.value[timestamp_idx] = _timestamp;
        r.value[root_idx] = uint256(_beaconRoot);
    }

    /// @notice Get a beacon root from the buffer
    /// @param _timestamp The timestamp of the beacon root
    /// @return beaconRoot The beacon root if found, otherwise 0
    function _get(uint256 _timestamp) internal view returns (bytes32 beaconRoot) {
        bytes32 slot = BUFFER_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        uint256 timestamp_idx = _timestamp % HISTORY_BUFFER_LENGTH;
        uint256 root_idx = timestamp_idx + HISTORY_BUFFER_LENGTH;

        uint256 bufferTimestamp = r.value[timestamp_idx];
        if (bufferTimestamp == _timestamp) {
            beaconRoot = bytes32(r.value[root_idx]);
        }
    }
}