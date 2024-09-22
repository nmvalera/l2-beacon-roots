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

### Deploy on Sepolia

Before running the scripts, make sure to set the following environment variables:

- `ETH_RPC_URL_SEPOLIA`: The RPC URL for the Sepolia network.
- `ETH_RPC_URL_OP_SEPOLIA`: The RPC URL for the Optimism Sepolia network.
- `DEPLOYER_PRIVATE_KEY_SEPOLIA`: The private key of an account with sufficient Sepolia ETH to cover deployment fees. Note that this account will not retain ownership of the deployed contracts.
- `DEPLOYER_PRIVATE_KEY_OP_SEPOLIA`: The private key of an account with sufficient Optimism Sepolia ETH to cover deployment fees. Note that this account will not retain ownership of the deployed contracts.
- `ETHERSCAN_API_KEY_SEPOLIA`: The API key for Ethereum Etherscan. This is used for smart contract verification.
- `ETHERSCAN_API_KEY_OP_SEPOLIA`: The API key for Optimism Etherscan. This is used for smart contract verification.

After setting the environment variables, execute the following command:

```sh
make deploy
```