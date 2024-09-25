package app

import (
	"encoding/json"
	"fmt"

	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/nmvalera/l2-beacon-roots/beacon"
	"github.com/nmvalera/l2-beacon-roots/ssz"
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
	client := new(beacon.BeaconClient)
	return &cli.App{
		Name: "beacon",
		Flags: []cli.Flag{
			BeaconURLFlag(),
		},
		Before: func(cCtx *cli.Context) (err error) {
			client, err = beacon.NewBeaconClient(cCtx.String("beacon-url"))
			return
		},
		Commands: []*cli.Command{
			{
				Name:        "generate-proof",
				Description: "Generates SSZ proof for a beacon block",
				Action: func(cCtx *cli.Context) error {
					blockId := ""
					if cCtx.NArg() > 0 {
						blockId = cCtx.Args().Get(0)
					} else {
						return fmt.Errorf("blockId is required")
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
			{
				Name:        "get-withdrawals-root",
				Description: "Get withdrawals root for a beacon block",
				Action: func(cCtx *cli.Context) error {
					blockId := ""
					if cCtx.NArg() > 0 {
						blockId = cCtx.Args().Get(0)
					} else {
						return fmt.Errorf("blockId is required")
					}

					blindedBlock, err := client.GetBlindedBlock(cCtx.Context, blockId)
					if err != nil {
						return err
					}

					fmt.Fprintf(cCtx.App.Writer, "%v\n", hexutil.Encode(blindedBlock.Body.ExecutionPayloadHeader.WithdrawalsRoot))
					return nil
				},
			},
		},
	}
}
