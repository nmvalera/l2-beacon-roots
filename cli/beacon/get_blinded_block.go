package beacon

import (
	"context"
	"fmt"
	"io"
	"net/http"

	"github.com/pkg/errors"
	v2 "github.com/prysmaticlabs/prysm/v5/proto/eth/v2"
)

// GetBlock fetches a blinded beacon block by its ID
func (c *BeaconClient) GetBlindedBlock(ctx context.Context, blockId string) (*v2.BlindedBeaconBlockDeneb, error) {
	// Prepare the request
	path := fmt.Sprintf("%v/%v/%v", c.baseURL.String(), "/eth/v1/beacon/blinded_blocks", blockId)
	req, err := http.NewRequest("GET", path, nil)
	if err != nil {
		return nil, err
	}

	// We request the block in SSZ format (because prysm SignedBeaconBlockDeneb.UnmarshalJSON is incompatible with the JSON response)
	req.Header.Set("Accept", "application/octet-stream")
	req.Header.Set("Eth-Consensus-Version", "deneb")

	// Send the request
	resp, err := c.client.Do(req.WithContext(ctx))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	// Process the response
	if resp.StatusCode != http.StatusOK {
		return nil, errors.Errorf("unexpected status code: %d", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var block v2.SignedBlindedBeaconBlockDeneb
	err = (&block).UnmarshalSSZ(body)
	if err != nil {
		return nil, err
	}

	return block.Message, nil
}
