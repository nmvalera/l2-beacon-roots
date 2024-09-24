package ssz

import (
	"crypto/sha256"
	"fmt"
	"io"
	"os"
	"testing"

	"github.com/ethereum/go-ethereum/common/hexutil"
	ssz "github.com/prysmaticlabs/fastssz"
	"github.com/prysmaticlabs/prysm/v5/consensus-types/blocks"
	v2 "github.com/prysmaticlabs/prysm/v5/proto/eth/v2"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const DATA_DIR = "data"

func loadTestBlock() (*v2.BeaconBlockDeneb, error) {
	file, err := os.Open(fmt.Sprintf("%s/block.ssz", DATA_DIR))
	if err != nil {
		return nil, err
	}
	defer file.Close()

	raw, err := io.ReadAll(file)
	if err != nil {
		return nil, err
	}

	block := &v2.BeaconBlockDeneb{}
	err = block.UnmarshalSSZ(raw)
	if err != nil {
		return nil, err
	}

	return block, nil
}

// TestBeaconBlockDenebSSZTree function
func TestBeaconBlockDenebSSZTree(t *testing.T) {
	// Decode file into a BeaconBlockDeneb
	block, err := loadTestBlock()
	require.NoError(t, err)

	// Construct SSZ tree for the block
	tree, err := ConstructBeaconBlockDenebTree(block)
	require.NoError(t, err)

	// Test the hash of the tree
	blockRoot, _ := block.HashTreeRoot()
	assert.Equal(t, hexutil.Encode(blockRoot[:]), hexutil.Encode(tree.Hash()), "Tree Hash does not match block root")

	// Test the withdrawal root
	data, err := blocks.NewWrappedExecutionData(block.Body.ExecutionPayload)
	require.NoError(t, err)

	header, err := blocks.PayloadToHeaderDeneb(data)
	require.NoError(t, err)

	treeWithdrawalsRoot, err := tree.GetWithdrawalRoot()
	require.NoError(t, err)

	assert.Equal(t, hexutil.Encode(header.WithdrawalsRoot[:]), hexutil.Encode(treeWithdrawalsRoot[:]), "Tree withdrawals root does not match block withdrawals root")

	// Test the proof for the withdrawal root
	proof, err := tree.ProveWithdrawalsRoot()
	require.NoError(t, err)

	assert.Equal(t, 6446, proof.Index, "Proof has invalid index")
	assert.Equal(t, hexutil.Encode(header.WithdrawalsRoot[:]), hexutil.Encode(proof.Leaf), "Proof has invalid Leaf")
	assert.Len(t, proof.Hashes, 12, "Proof has invalid length")

	isValid, err := ssz.VerifyProof(blockRoot[:], proof)
	require.NoError(t, err)

	assert.True(t, isValid, "Proof is not valid")
}

func TestSha256(t *testing.T) {
	hashL := hexutil.MustDecode("0xef91c6e7d3789ed96c6659a2641987fdeefee8c3fd6812f74ceeb258a3ce1561")
	hashR := hexutil.MustDecode("0x7c192a721d1eb9102864609e7c7cbede0a368252c3de10ca3a1c778cbd4e9ab1")

	// Concatenate the hashes
	hash := append(hashL, hashR...)

	// Compute the hash
	res := sha256.Sum256(hash)

	assert.Equal(t, "0x6cd96952b3dacfc7188b9ad9b17a2012b67827741f60b3c4e51a14f9d07f0c91", hexutil.Encode(res[:]))
}
