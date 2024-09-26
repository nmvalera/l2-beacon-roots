// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title BeaconRootsBuffer Storage
/// @notice Utility to track the state of the L2BeaconRoots ring buffer
library BeaconRootsRingTracker {
    /// @notice Storage slot of the buffer
    bytes32 internal constant RING_TRACKER_SLOT = bytes32(uint256(keccak256("beaconRootsSender.state.ringTracker")) - 1);

    /// @notice Check if a ring buffer index was already marked
    /// @param _ringIdx: The ring buffer index, it must be within the history buffer length (0 <= _ringIdx < HISTORY_BUFFER_LENGTH)
    function _isMarked(uint256 _ringIdx) internal view returns (bool isMarked) {
        bytes32 slot = RING_TRACKER_SLOT;

        assembly {
            let u := sload(add(slot,div(_ringIdx, 256)))
            isMarked := gt(and(u, shl(mod(_ringIdx, 256), 1)),0)
        }
    }
    
    /// @notice Mark a ring buffer index if it was not already marked
    /// @param _ringIdx: The ring buffer index, it must be within the history buffer length (0 <= _ringIdx < HISTORY_BUFFER_LENGTH)
    function _markIfNotYetMarked(uint256 _ringIdx) internal returns (bool wasMarked) {
        bytes32 slot = RING_TRACKER_SLOT;

        assembly {
            ///  Mark the ring index if it is not already marked
            ///  Note:
            ///  - This is the expensive part of the operation as it requires an SSTORE operation
            ///  - In most cases, this will re-write a storage slot that was already marked for a neighboring ring index, thus reducing gas cost
            let u := sload(add(slot,div(_ringIdx, 256)))
            wasMarked := eq(and(u, shl(mod(_ringIdx, 256), 1)),0)
            if wasMarked {
                sstore(add(slot,div(_ringIdx, 256)), or(u, shl(mod(_ringIdx, 256), 1)))
            }
        }
    }
}
