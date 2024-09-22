# L1BeaconRootsSender



> L1BeaconRootsSender

The L1BeaconRootsSender contract sends the beacon chain block roots to the L2BeaconRoots contract on the L2



## Methods

### L1_MESSENGER

```solidity
function L1_MESSENGER() external view returns (contract IL1CrossDomainMessenger)
```

The OP L1CrossDomainMessenger contract




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract IL1CrossDomainMessenger | undefined |

### L2_BEACON_ROOTS

```solidity
function L2_BEACON_ROOTS() external view returns (contract L2BeaconRoots)
```

The L2BeaconRoots contract on the L2




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract L2BeaconRoots | undefined |

### L2_BEACON_ROOTS_SET_GAS_LIMIT

```solidity
function L2_BEACON_ROOTS_SET_GAS_LIMIT() external view returns (uint32)
```

The required gas limit for executing the set function on the L2BeaconRoots contract




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint32 | undefined |

### sendBlockRoot

```solidity
function sendBlockRoot(uint256 _timestamp) external nonpayable
```

Sends a beacon block root to the L2Retrieves the block root from the official beacon roots contract and sends it to the L2



#### Parameters

| Name | Type | Description |
|---|---|---|
| _timestamp | uint256 | : The timestamp of the beacon chain block |

### sendCurrentBlockRoot

```solidity
function sendCurrentBlockRoot() external nonpayable
```

Sends beacon block root of the current block to the L2Retrieves the block root from the official beacon roots contract and sends it to the L2The beacon block root is for the parent beacon chain slot of the current block






## Events

### BlockRootSent

```solidity
event BlockRootSent(uint256 timestamp, bytes32 blockRoot)
```

Event emitted when a block root is sent to the L2The event can be emitted multiple times for the same block rootThe event can be emitted for block roots in the pastThe protocol does not guarantee that the event is emitted for every block root



#### Parameters

| Name | Type | Description |
|---|---|---|
| timestamp  | uint256 | : The timestamp of the beacon chain block |
| blockRoot  | bytes32 | : The beacon chain block root at the given timestamp |



## Errors

### BeaconRootMissing

```solidity
error BeaconRootMissing()
```

Beacont root is missing for the given timestamp.




### TimestampInTheFuture

```solidity
error TimestampInTheFuture()
```

Timestamp is in the future




### TimestampOutOfRing

```solidity
error TimestampOutOfRing()
```

Timestamp out of range for the the beacon roots buffer ring.





