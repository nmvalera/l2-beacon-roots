# IL1BeaconRootsSender



> IL1BeaconRootsSender

The L1BeaconRootsSender contract sends the beacon chain block roots to the L2BeaconRoots contract on the L2



## Methods

### getCrossDomainMessenger

```solidity
function getCrossDomainMessenger() external view returns (address)
```

Retrieves the address of the CrossDomainMessenger contract on the L1




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### getL2BeaconRoots

```solidity
function getL2BeaconRoots() external view returns (address)
```

Retrieves the address of the L2BeaconRoots contract on the L2




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

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





