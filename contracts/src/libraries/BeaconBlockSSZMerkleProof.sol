// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./SSZMerkleProof.sol";

/// @title BeaconBlockSSZMerkleProof
/// @notice Library for verifying Beacon Block SSZ Merkle proofs
library BeaconBlockSSZMerkleProof {
    uint256 internal constant WITHRAWAL_ROOT_GENERALIZED_INDEX = 0x192e;

    /// @notice The depth of the Withdrawals Root in the Beacon Block SSZ Merkle tree
    uint256 internal constant WITHRAWAL_ROOT_GENERALIZED_INDEX_DEPTH = 0xc;

    /// @notice Verifies a Withdrawals Root Merkle proof
    /// @param _withdrawalsRoot: The Withdrawals Root to verify
    /// @param _proofs: The Merkle proof
    /// @param _beaconRoot: The Beacon Root to verify against
    /// @return True if the proof is valid, false otherwise
    function _verifyWithdrawalsRootProof(bytes32 _withdrawalsRoot, bytes32[] memory _proofs, bytes32 _beaconRoot)
        internal
        pure
        returns (bool)
    {
        require(_proofs.length == WITHRAWAL_ROOT_GENERALIZED_INDEX_DEPTH, "L2BeaconRootVerifier: Invalid proof length");
        return SSZMerkleProof._verify(_proofs, _beaconRoot, _withdrawalsRoot, WITHRAWAL_ROOT_GENERALIZED_INDEX);
    }
}
