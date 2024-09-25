// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IL2CrossDomainMessenger.sol";
import "./interfaces/IL1BeaconRootsSender.sol";
import "./interfaces/IL2BeaconRoots.sol";
import "./state/BeaconRootsBuffer.sol";

/// @title L2BeaconRoots
/// @notice The L2BeaconRoots contract stores the beacon chain block roots on the L2
contract L2BeaconRoots is IL2BeaconRoots {
    /// @notice The L1CrossDomainMessenger contract
    address internal immutable MESSENGER;

    /// @notice The L1BeaconRootsSender contract on the L1
    address internal L1_BEACON_ROOTS_SENDER;

    /// @param _messenger: The address of the L2 CrossDomainMessenger contract
    constructor(address _messenger) {
        MESSENGER = _messenger;
    }

    /// @inheritdoc IL2BeaconRoots
    function init(address _l1BeaconRootsSender) public {
        require(L1_BEACON_ROOTS_SENDER == address(0), "BeaconRoots: Contract has already been initialized");
        L1_BEACON_ROOTS_SENDER = _l1BeaconRootsSender;
        emit Initialized(_l1BeaconRootsSender);
    }

    /// @inheritdoc IL2BeaconRoots
    function set(uint256 _beaconTimestamp, bytes32 _beaconRoot) public {
        require(msg.sender == MESSENGER, "BeaconRoots: Direct sender must be the CrossDomainMessenger");

        require(
            IL2CrossDomainMessenger(MESSENGER).xDomainMessageSender() == L1_BEACON_ROOTS_SENDER,
            "BeaconRoots: Remote sender must be the Beacon Roots Sender contract"
        );

        _set(_beaconTimestamp, _beaconRoot);
    }

    /// @inheritdoc IL2BeaconRoots
    function get(uint256 _beacon_timestamp) public view returns (bytes32) {
        return _get(_beacon_timestamp);
    }

    /// @inheritdoc IL2BeaconRoots
    function getCrossDomainMessenger() external view returns (address) {
        return MESSENGER;
    }

    /// @inheritdoc IL2BeaconRoots
    function getL1BeaconRootsSender() external view returns (address) {
        return L1_BEACON_ROOTS_SENDER;
    }

    function _set(uint256 _beaconTimestamp, bytes32 _beaconRoot) internal {
        BeaconRootsBuffer._set(_beaconTimestamp, _beaconRoot);
        emit BeaconRootSet(_beaconTimestamp, _beaconRoot);
    }

    function _get(uint256 _beaconTimestamp) internal view returns (bytes32) {
        return BeaconRootsBuffer._get(_beaconTimestamp);
    }

    fallback() external {
        // If calldata is not 32 bytes long, revert
        require(msg.data.length == 32, "BeaconRoots: Invalid function selector");

        // Convert the call data to a uint256
        uint256 beaconTimestamp;
        assembly {
            beaconTimestamp := calldataload(0)
        }

        bytes32 beaconRoot = _get(beaconTimestamp);

        // Return the beacon root
        assembly {
            mstore(0, beaconRoot)
            return(0, 32)
        }
    }
}
