// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title BeaconRootsMock
/// @notice The BeaconRootsMock contract is a mock contract of the official Beacon Roots contract (EIP-4788)
contract BeaconRootsMock {
    mapping(uint256 => bytes32) public beaconRoots;

    // @notice Sets the beacon root for a given beacon chain timestamp
    function givenTimespampReturn(uint256 _beaconTimestamp, bytes32 _beaconRoot) public {
        beaconRoots[_beaconTimestamp] = _beaconRoot;
    }

    /// @notice Gets the beacon root for a given beacon chain timestamp
    /// @notice It aims at replicating the behavior of the official Beacon Roots contract except the ring buffer logic
    /// @dev https://eips.ethereum.org/EIPS/eip-4788#pseudocode
    function _getBeaconRoot() internal view {
        // Check that call data size is 32 bytes
        require(msg.data.length == 32, "BeaconRootsMock: Invalid call data size");

        // Convert the call data to a uint256
        uint256 _beaconTimestamp;
        assembly {
            _beaconTimestamp := calldataload(0)
        }

        // Get the beacon root for the given timestamp
        bytes32 beaconRoot = beaconRoots[_beaconTimestamp];
        if (beaconRoot == 0) {
            // Revert if the beacon root is missing
            revert("BeaconRootsMock: Beacon root missing");
        }

        // Return the beacon root
        assembly {
            mstore(0, beaconRoot)
            return(0, 32)
        }
    }

    fallback() external {
        _getBeaconRoot();
    }
}
