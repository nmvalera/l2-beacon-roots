// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IL2BeaconRoots
/// @notice The interface of the L2BeaconRoots contract stores the beacon chain block roots on the L2
interface IL2BeaconRoots {
    /// @notice Event emitted when the smart contract is initialized
    /// @param _l1BeaconRootsSender: The address of the L1BeaconRootsSender contract on L1
    event Initialized(address _l1BeaconRootsSender);

    /// @notice Event emitted when a beacon block root is set
    /// @notice The event can be emitted multiple times for the same block root
    /// @notice The event can be emitted for block roots in the past
    /// @notice The protocol does not guarantee that the event is emitted for every block root
    /// @param timestamp: The timestamp of the beacon chain block
    /// @param blockRoot: The beacon chain block root at the given timestamp
    event BeaconRootSet(uint256 timestamp, bytes32 blockRoot);

    /// @notice Initialize the contract with the L1BeaconRootsSender address.
    /// @param _l1BeaconRootsSender: The address of the L1BeaconRootsSender contract
    /// @dev The flow is:
    ///       1) Deploy L2BeaconRoots on L2
    ///       2) Deploy L1BeaconRootsSender on L1 (passing the address of the deployed L2BeaconRoots to the constructor)
    ///       3) Initialize L2BeaconRoots with the L1BeaconRootsSender address
    function init(address _l1BeaconRootsSender) external;

    /// @notice Sets the beacon root for a given beacon chain timestamp
    /// @notice This function must be called by the L1BeaconRootsSender contract on L1 through the OP CrossDomainMessenger
    /// @param _beaconTimestamp: The timestamp of the beacon chain block
    /// @param _beaconRoot: The beacon chain block root at the given timestamp
    function set(uint256 _beaconTimestamp, bytes32 _beaconRoot) external;

    /// @notice Gets the beacon root for a given beacon chain timestamp
    /// @param _beacon_timestamp: The timestamp of the beacon chain block
    function get(uint256 _beacon_timestamp) external view returns (bytes32);

    /// @notice Retrieves the address of the CrossDomainMessenger contract on the L2
    function getCrossDomainMessenger() external view returns (address);

    /// @notice Retrieves the address of the L1BeaconRootsSender contract on the L1
    function getL1BeaconRootsSender() external view returns (address);
}
