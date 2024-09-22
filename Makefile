.PHONY: foundry install test test-lint lint deploy

# Install foundry
foundry:
	echo "Install foundry"
	curl -L https://foundry.paradigm.xyz | bash
	foundryup 

# Pull libraries submodules
lib:
	git submodule update --init --recursive 

yarn:
	yarn && yarn link_contracts

# Install development dependencies
install: foundry lib yarn

# Run tests
test:
	forge test -vvv --gas-report

# Run lint tests
test-lint:
	forge build --force
	forge fmt --check

# Run lint
lint:
	forge build --force
	forge fmt

# Deploy
deploy:
	yarn hh deploy --network optimismSepolia
	yarn hh deploy --network sepolia

# Send Beacon Root from L1 to L2
send-current-beacon-root:
	@cast send --gas-limit 130000 --rpc-url ${ETH_RPC_URL_SEPOLIA} --private-key ${PRIVATE_KEY_SEPOLIA} 0x5cdF4C5cbe8b4412b319f5Ae28a77A7177B3adcA "sendCurrentBlockRoot()"
