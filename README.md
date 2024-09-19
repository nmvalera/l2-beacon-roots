# Kraken L2 Test

> **Note:** This is a take-home exercise for the Senior On-Chain Protocol Engineer position at Kraken (c.f. [guidelines](./docs/Protocol%20Engineer%20Take%20Home%20Test%20-%20Beacon%20Block%20Root%20on%20L2.pdf))

The Kraken L2 Test protocol exposes the L1 beacon chain block root within any L2 OP chain, enabling beacon chain data validation directly on L2.

By making the beacon chain root accessible on L2, it provides trust-minimized access to specific L1 beacon chain data directly on L2. This allows L2 contracts to securely interact with and manage L1 beacon chain data.

The protocol is compatible with all OP chains.

The protocol leverages [EIP-4788](https://eips.ethereum.org/EIPS/eip-4788), which exposes beacon chain roots to the L1 EVM, along with the OP canonical bridge to [facilitate data transmission between L1 and L2](https://docs.optimism.io/builders/app-developers/bridging/messaging).
