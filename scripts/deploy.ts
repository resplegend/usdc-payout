import { ethers, upgrades } from "hardhat";
import * as dotenv from "dotenv";

dotenv.config();

async function main() {
  const usdcAddress = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174";
  const recipients = [
    "<RECIPIENT_1>",
    "<RECIPIENT_2>",
    "<RECIPIENT_3>",
    "<RECIPIENT_4>",
    "<RECIPIENT_5>"
  ];
  const rewardAddress = "<REWARD_ADDRESS>";
  const rewardPercent = 1000; // 10.00% (1000/10000) or set to 500 for 5%
  const distributionAmount = 27_500_000; // 27.5 USDC (6 decimals)

  const USDCDistributor = await ethers.getContractFactory("USDCDistributor");
  const distributor = await upgrades.deployProxy(
    USDCDistributor,
    [
      usdcAddress,
      recipients,
      rewardAddress,
      rewardPercent,
      distributionAmount
    ],
    { initializer: "initialize" }
  );
  await distributor.waitForDeployment();

  console.log("USDCDistributor deployed to:", await distributor.getAddress());
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
}); 