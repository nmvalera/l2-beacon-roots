package beacon

import (
	"net/http"
	"net/url"
)

// BeaconClient is an HTTP client for a Beacon node
type BeaconClient struct {
	baseURL *url.URL
	client  *http.Client
}

// NewBeaconClient creates a new BeaconClient
func NewBeaconClient(baseURL string) (*BeaconClient, error) {
	u, err := url.Parse(baseURL)
	if err != nil {
		return nil, err
	}

	return &BeaconClient{
		baseURL: u,
		client:  &http.Client{},
	}, nil
}
