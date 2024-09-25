//SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import "./mocks/L2CrossDomainMessengerMock.sol";

import "../src/L2BeaconRoots.sol";
import "../src/interfaces/IL2BeaconRoots.sol";

contract L1BeaconRootsTest is Test {
    // L1BeaconRootsSender instance
    L2BeaconRoots internal l2BeaconRoots;

    // Mocks
    L2CrossDomainMessengerMock internal l2CrossDomainMessengerMock;

    // Addresses
    address internal l1BeaconRootsSender;

    // Constants
    uint32 internal constant L2_BEACON_ROOTS_SET_WHEN_COLD_GAS_LIMIT = 50_000;
    uint32 internal constant L2_BEACON_ROOTS_SET_WHEN_WARM_GAS_LIMIT = 15_000;
    uint256 internal constant BEACON_ROOTS_HISTORY_BUFFER_LENGTH = 8191;

    function setUp() public {
        l2CrossDomainMessengerMock = new L2CrossDomainMessengerMock();
        l1BeaconRootsSender = makeAddr("l1BeaconRootsSender");
        l2BeaconRoots = new L2BeaconRoots(address(l2CrossDomainMessengerMock));
        l2BeaconRoots.init(address(l1BeaconRootsSender));
    }

    function test_set() public {
        uint256 timestamp = 1000;
        bytes32 root = bytes32(uint256(0x1234));
        bytes memory message =
            hex"64c4ef1a00000000000000000000000000000000000000000000000000000000000003e80000000000000000000000000000000000000000000000000000000000001234";

        vm.expectEmit(true, true, true, true, address(l2BeaconRoots));
        emit IL2BeaconRoots.BeaconRootSet(timestamp, root);

        vm.expectEmit(true, true, true, true, address(l2CrossDomainMessengerMock));
        bytes32 messageHash = keccak256(
            abi.encodeWithSignature(
                "relayMessage(address,address,bytes)", address(l2BeaconRoots), l1BeaconRootsSender, message
            )
        );
        emit L2CrossDomainMessengerMock.RelayedMessage(messageHash);

        // Relay the message from the L1BeaconRootsSender remote contract
        vm.startPrank(l1BeaconRootsSender);
        l2CrossDomainMessengerMock.relayMessage(
            address(l2BeaconRoots), L2_BEACON_ROOTS_SET_WHEN_COLD_GAS_LIMIT, message
        );
        vm.stopPrank();

        // Check that the beacon root was set
        assertTrue(l2BeaconRoots.get(timestamp) == root);
    }

    function test_set_RelayFailWhen_CalledByRemoteContractDifferentFromBeaconRootsSender() public {
        address unknown = makeAddr("unknown");

        bytes memory message =
            hex"64c4ef1a00000000000000000000000000000000000000000000000000000000000003e80000000000000000000000000000000000000000000000000000000000001234";

        vm.expectEmit(true, true, true, true, address(l2CrossDomainMessengerMock));
        bytes32 messageHash = keccak256(
            abi.encodeWithSignature("relayMessage(address,address,bytes)", address(l2BeaconRoots), unknown, message)
        );
        emit L2CrossDomainMessengerMock.FailedRelayedMessage(messageHash);

        // Relay the message from the unknown remote contract
        vm.startPrank(unknown);
        l2CrossDomainMessengerMock.relayMessage(
            address(l2BeaconRoots), L2_BEACON_ROOTS_SET_WHEN_COLD_GAS_LIMIT, message
        );
        vm.stopPrank();
    }

    function test_set_RelayFailWhen_GasLimitTooLow() public {
        bytes memory message =
            hex"64c4ef1a00000000000000000000000000000000000000000000000000000000000003e80000000000000000000000000000000000000000000000000000000000001234";

        vm.expectEmit(true, true, true, true, address(l2CrossDomainMessengerMock));
        bytes32 messageHash = keccak256(
            abi.encodeWithSignature(
                "relayMessage(address,address,bytes)", address(l2BeaconRoots), l1BeaconRootsSender, message
            )
        );
        emit L2CrossDomainMessengerMock.FailedRelayedMessage(messageHash);

        // Relay the message from the unknown remote contract
        vm.startPrank(l1BeaconRootsSender);
        l2CrossDomainMessengerMock.relayMessage(address(l2BeaconRoots), 20_000, message);
        vm.stopPrank();
    }

    function test_fallback() public {
        uint256 timestamp = 1000;
        bytes32 root = bytes32(uint256(0x1234));
        bytes memory message =
            hex"64c4ef1a00000000000000000000000000000000000000000000000000000000000003e80000000000000000000000000000000000000000000000000000000000001234";

        // Relay the message from the L1BeaconRootsSender remote contract
        vm.startPrank(l1BeaconRootsSender);
        l2CrossDomainMessengerMock.relayMessage(
            address(l2BeaconRoots), L2_BEACON_ROOTS_SET_WHEN_COLD_GAS_LIMIT, message
        );
        vm.stopPrank();

        // Check that the beacon root was set
        (bool success, bytes memory result) = address(l2BeaconRoots).staticcall(abi.encode(timestamp));
        assertTrue(success);
        assertTrue(abi.decode(result, (bytes32)) == root);
    }

    function test_set_onWarmRingBuffer() public {
        uint256 timestamp = 1000;
        bytes32 root = bytes32(uint256(0x1234));
        bytes memory message =
            hex"64c4ef1a00000000000000000000000000000000000000000000000000000000000003e80000000000000000000000000000000000000000000000000000000000001234";

        // Relay the message from the L1BeaconRootsSender remote contract
        vm.startPrank(l1BeaconRootsSender);
        l2CrossDomainMessengerMock.relayMessage(
            address(l2BeaconRoots), L2_BEACON_ROOTS_SET_WHEN_COLD_GAS_LIMIT, message
        );
        vm.stopPrank();

        // Check that the beacon root was set
        assertTrue(l2BeaconRoots.get(timestamp) == root);

        // Set the beacon root for the following timestamp in the ring
        timestamp = timestamp + BEACON_ROOTS_HISTORY_BUFFER_LENGTH;
        root = bytes32(uint256(0x5678));
        message =
            hex"64c4ef1a00000000000000000000000000000000000000000000000000000000000023e70000000000000000000000000000000000000000000000000000000000005678";
        vm.expectEmit(true, true, true, true, address(l2BeaconRoots));
        emit IL2BeaconRoots.BeaconRootSet(timestamp, root);

        vm.expectEmit(true, true, true, true, address(l2CrossDomainMessengerMock));
        bytes32 messageHash = keccak256(
            abi.encodeWithSignature(
                "relayMessage(address,address,bytes)", address(l2BeaconRoots), l1BeaconRootsSender, message
            )
        );
        emit L2CrossDomainMessengerMock.RelayedMessage(messageHash);

        vm.startPrank(l1BeaconRootsSender);
        l2CrossDomainMessengerMock.relayMessage(
            address(l2BeaconRoots), L2_BEACON_ROOTS_SET_WHEN_WARM_GAS_LIMIT, message
        );
        vm.stopPrank();
    }
}
