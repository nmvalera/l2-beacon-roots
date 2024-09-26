// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SSZMerkleProof
/// @notice Library for verifying SSZ Merkle proofs
library BeaconRoots {
    function _get(address _beaconRoots, uint256 _timestamp) internal view returns (bytes32 beaconRoot) {
        assembly {
            let data := mload(0x40)
            mstore(data, _timestamp)
            pop(staticcall(gas(), _beaconRoots, data, 0x20, data, 0x20))
            if eq(returndatasize(), 0x20) { beaconRoot := mload(data) }
        }
    }
}
