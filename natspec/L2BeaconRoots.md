# L2BeaconRoots



> L2BeaconRoots

The L2BeaconRoots contract stores the beacon chain block roots on the L2



## Methods

### L1_BEACON_ROOTS_SENDER

```solidity
function L1_BEACON_ROOTS_SENDER() external view returns (address)
```

The L1BeaconRootsSender contract on the L1




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### MESSENGER

```solidity
function MESSENGER() external view returns (contract IL2CrossDomainMessenger)
```

The L1CrossDomainMessenger contract




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract IL2CrossDomainMessenger | undefined |

### beaconRoots

```solidity
function beaconRoots(uint256) external view returns (bytes32)
```

The beacon chain block roots stored by timestamps



#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### get

```solidity
function get(uint256 _beacon_timestamp) external view returns (bytes32)
```

Gets the beacon root for a given beacon chain timestamp



#### Parameters

| Name | Type | Description |
|---|---|---|
| _beacon_timestamp | uint256 | : The timestamp of the beacon chain block |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### init

```solidity
function init(address _l1BeaconRootsSender) external nonpayable
```

Initialize the contract with the L1BeaconRootsSender address.

*The flow is:       1) Deploy L2BeaconRoots on L2       2) Deploy L1BeaconRootsSender on L1 (passing the address of the deployed L2BeaconRoots to the constructor)       3) Initialize L2BeaconRoots with the L1BeaconRootsSender address*

#### Parameters

| Name | Type | Description |
|---|---|---|
| _l1BeaconRootsSender | address | : The address of the L1BeaconRootsSender contract |

### set

```solidity
function set(uint256 _beaconTimestamp, bytes32 _beaconRoot) external nonpayable
```

Sets the beacon root for a given beacon chain timestampThis function must be called by the L1BeaconRootsSender contract on L1 through the OP CrossDomainMessenger



#### Parameters

| Name | Type | Description |
|---|---|---|
| _beaconTimestamp | uint256 | : The timestamp of the beacon chain block |
| _beaconRoot | bytes32 | : The beacon chain block root at the given timestamp |



## Events

### BeaconRootSet

```solidity
event BeaconRootSet(uint256 timestamp, bytes32 blockRoot)
```

Event emitted when a beacon block root is setThe event can be emitted multiple times for the same block rootThe event can be emitted for block roots in the pastThe protocol does not guarantee that the event is emitted for every block root



#### Parameters

| Name | Type | Description |
|---|---|---|
| timestamp  | uint256 | : The timestamp of the beacon chain block |
| blockRoot  | bytes32 | : The beacon chain block root at the given timestamp |

### Initialized

```solidity
event Initialized(address _l1BeaconRootsSender)
```

Event emitted when the smart contract is initialized



#### Parameters

| Name | Type | Description |
|---|---|---|
| _l1BeaconRootsSender  | address | : The address of the L1BeaconRootsSender contract on L1 |



