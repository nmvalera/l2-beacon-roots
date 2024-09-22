import * as dotenv from "dotenv";
import "hardhat-deploy";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-verify";
import "@nomicfoundation/hardhat-ethers";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "hardhat-docgen";
import "hardhat-contract-sizer";
import "@primitivefi/hardhat-dodoc";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.20",
    settings: {
      viaIR: true,
      optimizer: {
        enabled: true,
        runs: 100,
      },
    },
  },
  dodoc: {
    outputDir: "natspec",
  },
  contractSizer: {
    runOnCompile: true,
  },
  networks: {
    sepolia: {
      url: process.env.RPC_URL || "",
      accounts: [process.env.DEPLOYER_PRIVATE_KEY_SEPOLIA],
    },
    optimismSepolia: {
        url: process.env.RPC_URL || "",
        accounts: [process.env.DEPLOYER_PRIVATE_KEY_OP_SEPOLIA],
        companionNetworks: {
          l1: "sepolia",
        }
    },
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
    l1Messenger: {
      sepolia: "",
      optimismSepolia: ""
    },
    l2Messenger: {
      sepolia: "",
      optimismSepolia: ""
    }
  },
  paths: {
    sources: "./contracts/src",
    cache: "./hardhat-cache",
  },
  etherscan: {
    apiKey: {
        sepolia: process.env.ETHERSCAN_SEPOLIA_API_KEY,
        optimismSepolia: process.env.ETHERSCAN_OP_SEPOLIA_API_KEY
    },
    customChains: [
      {
        network: "sepolia",
        chainId: 11155111,
        urls: {
          apiURL: "https://api-sepolia.etherscan.io/api",
          browserURL: "https://sepolia.etherscan.io",
        },
      },
      {
        network: "optimismSepolia",
        chainId: 11155420,
        urls: {
          apiURL: "https://api-sepolia-optimistic.etherscan.io/api",
          browserURL: "https://sepolia-optimistic.etherscan.io",
        },
      },
    ],
  }
};

export default config;