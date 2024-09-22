import { DeployFunction } from "hardhat-deploy/dist/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { isDeployed, logStep, logStepEnd } from "../../ts-utils/helpers/index";

const func: DeployFunction = async function (l1Hre: HardhatRuntimeEnvironment) {
  if (!["sepolia"].includes(l1Hre.network.name)) {
    throw new Error("Invalid network for Sepolia deployment");
  }

  // Retrieve L1 deployer
  const { deployments } = await l1Hre;
  const l1BeaconRootsSenderDeployment = await deployments.get('L1BeaconRootsSender');
  
  // Verify contract on Etherscan
  await l1Hre.run("verify:verify", {
    address: l1BeaconRootsSenderDeployment.address,
    constructorArguments: l1BeaconRootsSenderDeployment.args,
  });
    
  logStepEnd(__filename);
};

func.skip = async function (l2Hre: HardhatRuntimeEnvironment): Promise<boolean> {
  logStep(__filename);

  const shouldSkip = false;
  if (shouldSkip) {
    console.log("Skipped");
    logStepEnd(__filename);
  }
  return shouldSkip;
};

export default func;