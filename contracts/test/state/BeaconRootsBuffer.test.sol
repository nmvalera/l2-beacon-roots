//SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import "../../src/state/BeaconRootsBuffer.sol";

contract BeaconRootsBufferTest is Test {
    uint256 internal constant warmTimestamp = 1000;
    uint256 internal constant coldTimestamp = 2000;
    uint256 internal constant HISTORY_BUFFER_LENGTH = 8191;

    function setUp() public {
        BeaconRootsBuffer._set(warmTimestamp, bytes32(uint256(0x1234)));
    }

    function test_get_overridenTimestamp() public {
        assertEq(BeaconRootsBuffer._get(warmTimestamp), bytes32(uint256(0x1234)));
        BeaconRootsBuffer._set(warmTimestamp+HISTORY_BUFFER_LENGTH, bytes32(uint256(0x1235)));
        assertEq(BeaconRootsBuffer._get(warmTimestamp), bytes32(uint256(0)));
    }

    function test_set_onWarmState() public {
        BeaconRootsBuffer._set(warmTimestamp, bytes32(uint256(0x1235)));
    }

    function test_set_onColdState() public {
        BeaconRootsBuffer._set(coldTimestamp, bytes32(uint256(0x1235)));
    }
}