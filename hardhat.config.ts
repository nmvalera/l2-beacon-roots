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
      url: process.env.ETH_RPC_URL_SEPOLIA,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY_SEPOLIA],
      deploy: ["deploy/sepolia"],
    },
    optimismSepolia: {
        url: process.env.ETH_RPC_URL_OP_SEPOLIA,
        accounts: [process.env.DEPLOYER_PRIVATE_KEY_OP_SEPOLIA],
        companionNetworks: {
          l1: "sepolia",
        },
        deploy: ["deploy/optimismSepolia"],
    },
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
    l1Messenger: {
      sepolia: "0x58Cc85b8D04EA49cC6DBd3CbFFd00B4B8D6cb3ef",
      optimismSepolia: "0x58Cc85b8D04EA49cC6DBd3CbFFd00B4B8D6cb3ef"
    },
    l2Messenger: {
      sepolia: "0x4200000000000000000000000000000000000007",
      optimismSepolia: "0x4200000000000000000000000000000000000007"
    }
  },
  paths: {
    sources: "./contracts/src",
    cache: "./hardhat-cache",
  },
  etherscan: {
    apiKey: {
        sepolia: process.env.ETHERSCAN_API_KEY_SEPOLIA,
        optimismSepolia: process.env.ETHERSCAN_API_KEY_OP_SEPOLIA
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