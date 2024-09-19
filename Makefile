.PHONY: foundry install test test-lint lint

# Install foundry
foundry:
	echo "Install foundry"
	curl -L https://foundry.paradigm.xyz | bash
	foundryup 

# Install development dependencies
install: foundry

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