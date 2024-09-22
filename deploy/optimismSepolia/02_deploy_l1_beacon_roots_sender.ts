import { DeployFunction } from "hardhat-deploy/dist/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { isDeployed, logStep, logStepEnd } from "../../ts-utils/helpers/index";

const func: DeployFunction = async function (l2Hre: HardhatRuntimeEnvironment) {
  if (!["optimismSepolia"].includes(l2Hre.network.name)) {
    throw new Error("Invalid network for optimistic Sepolia deployment");
  }

  // Retrieve L1 deployer
  const l1Hre = l2Hre.companionNetworks['l1'];
  const { deployer, l1Messenger} = await l1Hre.getNamedAccounts();
  const { deploy } = l1Hre.deployments

  // Retrieve L2BeaconRoots contract deployed on L2
  const l2BeaconRootsDeployment = await l2Hre.deployments.get('L2BeaconRoots');

  // Deploy on L1
  const l1BeaconRootsSenderDeployment = await deploy('L1BeaconRootsSender', {
    from: deployer,
    args: [l1Messenger, l2BeaconRootsDeployment.address],
    log: true,
  });

    
  logStepEnd(__filename);
};

func.skip = async function (l2Hre: HardhatRuntimeEnvironment): Promise<boolean> {
  logStep(__filename);

  const l1Hre = l2Hre.companionNetworks['l1'];
  const { deployments } = l1Hre
  const shouldSkip = await isDeployed("L1BeaconRootsSender", deployments, __filename);
  if (shouldSkip) {
    console.log("Skipped");
    logStepEnd(__filename);
  }
  return shouldSkip;
};

export default func;