# Contributing Guidelines

## Scripts

### Install Development Environment

```sh
make install
```

### Run tests

```sh
make test
```

### Run linting checks

```sh
make test-lint
```

### Deploy

You need to define the following environment variable before running the scripts

- `DEPLOYER_PRIVATE_KEY_SEPOLIA` the private key of an account with enough Sepolia ETH to cover deployment fees. Note that the deployment account has no ownership on the contracts deployed
- `DEPLOYER_PRIVATE_KEY_OP_SEPOLIA` the private key of an account with enough Optimism Sepolia ETH to cover deployment fees. Note that the deployment account has no ownership on the contracts deployed
- `ETHERSCAN_API_KEY_SEPOLIA` an Ethereum Etherscan API Key. Note: this is used for smart contract verification
- `ETHERSCAN_API_KEY_OP_SEPOLIA` an Optimism Etherscan API Key. Note: this is used for smart contract verification

#### Local

To deploy the contracts in an ephemeral EVM instance, run

```sh
make deploy
```