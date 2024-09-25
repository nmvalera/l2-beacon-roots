// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title BeaconRootsBuffer Storage
/// @notice Utility to track the state of the L2BeaconRoots ring buffer
library BeaconRootsRingTracker {
    /// @notice Storage slot of the buffer
    bytes32 internal constant RING_TRACKER_SLOT = bytes32(uint256(keccak256("beaconRootsSender.state.ringTracker")) - 1);

    /// @notice Structure of the buffer in storage
    struct Slot {
        uint256[32] value;
    }

    /// @notice Check if a ring buffer index is set
    /// @dev The ring buffer index must be within the history buffer length (0 <= _ringIdx < HISTORY_BUFFER_LENGTH)
    function _isSet(uint256 _ringIdx) internal view returns (bool) {
        bytes32 slot = RING_TRACKER_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        (uint256 trackerIdx, uint256 bitIdx) = _position(_ringIdx);

        return r.value[trackerIdx] & (1 << bitIdx) > 0;
    }

    /// @notice Set a ring buffer index if it is not already set
    /// @return true if the index was set, false otherwise
    function _setIfNotSet(uint256 _ringIdx) internal returns (bool) {
        bytes32 slot = RING_TRACKER_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        (uint256 trackerIdx, uint256 bitIdx) = _position(_ringIdx);
        if (r.value[trackerIdx] & (1 << bitIdx) > 0) {
            return false;
        }

        r.value[trackerIdx] |= (1 << bitIdx);

        return true;
    }

    function _position(uint256 _ringIdx) private pure returns (uint256, uint256) {
        return (_ringIdx / 256, _ringIdx % 256);
    }
}