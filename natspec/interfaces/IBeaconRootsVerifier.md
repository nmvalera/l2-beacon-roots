# IBeaconRootsVerifier



> IBeaconRootsVerifier

The interface of BeaconRootsVerifier  responsible for verifying Beacon Block SSZ Merkle proofs



## Methods

### getBeaconRoots

```solidity
function getBeaconRoots() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### verify

```solidity
function verify(uint256 _timestamp, bytes32[] _proofs, bytes32 _withdrawalsRoot) external view returns (bool)
```

Verifies a Withdrawals Root Merkle proof for a given timestamp



#### Parameters

| Name | Type | Description |
|---|---|---|
| _timestamp | uint256 | : The timestamp of the Beacon Block |
| _proofs | bytes32[] | : The Merkle proof |
| _withdrawalsRoot | bytes32 | : The Withdrawals Root to verify |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |




