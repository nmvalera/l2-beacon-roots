import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import { isDeployed, logStep, logStepEnd } from "../../ts-utils/helpers/index";

const func: DeployFunction = async function (l2Hre: HardhatRuntimeEnvironment) {
  if (!["optimismSepolia"].includes(l2Hre.network.name)) {
    throw new Error("Invalid network for optimistic Sepolia deployment");
  }

  const {deployments, getNamedAccounts} = l2Hre;
  const {execute} = deployments;
  const {deployer} = await getNamedAccounts();

  const l1BeaconRootsSenderDeployment = await l2Hre.companionNetworks['l1'].deployments.get('L1BeaconRootsSender'); // layer 1

  await execute(
    'L2BeaconRoots', 
    {
        from: deployer, 
        log: true
    },
    'init',
    l1BeaconRootsSenderDeployment.address
  );

  logStepEnd(__filename);
};

func.skip = async function ({ deployments, ethers }: HardhatRuntimeEnvironment): Promise<boolean> {
    logStep(__filename);
    const l2BeaconRootsDeployment = await deployments.get("L2BeaconRoots");
    const l2BeaconRoots = new ethers.Contract(l2BeaconRootsDeployment.address, l2BeaconRootsDeployment.abi, ethers.provider);
    const shouldSkip = (await l2BeaconRoots.L1_BEACON_ROOTS_SENDER()).toLowerCase() !== "0x0000000000000000000000000000000000000000";
   
    if (shouldSkip) {
      console.log("Skipped");
      logStepEnd(__filename);
    }
    return shouldSkip;
};

export default func;