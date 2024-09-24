package ssz

import (
	ssz "github.com/prysmaticlabs/fastssz"
	sszencoding "github.com/prysmaticlabs/prysm/v5/encoding/ssz"
	v11 "github.com/prysmaticlabs/prysm/v5/proto/engine/v1"
	v2 "github.com/prysmaticlabs/prysm/v5/proto/eth/v2"
)

type BeaconBlockDenebTree struct {
	tree *ssz.Node
}

// ConstructBeaconBlockDenebTree constructs a SSZ tree for a Beacon block
func ConstructBeaconBlockDenebTree(block *v2.BeaconBlockDeneb) (*BeaconBlockDenebTree, error) {
	tree, err := constructBeaconBlockDenebTree(block)
	if err != nil {
		return nil, err
	}

	return &BeaconBlockDenebTree{tree: tree}, nil
}

// Hash returns the root hash of the SSZ tree
func (t *BeaconBlockDenebTree) Hash() []byte {
	return t.tree.Hash()
}

func (t *BeaconBlockDenebTree) Prove(idx int) (*ssz.Proof, error) {
	proof, err := t.tree.Prove(idx)
	if err != nil {
		return nil, err
	}
	if len(proof.Leaf) == 0 {
		node, err := t.tree.Get(idx)
		if err != nil {
			return nil, err
		}
		proof.Leaf = node.Hash()
	}

	return proof, nil
}

// General Index of the withdrawals root in the block SSZ tree
// Path: leaf 4/8 -> leaf 9/16 -> leaf 14/32
const WITHDRAWALS_ROOT_GENERAL_INDEX = ((8+4)*16+9)*32 + 14 // = 6446

// GetWithdrawalRoot retrieves the withdrawal root from  SSZ tree
func (t *BeaconBlockDenebTree) GetWithdrawalRoot() ([]byte, error) {
	node, err := t.tree.Get(WITHDRAWALS_ROOT_GENERAL_INDEX)
	if err != nil {
		return []byte{}, err
	}

	return node.Hash(), nil
}

// ProveWithdrawalsRoot generates a proof for the withdrawals root
func (t *BeaconBlockDenebTree) ProveWithdrawalsRoot() (*ssz.Proof, error) {
	return t.Prove(6)
}

// constructBeaconBlockDenebTree constructs a SSZ tree for a Beacon block
// The final tree holds 3 layers: BeaconBlock -> BeaconBlockBody -> ExecutionPayload
func constructBeaconBlockDenebTree(block *v2.BeaconBlockDeneb) (*ssz.Node, error) {
	leaves := make([]*ssz.Node, 8)

	// Leaf (0) - Slot
	leaves[0] = ssz.LeafFromUint64(uint64(block.Slot))

	// Leaf (1) - Proposer Index
	leaves[1] = ssz.LeafFromUint64(uint64(block.ProposerIndex))

	// Leaf (2) - Parent Root
	leaves[2] = ssz.LeafFromBytes(block.ParentRoot[:])

	// Leaf (3) - State Root
	leaves[3] = ssz.LeafFromBytes(block.StateRoot[:])

	// Leaf (4) - Body
	bodyTree, err := constructBeaconBlockBodyDenebTree(block.Body)
	if err != nil {
		return nil, err
	}
	leaves[4] = bodyTree

	// Leaf (5,6,7) - Empty
	leaves[5] = ssz.EmptyLeaf()
	leaves[6] = ssz.EmptyLeaf()
	leaves[7] = ssz.EmptyLeaf()

	return ssz.TreeFromNodes(leaves)
}

