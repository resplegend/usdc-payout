import { ethers, upgrades } from "hardhat";

async function main() {
  // === CONFIGURE THESE VALUES ===
  const usdcAddress = "<USDC_TOKEN_ADDRESS>"; // Polygon USDC token address
  const recipients = [
    "<RECIPIENT_1>",
    "<RECIPIENT_2>",
    "<RECIPIENT_3>",
    "<RECIPIENT_4>",
    "<RECIPIENT_5>"
  ];
  const recipientsPercent = 9000; // 90.00% (9000/10000)
  const rewardAddress = "<REWARD_ADDRESS>";
  const rewardPercent = 1000; // 10.00% (1000/10000)
  const distributionAmount = 25 * 10 ** 6; // 25 USDC (6 decimals)

  // ==============================

  const USDCDistributor = await ethers.getContractFactory("USDCDistributor");
  const distributor = await upgrades.deployProxy(
    USDCDistributor,
    [
      usdcAddress,
      recipients,
      recipientsPercent,
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