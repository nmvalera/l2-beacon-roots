import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/dist/types";
import { isDeployed, logStep, logStepEnd } from "../../ts-utils/helpers/index";

const func: DeployFunction = async function (l2Hre: HardhatRuntimeEnvironment) {
  if (!["optimismSepolia"].includes(l2Hre.network.name)) {
    throw new Error("Invalid network for optimistic Sepolia deployment");
  }
  
  const { deployer } = await l2Hre.getNamedAccounts();
  const { deploy } = l2Hre.deployments

  // Retrieve L2BeaconRoots contract deployed on L2
  const l2BeaconRootsDeployment = await l2Hre.deployments.get('L2BeaconRoots');
  
  const l2BeaconRootsVerifierDeployment = await deploy('L2BeaconRootsVerifier', {
    from: deployer,
    args: [l2BeaconRootsDeployment.address],
    log: true,
  });

  // Verify contract on Etherscan
  await l2Hre.run("verify:verify", {
    address: l2BeaconRootsVerifierDeployment.address,
    constructorArguments: [l2BeaconRootsDeployment.address],
  });

  logStepEnd(__filename);
};

func.skip = async function ({ deployments }: HardhatRuntimeEnvironment): Promise<boolean> {
  logStep(__filename);
  const shouldSkip = await isDeployed("L2BeaconRootsVerifier", deployments, __filename);
  if (shouldSkip) {
    console.log("Skipped");
    logStepEnd(__filename);
  }
  return shouldSkip;
};

export default func;