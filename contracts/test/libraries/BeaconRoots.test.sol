//SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import "../mocks/BeaconRootsMock.sol";
import "../../src/libraries/BeaconRoots.sol";

contract BeaconRootsTest is Test {
    BeaconRootsMock public beaconRootsMock;

    function setUp() public {
        beaconRootsMock = new BeaconRootsMock();
        beaconRootsMock.givenTimespampReturn(0x12345, bytes32(uint256(0x12345)));
    }

    function test_get_whenRootMissing() public view {
        bytes32 beaconRoot = BeaconRoots._get(address(beaconRootsMock), 0x1234);
        assertEq(beaconRoot, bytes32(uint256(0)));
    }

    function test_get_whenRootNotMissing() public view {
        bytes32 beaconRoot = BeaconRoots._get(address(beaconRootsMock), 0x12345);
        assertEq(beaconRoot, bytes32(uint256(0x12345)));
    }
}
