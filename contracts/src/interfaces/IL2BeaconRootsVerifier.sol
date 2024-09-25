// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IL2BeaconRootsVerifier
/// @notice The interface of L2BeaconRootsVerifier  responsible for verifying Beacon Block SSZ Merkle proofs
interface IL2BeaconRootsVerifier {
    /// @notice Verifies a Withdrawals Root Merkle proof for a given timestamp
    /// @param _timestamp: The timestamp of the Beacon Block
    /// @param _proofs: The Merkle proof
    /// @param _withdrawalsRoot: The Withdrawals Root to verify
    function verify(uint256 _timestamp, bytes32[] memory _proofs, bytes32 _withdrawalsRoot)
        external
        view
        returns (bool);

    // @notice Returns the address of the BeaconRoots contract
    function getBeaconRoots() external view returns (address);
}
