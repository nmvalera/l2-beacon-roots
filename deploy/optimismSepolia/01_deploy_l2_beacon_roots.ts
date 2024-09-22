import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/dist/types";
import { isDeployed, logStep, logStepEnd } from "../../ts-utils/helpers/index";

const func: DeployFunction = async function (l2Hre: HardhatRuntimeEnvironment) {
  if (!["optimismSepolia"].includes(l2Hre.network.name)) {
    throw new Error("Invalid network for optimistic Sepolia deployment");
  }
  
  const { deployer, l2Messenger} = await l2Hre.getNamedAccounts();
  const { deploy } = l2Hre.deployments

  const l2BeaconRootsDeployment = await deploy('L2BeaconRoots', {
    from: deployer,
    args: [l2Messenger],
    log: true,
  });

  // Verify contract on Etherscan
  await l2Hre.run("verify:verify", {
    address: l2BeaconRootsDeployment.address,
    constructorArguments: [l2Messenger],
  });

  logStepEnd(__filename);
};

func.skip = async function ({ deployments }: HardhatRuntimeEnvironment): Promise<boolean> {
  logStep(__filename);
  const shouldSkip = await isDeployed("L2BeaconRoots", deployments, __filename);
  if (shouldSkip) {
    console.log("Skipped");
    logStepEnd(__filename);
  }
  return shouldSkip;
};

export default func;