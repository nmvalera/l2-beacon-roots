package main

import (
	"log"
	"os"

	"github.com/nmvalera/l2-beacon-roots/app"
)

func main() {
	app := app.NewApp()
	err := app.Run(os.Args)
	if err != nil {
		log.Fatalf("failed to run app: %v", err)
	}

	// Log client URl
	// blockId := "0x901630d35afe712ac1922cc4615c16c282b221f21ec870b837801a29a51d199e"
	// blockId := "0x6cd96952b3dacfc7188b9ad9b17a2012b67827741f60b3c4e51a14f9d07f0c91"
}
