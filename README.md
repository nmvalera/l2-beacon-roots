# Kraken L2 Test

> **Note:** This is a take-home exercise for the Senior On-Chain Protocol Engineer position at Kraken (c.f. [guidelines](./docs/Protocol%20Engineer%20Take%20Home%20Test%20-%20Beacon%20Block%20Root%20on%20L2.pdf))

The Kraken L2 Test protocol exposes the L1 beacon chain block root within any L2 OP chain, enabling beacon chain data validation directly on L2.

By making the beacon chain root accessible on L2, it provides trust-minimized access to specific L1 beacon chain data directly on L2. This allows L2 contracts to securely interact with and manage L1 beacon chain data.

The protocol is compatible with all OP chains.

The protocol leverages [EIP-4788](https://eips.ethereum.org/EIPS/eip-4788), which exposes beacon chain roots to the L1 EVM, along with the OP canonical bridge to [facilitate data transmission between L1 and L2](https://docs.optimism.io/builders/app-developers/bridging/messaging).

# Contributing

See [Contributing Guidelines](./CONTRIBUTING.md)

# Architecture Overview

## Diagram

![Architecture Diagram](./docs/Kraken%20Beacon%20Root%20Bridge%20Protocol%20v0.1.0.png)

## Components

### L1 Beacon Roots

The L1 Beacon Roots contract, as defined in [EIP-4788](https://eips.ethereum.org/EIPS/eip-4788), is an L1 system contract. With each new block, before any transactions are executed, this contract records the parent beacon block root, indexed by the block timestamp. These recorded roots are then accessible to other L1 smart contracts.

### L1BeaconRootsSender

This protocol contract on the L1 chain is responsible for relaying beacon block roots to the L2 chain through the OP canonical bridge. It provides public methods to send these roots by fetching them from the L1 Beacon Roots contract, preparing a cross-chain message for the OP bridge, and transmitting it to the L2 via the L1 CrossDomainMessenger.

### CrossDomainMessenger

The CrossDomainMessenger contracts on both L1 and L2 chains serve as the OP official bridge, facilitating data communication between L1 and L2. This protocol exclusively uses messaging from L1 to L2.

### L2BeaconRoots

The contract on the L2 network responsible to store and provide access to the beacon block roots. It receives beacon roots from the L1BeaconRootsSender via the L2 CrossDomainMessenger, upon message relaying it stores the beacon block roots.

## Security Considerations

### Enforcement of valid beacon roots sent by L1BeaconRootsSender

The L1BeaconRootsSender's methods for sending data are entirely programatic, and enforce fetching block roots from the official beacon roots contract before transmitting it to the L2. This ensures that only valid beacon block roots from the official L1 Beacon Roots contract are transmitted to the L2BeaconRoots contract. This allows the send methods to be public without compromising the protocol's security.

### Restriction of L2BeaconRoots set method

To guarantee that the L2BeaconRoots contract only stores valid beacon roots, its `set` method is restricted to the L2 CrossDomainMessenger, and only accepts messages from the designated L1BeaconRootsSender remote contract.