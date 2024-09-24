# Kraken L2 Test

> **Note:** This is a take-home exercise for the Senior On-Chain Protocol Engineer position at Kraken (c.f. [guidelines](./docs/Protocol%20Engineer%20Take%20Home%20Test%20-%20Beacon%20Block%20Root%20on%20L2.pdf))

The Kraken L2 Test protocol exposes the L1 beacon chain block root within any L2 OP chain, enabling beacon chain data validation directly on L2.

By making the beacon chain root accessible on L2, it provides trust-minimized access to specific L1 beacon chain data directly on L2. This allows L2 contracts to securely interact with and manage L1 beacon chain data.

The protocol is compatible with all OP chains.

The protocol leverages [EIP-4788](https://eips.ethereum.org/EIPS/eip-4788), which exposes beacon chain roots to the L1 EVM, along with the OP canonical bridge to [facilitate data transmission between L1 and L2](https://docs.optimism.io/builders/app-developers/bridging/messaging).

# Contributing

See [Contributing Guidelines](./CONTRIBUTING.md)

# Deployment Addresses

| Contract | Optimism Sepolia (L2) | Sepolia (L1) |
|-|-|-|
| [L2BeaconRootsVerifier](./contracts/src/L2BeaconRootsVerifier.sol) | [0xe094C96145fe094D3Cb6bF05d8cFD08E92f11BE5](https://sepolia-optimism.etherscan.io/address/0xe094C96145fe094D3Cb6bF05d8cFD08E92f11BE5) | |
| [L2BeaconRoots](./contracts/src/L2BeaconRoots.sol) | [0xb53F763AB795e2A2C13613e25cc54939Ca01b4E1](https://sepolia-optimism.etherscan.io/address/0xb53F763AB795e2A2C13613e25cc54939Ca01b4E1) | |
| [L1BeaconRootsSender](./contracts/src/L1BeaconRootsSender.sol) | | [0x5cdF4C5cbe8b4412b319f5Ae28a77A7177B3adcA](https://sepolia.etherscan.io/address/0x5cdF4C5cbe8b4412b319f5Ae28a77A7177B3adcA) |

# Architecture Overview

## Diagram

![Architecture Diagram](./docs/Kraken%20Beacon%20Root%20Bridge%20Protocol%20v1.0.0.png)

## Components

### L1 Beacon Roots

The L1 Beacon Roots contract, as defined in [EIP-4788](https://eips.ethereum.org/EIPS/eip-4788), is an L1 system contract. With each new block, before any transactions are executed, this contract records the parent beacon block root, indexed by the block timestamp. These recorded roots are then accessible to other L1 smart contracts.

### L1BeaconRootsSender

This protocol contract on the L1 chain is responsible for relaying beacon block roots to the L2 chain through the OP canonical bridge. It provides public methods to send these roots by fetching them from the L1 Beacon Roots contract, preparing a cross-chain message for the OP bridge, and transmitting it to the L2 via the L1 CrossDomainMessenger.

### CrossDomainMessenger

The CrossDomainMessenger contracts on both L1 and L2 chains serve as the OP official bridge, facilitating data communication between L1 and L2. This protocol exclusively uses messaging from L1 to L2.

### L2BeaconRoots

The contract on the L2 network responsible to store and provide access to the beacon block roots. It receives beacon roots from the L1BeaconRootsSender via the L2 CrossDomainMessenger, upon message relaying it stores the beacon block roots.

### L2BeaconRootsVerifier

A contract on the L2 network that exposes functions to verify SSZ Merkle proofs for beacon blocks. In particular, it enables to verify withdrawals root. It reads the beacon roots from the L2BeaconRoots contract and perform SSZ Merkle proofs verifications against those roots.

## Security Considerations

### Enforcement of valid beacon roots sent by L1BeaconRootsSender

The L1BeaconRootsSender's methods for sending data are entirely programatic, and enforce fetching block roots from the official beacon roots contract before transmitting it to the L2. This ensures that only valid beacon block roots from the official L1 Beacon Roots contract are transmitted to the L2BeaconRoots contract. This allows the send methods to be public without compromising the protocol's security.

### Restriction of L2BeaconRoots set method

To guarantee that the L2BeaconRoots contract only stores valid beacon roots, its `set` method is restricted to the L2 CrossDomainMessenger, and only accepts messages from the designated L1BeaconRootsSender remote contract.

# Test Protocol

## Send the beacon block of the current block from L1 to L2

Before running the scripts, make sure to set the following environment variables:

- `ETH_RPC_URL_SEPOLIA`: RPC URL of a Sepolia network
- `PRIVATE_KEY_SEPOLIA`: The private key of an account with sufficient Sepolia ETH to cover transaction fees.

After setting the environment variables, execute the following command:

```sh
make send-current-beacon-root
```

## Generate Beacon Block Merkle proof for Withdrawals Root

Before running the scripts, make sure to set the following environment variables:

- `BEACON_URL`: Beacon node URL (Sepolia)

After setting the environment variables, execute the following command:

```sh
BLOCK_ID=<BLOCK_ID> make generate_proof
```

where `BLOCK_ID` is a valid Sepolia beacon block ID.

***Example***

```sh
BLOCK_ID="0x6cd96952b3dacfc7188b9ad9b17a2012b67827741f60b3c4e51a14f9d07f0c91" make generate-proof
```

should ouput

```json
{
  "root": "0x6cd96952b3dacfc7188b9ad9b17a2012b67827741f60b3c4e51a14f9d07f0c91", // beacon block root
  "leaf": "0x2e0130c856001a39482aa288f64f001a619dc46a5377b8c278776a41b3a62269", // here the leaf is the Withdrawals root
  "index": "0x192e", // the generalized index of the Withdrawals Root in the SSZ Merkle tree
  "proofs": [
    "0x0000060000000000000000000000000000000000000000000000000000000000",
    "0x1c81242091b62f06c68069f0574d78b7d5e2305ec0638d70aea9ddf4842f7cc2",
    "0xa9a30aed71d87b062cdaf6a68476d1fb88ba17824d33073fc0a47c14ee2f0542",
    "0xa55982c5098e75240dfa67589b6087b473360058919c1354f54fec07d0d54964",
    "0x2b075536cd68d87c6a42236945f8946ec654d1603cea26fd63fcfb714bc4e678",
    "0x13b46e5c802956f74b294cd43fee7f7fbe2786fa5234312142919ac6fba8122d",
    "0x94e05d13e26c028d1e415400d68a54fe931d72a5fe482dabf79d1c52dd82573a",
    "0xdb56114e00fdd4c1f85c892bf35ac9a89289aaecb1ebd0a96cde606a748b5d71",
    "0xb8704d40a68b6bddae5e2d83c5be32959491185c4e41a5e355181845922d000c",
    "0x0000000000000000000000000000000000000000000000000000000000000000",
    "0xf5a5fd42d16a20302798ef6ed309979b43003d2320d9f0e8ea9831a92759fb4b",
    "0xef91c6e7d3789ed96c6659a2641987fdeefee8c3fd6812f74ceeb258a3ce1561"
  ] // the proofs to prove the Merkle branch
}
```