// constructBeaconBlockBodyDenebTree constructs a SSZ tree for a Beacon block body
// The final tree holds 2 layers: BeaconBlockBody -> ExecutionPayload
func constructBeaconBlockBodyDenebTree(blockBody *v2.BeaconBlockBodyDeneb) (*ssz.Node, error) {
	leaves := make([]*ssz.Node, 16)

	// Lead (0) - Randao Reveal
	randaoRoot, err := sszencoding.MerkleizeByteSliceSSZ(blockBody.RandaoReveal[:])
	if err != nil {
		return nil, err
	}
	leaves[0] = ssz.LeafFromBytes(randaoRoot[:])

	// Leaf (1) - Eth1 Data
	eth1Data, err := blockBody.Eth1Data.HashTreeRoot()
	if err != nil {
		return nil, err
	}
	leaves[1] = ssz.LeafFromBytes(eth1Data[:])

	// Leaf (2) - Graffiti
	leaves[2] = ssz.LeafFromBytes(blockBody.Graffiti[:])

	// Leaf (3) - Proposer Slashings
	proposerSlashingsRoot, err := sszencoding.MerkleizeListSSZ(blockBody.ProposerSlashings, 16)
	if err != nil {
		return nil, err
	}
	leaves[3] = ssz.LeafFromBytes(proposerSlashingsRoot[:])

	// Leaf (4) - Attester Slashings
	attesterSlashingsRoot, err := sszencoding.MerkleizeListSSZ(blockBody.AttesterSlashings, 2)
	if err != nil {
		return nil, err
	}
	leaves[4] = ssz.LeafFromBytes(attesterSlashingsRoot[:])

	// Leaf (5) - Attestations
	attestationsRoot, err := sszencoding.MerkleizeListSSZ(blockBody.Attestations, 128)
	if err != nil {
		return nil, err
	}
	leaves[5] = ssz.LeafFromBytes(attestationsRoot[:])

	// Leaf (6) - Deposits
	depositsRoot, err := sszencoding.MerkleizeListSSZ(blockBody.Deposits, 16)
	if err != nil {
		return nil, err
	}
	leaves[6] = ssz.LeafFromBytes(depositsRoot[:])

	// Leaf (7) - Voluntary Exits
	voluntaryExitsRoot, err := sszencoding.MerkleizeListSSZ(blockBody.VoluntaryExits, 16)
	if err != nil {
		return nil, err
	}
	leaves[7] = ssz.LeafFromBytes(voluntaryExitsRoot[:])

	// Leaf (8) - Sync Aggregate
	syncAggregateRoot, err := blockBody.SyncAggregate.HashTreeRoot()
	if err != nil {
		return nil, err
	}
	leaves[8] = ssz.LeafFromBytes(syncAggregateRoot[:])

	// Leaf (9) - ExecutionPayload
	executionPayloadNode, err := constructExecutionPayloadDenebTree(blockBody.ExecutionPayload)
	if err != nil {
		return nil, err
	}
	leaves[9] = executionPayloadNode

	// Leaf (10) - BlsToExecutionChanges
	blsToExecutionChangesRoot, err := sszencoding.MerkleizeListSSZ(blockBody.BlsToExecutionChanges, 16)
	if err != nil {
		return nil, err
	}
	leaves[10] = ssz.LeafFromBytes(blsToExecutionChangesRoot[:])

	// Leaf (11) - BlobKzgCommitments
	blobKzgCommitmentsRoot, err := KzgCommitmentsRoot(blockBody.BlobKzgCommitments)
	if err != nil {
		return nil, err
	}
	leaves[11] = ssz.LeafFromBytes(blobKzgCommitmentsRoot[:])

	// Leaf (12,13,14,15) - Empty
	leaves[12] = ssz.EmptyLeaf()
	leaves[13] = ssz.EmptyLeaf()
	leaves[14] = ssz.EmptyLeaf()
	leaves[15] = ssz.EmptyLeaf()

	return ssz.TreeFromNodes(leaves)
}

// constructExecutionPayloadDenebSSZTree constructs a SSZ tree for an ExecutionPayload
func constructExecutionPayloadDenebTree(payload *v11.ExecutionPayloadDeneb) (*ssz.Node, error) {
	leaves := make([]*ssz.Node, 32)
	payload.HashTreeRoot()
	// Leaf (0) - ParentHash
	leaves[0] = ssz.LeafFromBytes(payload.ParentHash[:])

	// Leaf (1) - FeeRecipient
	leaves[1] = ssz.LeafFromBytes(payload.FeeRecipient[:])

	// Leaf (2) - StateRoot
	leaves[2] = ssz.LeafFromBytes(payload.StateRoot[:])

	// Leaf (3) - ReceiptsRoot
	leaves[3] = ssz.LeafFromBytes(payload.ReceiptsRoot[:])

	// Leaf (4) - LogsBloom
	logsBloomRoot, err := sszencoding.MerkleizeByteSliceSSZ(payload.LogsBloom[:])
	if err != nil {
		return nil, err
	}
	leaves[4] = ssz.LeafFromBytes(logsBloomRoot[:])

	// Leaf (5) - PrevRandao
	leaves[5] = ssz.LeafFromBytes(payload.PrevRandao[:])

	// Leaf (6) - BlockNumber
	leaves[6] = ssz.LeafFromUint64(uint64(payload.BlockNumber))

	// Leaf (7) - GasLimit
	leaves[7] = ssz.LeafFromUint64(uint64(payload.GasLimit))

	// Leaf (8) - GasUsed
	leaves[8] = ssz.LeafFromUint64(uint64(payload.GasUsed))

	// Leaf (9) - Timestamp
	leaves[9] = ssz.LeafFromUint64(uint64(payload.Timestamp))

	// Leaf (10) - ExtraData
	extraDataRoot, err := ExtraDataRoot(payload.ExtraData[:])
	if err != nil {
		return nil, err
	}
	leaves[10] = ssz.LeafFromBytes(extraDataRoot[:])

	// Leaf (11) - BaseFeePerGas
	leaves[11] = ssz.LeafFromBytes(payload.BaseFeePerGas)

	// Leaf (12) - BlockHash
	leaves[12] = ssz.LeafFromBytes(payload.BlockHash[:])

	// Leaf (13) - Transactions
	transactionsRoot, err := sszencoding.TransactionsRoot(payload.Transactions)
	if err != nil {
		return nil, err
	}
	leaves[13] = ssz.LeafFromBytes(transactionsRoot[:])

	// Leaf (14) - Withdrawals
	withdrawalsRoot, err := sszencoding.WithdrawalSliceRoot(payload.Withdrawals, 16)
	if err != nil {
		return nil, err
	}
	leaves[14] = ssz.LeafFromBytes(withdrawalsRoot[:])

	// Leaf (15) - BlobGasUsed
	leaves[15] = ssz.LeafFromUint64(uint64(payload.BlobGasUsed))

	// Leaf (16) - ExcessBlobGas
	leaves[16] = ssz.LeafFromUint64(uint64(payload.ExcessBlobGas))

	// Leaf (17->31) - Empty
	for i := 17; i < 32; i++ {
		leaves[i] = ssz.EmptyLeaf()
	}

	return ssz.TreeFromNodes(leaves)
}
