// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SSZMerkleProof
/// @notice Library for verifying SSZ Merkle proofs
library BeaconRoots {
    function _get(address _beaconRoots, uint256 _timestamp) internal view returns (bytes32 beaconRoot) {
        assembly {
            mstore(0, _timestamp)
            pop(staticcall(gas(), _beaconRoots, 0, 0x20, 0, 0x20))
            if eq(returndatasize(), 0x20) {
                beaconRoot := mload(0)
            }
        }
    }
}
