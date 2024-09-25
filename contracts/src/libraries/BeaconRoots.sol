// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SSZMerkleProof
/// @notice Library for verifying SSZ Merkle proofs
library BeaconRoots {
    function _get(address _beaconRoots, uint256 _timestamp) internal view returns (bytes32) {
        (bool success, bytes memory result) = _beaconRoots.staticcall(abi.encode(_timestamp));
        if (success && result.length > 0) {
            return abi.decode(result, (bytes32));
        } else {
            return bytes32(0);
        }
    }
}
