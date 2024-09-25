// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./libraries/BeaconBlockSSZMerkleProof.sol";
import "./interfaces/IL2BeaconRootsVerifier.sol";
import "./interfaces/IL2BeaconRoots.sol";

/// @title L2BeaconRootsVerifier
/// @notice The L2BeaconRootsVerifier contract responsible for verifyring Beacon Block SSZ Merkle proofs
contract L2BeaconRootsVerifier is IL2BeaconRootsVerifier {
    address internal immutable L2_BEACON_ROOTS;

    /// @param _l2BeaconRoots: The address of the L2BeaconRoots contract
    constructor(address _l2BeaconRoots) {
        L2_BEACON_ROOTS = _l2BeaconRoots;
    }

    /// @inheritdoc IL2BeaconRootsVerifier
    function verify(uint256 _timestamp, bytes32[] memory _proofs, bytes32 _withdrawalsRoot)
        public
        view
        returns (bool)
    {
        // Retrieve the Beacon Root from L2BeaconRoots
        bytes32 _beaconRoot = IL2BeaconRoots(L2_BEACON_ROOTS).get(_timestamp);
        require(_beaconRoot != bytes32(0), "L2BeaconRootsVerifier: Beacon root not found");

        // Verify the Withdrawals Root Merkle proof
        return BeaconBlockSSZMerkleProof._verifyWithdrawalsRootProof(_withdrawalsRoot, _proofs, _beaconRoot);
    }

    /// @inheritdoc IL2BeaconRootsVerifier
    function getBeaconRoots() external view returns (address) {
        return L2_BEACON_ROOTS;
    }
}
