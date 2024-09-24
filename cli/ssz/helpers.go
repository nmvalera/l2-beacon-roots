package ssz

import (
	"encoding/binary"

	"github.com/prysmaticlabs/prysm/v5/crypto/hash/htr"
	sszencoding "github.com/prysmaticlabs/prysm/v5/encoding/ssz"
)

// KzgCommitmentsRoot computes the root of a Deneb valid beacon block body KZGCommitments field
func KzgCommitmentsRoot(commitments [][]byte) ([32]byte, error) {
	commitmentsRoots := make([][32]byte, len(commitments))
	for i, commitment := range commitments {
		chunks, err := sszencoding.PackByChunk([][]byte{commitment})
		if err != nil {
			return [32]byte{}, err
		}
		commitmentsRoots[i] = htr.VectorizedSha256(chunks)[0]
	}
	commitmentsRoot, err := sszencoding.BitwiseMerkleize(commitmentsRoots, uint64(len(commitments)), 4096)
	if err != nil {
		return [32]byte{}, err
	}

	length := make([]byte, 32)
	binary.LittleEndian.PutUint64(length[:8], uint64(len(commitmentsRoots)))
	return sszencoding.MixInLength(commitmentsRoot, length), nil
}

// ExtraDataRoot computes the root of a Deneb valid execution payload ExtraData field
func ExtraDataRoot(extraData []byte) ([32]byte, error) {
	extraDataRoot, err := sszencoding.MerkleizeByteSliceSSZ(extraData[:])
	if err != nil {
		return [32]byte{}, err
	}

	length := make([]byte, 32)
	binary.LittleEndian.PutUint64(length[:8], uint64(len(extraData)))
	return sszencoding.MixInLength(extraDataRoot, length), nil
}
