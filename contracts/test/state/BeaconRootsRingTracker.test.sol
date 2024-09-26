//SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import "../../src/state/BeaconRootsRingTracker.sol";

contract BeaconRootsRingTackerTest is Test {
    /// @notice Length of the history buffer
    uint256 internal constant HISTORY_BUFFER_LENGTH = 8191;

    function test_markIfNotYetMarked(uint256 timestamp) public {
        uint256 ringIdx = timestamp % HISTORY_BUFFER_LENGTH;
        assertFalse(BeaconRootsRingTracker._isMarked(ringIdx));
        assertTrue(BeaconRootsRingTracker._markIfNotYetMarked(ringIdx));
        assertTrue(BeaconRootsRingTracker._isMarked(ringIdx));
        assertFalse(BeaconRootsRingTracker._markIfNotYetMarked(ringIdx));
    }

    function test_isMarked_whenNotMarked(uint256 timestamp) public view{
        assertFalse(BeaconRootsRingTracker._isMarked(timestamp));
    }

    function test_markIfNotYetMarked_whenNotMarked(uint256 timestamp) public {
        assertTrue(BeaconRootsRingTracker._markIfNotYetMarked(timestamp));
    }
}
