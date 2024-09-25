// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./libraries/BeaconBlockSSZMerkleProof.sol";
import "./libraries/BeaconRoots.sol";
import "./interfaces/IBeaconRootsVerifier.sol";

/// @title BeaconRootsVerifier
/// @notice The BeaconRootsVerifier contract responsible for verifyring Beacon Block SSZ Merkle proofs
contract BeaconRootsVerifier is IBeaconRootsVerifier {
    /// @notice The address of the BeaconRoots contract to retrieve Beacon Block roots from
    address internal immutable BEACON_ROOTS;

    /// @param _beaconRoots: The address of the L2BeaconRoots contract
    constructor(address _beaconRoots) {
        BEACON_ROOTS = _beaconRoots;
    }

    /// @inheritdoc IBeaconRootsVerifier
    function verify(uint256 _timestamp, bytes32[] memory _proofs, bytes32 _withdrawalsRoot)
        public
        view
        returns (bool)
    {
        // Retrieve the Beacon Root from L2BeaconRoots
        bytes32 _beaconRoot = _getBlockRoot(_timestamp);
        require(_beaconRoot != bytes32(0), "L2BeaconRootsVerifier: Beacon root not found");

        // Verify the Withdrawals Root Merkle proof
        return BeaconBlockSSZMerkleProof._verifyWithdrawalsRootProof(_withdrawalsRoot, _proofs, _beaconRoot);
    }

    /// @notice Retrieves a beacon block root from the official beacon roots contract (EIP-4788)
    /// @param _timestamp: The timestamp of the beacon chain block
    function _getBlockRoot(uint256 _timestamp) internal view returns (bytes32 blockRoot) {
        return BeaconRoots._get(BEACON_ROOTS, _timestamp);
    }

    /// @inheritdoc IBeaconRootsVerifier
    function getBeaconRoots() external view returns (address) {
        return BEACON_ROOTS;
    }
}
