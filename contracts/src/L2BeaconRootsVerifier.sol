// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./libraries/BeaconBlockSSZMerkleProof.sol";
import "./L2BeaconRoots.sol";

/// @title L2BeaconRootsVerifier
/// @notice The L2BeaconRootsVerifier contract responsible for verifyring Beacon Block SSZ Merkle proofs
contract L2BeaconRootsVerifier {
    L2BeaconRoots public immutable L2_BEACON_ROOTS;

    /// @param _l2BeaconRoots: The address of the L2BeaconRoots contract
    constructor(address _l2BeaconRoots) {
        L2_BEACON_ROOTS = L2BeaconRoots(_l2BeaconRoots);
    }

    /// @notice Verifies a Withdrawals Root Merkle proof for a given timestamp
    /// @param _timestamp: The timestamp of the Beacon Block
    /// @param _proofs: The Merkle proof
    /// @param _withdrawalsRoot: The Withdrawals Root to verify
    function verify(uint256 _timestamp, bytes32[] memory _proofs, bytes32 _withdrawalsRoot)
        public
        view
        returns (bool)
    {
        // Retrieve the Beacon Root from L2BeaconRoots
        bytes32 _beaconRoot = L2_BEACON_ROOTS.get(_timestamp);
        require(_beaconRoot != bytes32(0), "L2BeaconRootsVerifier: Beacon root not found");

        // Verify the Withdrawals Root Merkle proof
        return BeaconBlockSSZMerkleProof._verifyWithdrawalsRootProof(_withdrawalsRoot, _proofs, _beaconRoot);
    }
}
