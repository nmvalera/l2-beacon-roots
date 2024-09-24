package app

import (
	"encoding/json"
	"fmt"

	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/nmvalera/kraken-l2-test/beacon"
	"github.com/nmvalera/kraken-l2-test/ssz"
	"github.com/urfave/cli/v2"
)

func BeaconURLFlag() *cli.StringFlag {
	return &cli.StringFlag{
		Name:     "beacon-url",
		Required: true,
		Usage:    "Beacon Node URL",
		EnvVars:  []string{"BEACON_URL"},
	}
}

func IndexFlag() *cli.IntFlag {
	return &cli.IntFlag{
		Name:        "index",
		Usage:       "Index of the leaf to prove (in not set default to the Withdrawals Root index)",
		DefaultText: "6446",
	}
}

type ProofMsg struct {
	Root   string   `json:"root"`
	Leaf   string   `json:"leaf"`
	Index  string   `json:"index"`
	Proofs []string `json:"proofs"`
}

func NewApp() *cli.App {
	return &cli.App{
		Name: "kl2test",
		Commands: []*cli.Command{
			{
				Name:        "generate-proof",
				Description: "Generates SSZ proof for a beacon block",
				Flags: []cli.Flag{
					BeaconURLFlag(),
				},
				Action: func(cCtx *cli.Context) error {
					blockId := ""
					if cCtx.NArg() > 0 {
						blockId = cCtx.Args().Get(0)
					} else {
						return fmt.Errorf("blockId is required")
					}

					client, err := beacon.NewBeaconClient(cCtx.String("beacon-url"))
					if err != nil {
						return err
					}

					block, err := client.GetBlock(cCtx.Context, blockId)
					if err != nil {
						return err
					}

					tree, err := ssz.ConstructBeaconBlockDenebTree(block)
					if err != nil {
						return err
					}

					index := cCtx.Int("index")
					if index == 0 {
						index = ssz.WITHDRAWALS_ROOT_GENERAL_INDEX
					}
					proof, err := tree.Prove(index)
					if err != nil {
						return err
					}

					// Print proof
					msgProof := ProofMsg{
						Root:  hexutil.Encode(tree.Hash()),
						Leaf:  hexutil.Encode(proof.Leaf[:]),
						Index: hexutil.EncodeUint64(uint64(proof.Index)),
					}

					for _, p := range proof.Hashes {
						msgProof.Proofs = append(msgProof.Proofs, hexutil.Encode(p[:]))
					}

					err = json.NewEncoder(cCtx.App.Writer).Encode(msgProof)
					if err != nil {
						return err
					}
					return nil
				},
			},
		},
	}
}
