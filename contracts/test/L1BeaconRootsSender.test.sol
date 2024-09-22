//SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import "./mocks/BeaconRootsMock.sol";
import "./mocks/L1CrossDomainMessengerMock.sol";

import "../src/L1BeaconRootsSender.sol";

contract L1BeaconRootsSenderTest is Test {
    // L1BeaconRootsSender instance
    L1BeaconRootsSender internal l1BeaconRootsSender;

    // Mocks
    L1CrossDomainMessengerMock internal l1CrossDomainMessengerMock;
    BeaconRootsMock public beaconRootsMock;

    // Addresses
    address internal l2BeaconRootsAddress;

    // Constants
    address internal constant BEACON_ROOTS_ADDRESS = 0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02;
    uint256 internal constant BEACON_ROOTS_HISTORY_BUFFER_LENGTH = 8191;
    uint256 internal constant BEACON_SECONDS_PER_SLOT = 12;
    uint32 internal constant L2_BEACON_ROOTS_SET_GAS_LIMIT = 27_000;

    function setUp() public {
        l1CrossDomainMessengerMock = new L1CrossDomainMessengerMock();
        l2BeaconRootsAddress = makeAddr("l2BeaconRoots");
        l1BeaconRootsSender =
            new L1BeaconRootsSender(address(l1CrossDomainMessengerMock), address(l2BeaconRootsAddress));

        // Mocks the Beacon Roots contract
        vm.etch(BEACON_ROOTS_ADDRESS, address(new BeaconRootsMock()).code);
        beaconRootsMock = BeaconRootsMock(BEACON_ROOTS_ADDRESS);
    }

    function _setMockedBeaconRootForTimestamp(uint256 _timestamp, bytes32 _root) internal {
        beaconRootsMock.givenTimespampReturn(_timestamp, _root);
    }

    function test_sendBlockRoot() public {
        vm.warp(2000);
        uint256 timestamp = 1000;
        bytes32 root = bytes32(uint256(0x1234));

        // Set the beacon root for the current block
        _setMockedBeaconRootForTimestamp(timestamp, root);

        vm.expectEmit(true, true, true, true, address(l1CrossDomainMessengerMock));
        bytes memory message =
            hex"64c4ef1a00000000000000000000000000000000000000000000000000000000000003e80000000000000000000000000000000000000000000000000000000000001234";
        emit L1CrossDomainMessengerMock.MessageSent(l2BeaconRootsAddress, message, L2_BEACON_ROOTS_SET_GAS_LIMIT);

        vm.expectEmit(true, true, true, true, address(l1BeaconRootsSender));
        emit L1BeaconRootsSender.BlockRootSent(1000, bytes32(uint256(0x1234)));

        // Send the current block root
        l1BeaconRootsSender.sendBlockRoot(timestamp);
    }

    function test_sendCurrentBlockRoot() public {
        vm.warp(1000);
        bytes32 root = bytes32(uint256(0x1234));

        // Set the beacon root for the current block
        _setMockedBeaconRootForTimestamp(block.timestamp, root);

        vm.expectEmit(true, true, true, true, address(l1CrossDomainMessengerMock));
        bytes memory message =
            hex"64c4ef1a00000000000000000000000000000000000000000000000000000000000003e80000000000000000000000000000000000000000000000000000000000001234";
        emit L1CrossDomainMessengerMock.MessageSent(l2BeaconRootsAddress, message, L2_BEACON_ROOTS_SET_GAS_LIMIT);

        vm.expectEmit(true, true, true, true, address(l1BeaconRootsSender));
        emit L1BeaconRootsSender.BlockRootSent(1000, bytes32(uint256(0x1234)));

        // Send the current block root
        l1BeaconRootsSender.sendCurrentBlockRoot();
    }

    function test_sendBlockRoot_RevertWhen_TimestampInTheFuture() public {
        vm.warp(1000);
        uint256 timestamp = 2000;

        vm.expectRevert(L1BeaconRootsSender.TimestampInTheFuture.selector);
        // Send the current block root
        l1BeaconRootsSender.sendBlockRoot(timestamp);
    }

    function test_sendBlockRoot_RevertWhen_TimestampOutOfRing() public {
        vm.warp(1001 + BEACON_ROOTS_HISTORY_BUFFER_LENGTH * BEACON_SECONDS_PER_SLOT);
        uint256 timestamp = 1000;

        vm.expectRevert(L1BeaconRootsSender.TimestampOutOfRing.selector);
        // Send the current block root
        l1BeaconRootsSender.sendBlockRoot(timestamp);
    }

    function test_sendBlockRoot_RevertWhen_BeaconRootMissing() public {
        vm.warp(2000);
        uint256 timestamp = 1000;

        vm.expectRevert(L1BeaconRootsSender.BeaconRootMissing.selector);

        // Send the current block root
        l1BeaconRootsSender.sendBlockRoot(timestamp);
    }
}
