.PHONY: foundry install test test-lint lint deploy generate-proof

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
	@cast send --gas-limit 130000 --rpc-url ${ETH_RPC_URL_SEPOLIA} --private-key ${PRIVATE_KEY_SEPOLIA} 0xB5c70f0CD8Ca5738E555FB76E9f1B82BF254fc5b "sendCurrentBlockRoot()"

# Generate SSZ Merkle proof for a beacon block
generate-proof:
	cd cli && go run . generate-proof $(BLOCK_ID) | jq