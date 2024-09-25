//SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import "../../src/state/BeaconRootsRingTracker.sol";

contract BeaconRootsRingTackerTest is Test {
    /// @notice Length of the history buffer
    uint256 internal constant HISTORY_BUFFER_LENGTH = 8191;

    function test_setIfNotSet(uint256 timestamp) public {
        uint256 ringIdx = timestamp % HISTORY_BUFFER_LENGTH;
        assertFalse(BeaconRootsRingTracker._isSet(ringIdx));
        assertTrue(BeaconRootsRingTracker._setIfNotSet(ringIdx));
        assertTrue(BeaconRootsRingTracker._isSet(ringIdx));
        assertFalse(BeaconRootsRingTracker._setIfNotSet(ringIdx));
    }
}