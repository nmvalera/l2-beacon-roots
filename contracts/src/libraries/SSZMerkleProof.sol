// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SSZMerkleProof
/// @notice Library for verifying SSZ Merkle proofs
library SSZMerkleProof {
    /// @notice Verifies an SSZ Merkle proof for a branch
    /// @param _proofs: The Merkle proofs
    /// @param _root: The root hash to verify against
    /// @param _leaf: The leaf value to verify
    /// @param _index: The generalized index of the leaf in the SSZ tree
    function _verify(bytes32[] memory _proofs, bytes32 _root, bytes32 _leaf, uint256 _index)
        internal
        pure
        returns (bool)
    {
        return _processProof(_proofs, _leaf, _index) == _root;
    }

    /// @notice Computes the root hash of a Merkle branch in a SSZ tree
    /// @param _proofs: The Merkle proofs
    /// @param _leaf: The leaf value
    /// @param _index: The generalized index of the leaf in the SSZ tree
    function _processProof(bytes32[] memory _proofs, bytes32 _leaf, uint256 _index) internal pure returns (bytes32) {
        // Compute the root hash of the Merkle branch
        bytes32 computedHash = _leaf;
        for (uint256 i = 0; i < _proofs.length; i++) {
            // if i-th bit of WITHRAWAL_ROOT_GENERALIZED_INDEX is set to 1,
            // then the computedHash is the right child
            // otherwise it is the left child
            if (_index & (1 << i) == (1 << i)) {
                computedHash = _efficientSha256(_proofs[i], computedHash);
            } else {
                computedHash = _efficientSha256(computedHash, _proofs[i]);
            }
        }
        return computedHash;
    }

    function _efficientSha256(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        bytes memory pack = new bytes(64);
        assembly {
            mstore(add(pack, 32), a)
            mstore(add(pack, 64), b)
        }
        return sha256(pack);
    }
}
