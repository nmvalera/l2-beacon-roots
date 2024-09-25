// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IL1BeaconRootsSender
/// @notice The L1BeaconRootsSender contract sends the beacon chain block roots to the L2BeaconRoots contract on the L2
interface IL1BeaconRootsSender {
    /// @notice Event emitted when a block root is sent to the L2
    /// @notice The event can be emitted multiple times for the same block root
    /// @notice The event can be emitted for block roots in the past
    /// @notice The protocol does not guarantee that the event is emitted for every block root
    /// @param timestamp: The timestamp of the beacon chain block
    /// @param blockRoot: The beacon chain block root at the given timestamp
    event BlockRootSent(uint256 timestamp, bytes32 blockRoot);

    /// @notice Timestamp out of range for the the beacon roots buffer ring.
    error TimestampOutOfRing();

    /// @notice Timestamp is in the future
    error TimestampInTheFuture();

    /// @notice Beacont root is missing for the given timestamp.
    error BeaconRootMissing();

    /// @notice Sends a beacon block root to the L2
    /// @notice Retrieves the block root from the official beacon roots contract and sends it to the L2
    /// @param _timestamp: The timestamp of the beacon chain block
    function sendBlockRoot(uint256 _timestamp) external;

    /// @notice Sends beacon block root of the current block to the L2
    /// @notice Retrieves the block root from the official beacon roots contract and sends it to the L2
    /// @notice The beacon block root is for the parent beacon chain slot of the current block
    function sendCurrentBlockRoot() external;

    /// @notice Retrieves the address of the CrossDomainMessenger contract on the L1
    function getCrossDomainMessenger() external view returns (address);

    /// @notice Retrieves the address of the L2BeaconRoots contract on the L2
    function getL2BeaconRoots() external view returns (address);
}
