//SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import "./mocks/BeaconRootsMock.sol";
import "../src/BeaconRootsVerifier.sol";

contract BeaconRootsVerifierTest is Test {
    // L2BeaconRoots instance
    BeaconRootsMock public beaconRootsMock;
    BeaconRootsVerifier public beaconRootsVerifier;

    function setUp() public {
        beaconRootsMock = new BeaconRootsMock();
        beaconRootsVerifier = new BeaconRootsVerifier(address(beaconRootsMock));
    }

    function setMockBeaconRootForTimestamp(uint256 _timestamp, bytes32 _root) internal {
        beaconRootsMock.givenTimespampReturn(_timestamp, _root);
    }

    function test_verify() public {
        uint256 timestamp = 1000;
        bytes32 beaconRoot = bytes32(0x6cd96952b3dacfc7188b9ad9b17a2012b67827741f60b3c4e51a14f9d07f0c91);
        bytes32 withdrawalsRoot = bytes32(0x2e0130c856001a39482aa288f64f001a619dc46a5377b8c278776a41b3a62269);

        bytes32[] memory proofs = new bytes32[](12);
        proofs[0] = bytes32(uint256(0x0000060000000000000000000000000000000000000000000000000000000000));
        proofs[1] = bytes32(uint256(0x1c81242091b62f06c68069f0574d78b7d5e2305ec0638d70aea9ddf4842f7cc2));
        proofs[2] = bytes32(uint256(0xa9a30aed71d87b062cdaf6a68476d1fb88ba17824d33073fc0a47c14ee2f0542));
        proofs[3] = bytes32(uint256(0xa55982c5098e75240dfa67589b6087b473360058919c1354f54fec07d0d54964));
        proofs[4] = bytes32(uint256(0x2b075536cd68d87c6a42236945f8946ec654d1603cea26fd63fcfb714bc4e678));
        proofs[5] = bytes32(uint256(0x13b46e5c802956f74b294cd43fee7f7fbe2786fa5234312142919ac6fba8122d));
        proofs[6] = bytes32(uint256(0x94e05d13e26c028d1e415400d68a54fe931d72a5fe482dabf79d1c52dd82573a));
        proofs[7] = bytes32(uint256(0xdb56114e00fdd4c1f85c892bf35ac9a89289aaecb1ebd0a96cde606a748b5d71));
        proofs[8] = bytes32(uint256(0xb8704d40a68b6bddae5e2d83c5be32959491185c4e41a5e355181845922d000c));
        proofs[9] = bytes32(uint256(0x0000000000000000000000000000000000000000000000000000000000000000));
        proofs[10] = bytes32(uint256(0xf5a5fd42d16a20302798ef6ed309979b43003d2320d9f0e8ea9831a92759fb4b));
        proofs[11] = bytes32(uint256(0xef91c6e7d3789ed96c6659a2641987fdeefee8c3fd6812f74ceeb258a3ce1561));

        setMockBeaconRootForTimestamp(timestamp, beaconRoot);

        // Check that the beacon root was set
        assertTrue(beaconRootsVerifier.verify(timestamp, proofs, withdrawalsRoot));
    }

    function test_verify_FailWhenInvalidProof() public {
        uint256 timestamp = 1000;
        bytes32 beaconRoot = bytes32(0x6cd96952b3dacfc7188b9ad9b17a2012b67827741f60b3c4e51a14f9d07f0c91);
        bytes32 withdrawalsRoot = bytes32(0x2e0130c856001a39482aa288f64f001a619dc46a5377b8c278776a41b3a62269);

        bytes32[] memory proofs = new bytes32[](12);
        proofs[0] = bytes32(uint256(0x0000060000000000000000000000000000000000000000000000000000000000));
        proofs[1] = bytes32(uint256(0x1c81242091b62f06c68069f0574d78b7d5e2305ec0638d70aea9ddf4842f7cc2));
        proofs[2] = bytes32(uint256(0xa9a30aed71d87b062cdaf6a68476d1fb88ba17824d33073fc0a47c14ee2f0542));
        proofs[3] = bytes32(uint256(0xa55982c5098e75240dfa67589b6087b473360058919c1354f54fec07d0d54964));
        proofs[4] = bytes32(uint256(0x2b075536cd68d87c6a42236945f8946ec654d1603cea26fd63fcfb714bc4e678));
        proofs[5] = bytes32(uint256(0x13b46e5c802956f74b294cd43fee7f7fbe2786fa5234312142919ac6fba8122d));
        proofs[6] = bytes32(uint256(0x94e05d13e26c028d1e415400d68a54fe931d72a5fe482dabf79d1c52dd82573a));
        proofs[7] = bytes32(uint256(0xdb56114e00fdd4c1f85c892bf35ac9a89289aaecb1ebd0a96cde606a748b5d71));
        proofs[8] = bytes32(uint256(0xb8704d40a68b6bddae5e2d83c5be32959491185c4e41a5e355181845922d000c));
        proofs[9] = bytes32(uint256(0x0000000000000000000000000000000000000000000000000000000000000000));
        proofs[10] = bytes32(uint256(0xf5a5fd42d16a20302798ef6ed309979b43003d2320d9f0e8ea9831a92759fb4b));
        // Invalid proof at position 11
        proofs[11] = bytes32(uint256(0xf5a5fd42d16a20302798ef6ed309979b43003d2320d9f0e8ea9831a92759fb4b));

        setMockBeaconRootForTimestamp(timestamp, beaconRoot);

        // Check that the beacon root was set
        assertFalse(beaconRootsVerifier.verify(timestamp, proofs, withdrawalsRoot));
    }

    function test_verify_FailWhenInvalidBeaconRoot() public {
        uint256 timestamp = 1000;

        // Invalid beacon root
        bytes32 beaconRoot = bytes32(0x2e0130c856001a39482aa288f64f001a619dc46a5377b8c278776a41b3a62269);
        bytes32 withdrawalsRoot = bytes32(0x2e0130c856001a39482aa288f64f001a619dc46a5377b8c278776a41b3a62269);

        bytes32[] memory proofs = new bytes32[](12);
        proofs[0] = bytes32(uint256(0x0000060000000000000000000000000000000000000000000000000000000000));
        proofs[1] = bytes32(uint256(0x1c81242091b62f06c68069f0574d78b7d5e2305ec0638d70aea9ddf4842f7cc2));
        proofs[2] = bytes32(uint256(0xa9a30aed71d87b062cdaf6a68476d1fb88ba17824d33073fc0a47c14ee2f0542));
        proofs[3] = bytes32(uint256(0xa55982c5098e75240dfa67589b6087b473360058919c1354f54fec07d0d54964));
        proofs[4] = bytes32(uint256(0x2b075536cd68d87c6a42236945f8946ec654d1603cea26fd63fcfb714bc4e678));
        proofs[5] = bytes32(uint256(0x13b46e5c802956f74b294cd43fee7f7fbe2786fa5234312142919ac6fba8122d));
        proofs[6] = bytes32(uint256(0x94e05d13e26c028d1e415400d68a54fe931d72a5fe482dabf79d1c52dd82573a));
        proofs[7] = bytes32(uint256(0xdb56114e00fdd4c1f85c892bf35ac9a89289aaecb1ebd0a96cde606a748b5d71));
        proofs[8] = bytes32(uint256(0xb8704d40a68b6bddae5e2d83c5be32959491185c4e41a5e355181845922d000c));
        proofs[9] = bytes32(uint256(0x0000000000000000000000000000000000000000000000000000000000000000));
        proofs[10] = bytes32(uint256(0xf5a5fd42d16a20302798ef6ed309979b43003d2320d9f0e8ea9831a92759fb4b));
        proofs[11] = bytes32(uint256(0xef91c6e7d3789ed96c6659a2641987fdeefee8c3fd6812f74ceeb258a3ce1561));

        setMockBeaconRootForTimestamp(timestamp, beaconRoot);

        // Check that the beacon root was set
        assertFalse(beaconRootsVerifier.verify(timestamp, proofs, withdrawalsRoot));
    }

    function test_verify_FailWhenInvalidWithdrawalsRoot() public {
        uint256 timestamp = 1000;
        bytes32 beaconRoot = bytes32(0x6cd96952b3dacfc7188b9ad9b17a2012b67827741f60b3c4e51a14f9d07f0c91);

        // Invalid withdrawals root
        bytes32 withdrawalsRoot = bytes32(0x6cd96952b3dacfc7188b9ad9b17a2012b67827741f60b3c4e51a14f9d07f0c91);

        bytes32[] memory proofs = new bytes32[](12);
        proofs[0] = bytes32(uint256(0x0000060000000000000000000000000000000000000000000000000000000000));
        proofs[1] = bytes32(uint256(0x1c81242091b62f06c68069f0574d78b7d5e2305ec0638d70aea9ddf4842f7cc2));
        proofs[2] = bytes32(uint256(0xa9a30aed71d87b062cdaf6a68476d1fb88ba17824d33073fc0a47c14ee2f0542));
        proofs[3] = bytes32(uint256(0xa55982c5098e75240dfa67589b6087b473360058919c1354f54fec07d0d54964));
        proofs[4] = bytes32(uint256(0x2b075536cd68d87c6a42236945f8946ec654d1603cea26fd63fcfb714bc4e678));
        proofs[5] = bytes32(uint256(0x13b46e5c802956f74b294cd43fee7f7fbe2786fa5234312142919ac6fba8122d));
        proofs[6] = bytes32(uint256(0x94e05d13e26c028d1e415400d68a54fe931d72a5fe482dabf79d1c52dd82573a));
        proofs[7] = bytes32(uint256(0xdb56114e00fdd4c1f85c892bf35ac9a89289aaecb1ebd0a96cde606a748b5d71));
        proofs[8] = bytes32(uint256(0xb8704d40a68b6bddae5e2d83c5be32959491185c4e41a5e355181845922d000c));
        proofs[9] = bytes32(uint256(0x0000000000000000000000000000000000000000000000000000000000000000));
        proofs[10] = bytes32(uint256(0xf5a5fd42d16a20302798ef6ed309979b43003d2320d9f0e8ea9831a92759fb4b));
        proofs[11] = bytes32(uint256(0xef91c6e7d3789ed96c6659a2641987fdeefee8c3fd6812f74ceeb258a3ce1561));

        setMockBeaconRootForTimestamp(timestamp, beaconRoot);

        // Check that the beacon root was set
        assertFalse(beaconRootsVerifier.verify(timestamp, proofs, withdrawalsRoot));
    }
}
