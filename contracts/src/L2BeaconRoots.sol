// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./L1BeaconRootsSender.sol";

/// @title IL2CrossDomainMessenger
/// @notice Interface for the OP L2CrossDomainMessenger contract
interface IL2CrossDomainMessenger {
    function xDomainMessageSender() external view returns (address);
}

/// @title L2BeaconRoots
/// @notice The L2BeaconRoots contract stores the beacon chain block roots on the L2
contract L2BeaconRoots {
    /// @notice The L1CrossDomainMessenger contract
    IL2CrossDomainMessenger public immutable MESSENGER;

    /// @notice The L1BeaconRootsSender contract on the L1
    address public L1_BEACON_ROOTS_SENDER;

    /// @notice The beacon chain block roots stored by timestamps
    mapping(uint256 => bytes32) public beaconRoots;

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

    /// @param _messenger: The address of the L2 CrossDomainMessenger contract
    constructor(address _messenger) {
        MESSENGER = IL2CrossDomainMessenger(_messenger);
    }

    /// @notice Initialize the contract with the L1BeaconRootsSender address.
    /// @param _l1BeaconRootsSender: The address of the L1BeaconRootsSender contract
    /// @dev The flow is:
    ///       1) Deploy L2BeaconRoots on L2
    ///       2) Deploy L1BeaconRootsSender on L1 (passing the address of the deployed L2BeaconRoots to the constructor)
    ///       3) Initialize L2BeaconRoots with the L1BeaconRootsSender address
    function init(address _l1BeaconRootsSender) public {
        require(address(L1_BEACON_ROOTS_SENDER) == address(0), "BeaconRoots: Contract has already been initialized");
        L1_BEACON_ROOTS_SENDER = _l1BeaconRootsSender;
        emit Initialized(_l1BeaconRootsSender);
    }

    /// @notice Sets the beacon root for a given beacon chain timestamp
    /// @notice This function must be called by the L1BeaconRootsSender contract on L1 through the OP CrossDomainMessenger
    /// @param _beaconTimestamp: The timestamp of the beacon chain block
    /// @param _beaconRoot: The beacon chain block root at the given timestamp
    function set(uint256 _beaconTimestamp, bytes32 _beaconRoot) public {
        require(msg.sender == address(MESSENGER), "BeaconRoots: Direct sender must be the CrossDomainMessenger");

        require(
            MESSENGER.xDomainMessageSender() == L1_BEACON_ROOTS_SENDER,
            "BeaconRoots: Remote sender must be the Beacon Roots Sender contract"
        );

        beaconRoots[_beaconTimestamp] = _beaconRoot;

        emit BeaconRootSet(_beaconTimestamp, _beaconRoot);
    }

    /// @notice Gets the beacon root for a given beacon chain timestamp
    /// @param _beacon_timestamp: The timestamp of the beacon chain block
    function get(uint256 _beacon_timestamp) public view returns (bytes32) {
        return beaconRoots[_beacon_timestamp];
    }
}
