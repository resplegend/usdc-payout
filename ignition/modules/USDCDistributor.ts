import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const USDCDistributorModule = buildModule("USDCDistributorModule", (m) => {
  const usdcAddress = m.getParameter("usdcAddress");
  const recipients = m.getParameter("recipients");
  const rewardAddress = m.getParameter("rewardAddress");
  const distributionAmount = m.getParameter("distributionAmount");

  const distributor = m.contract("USDCDistributor", [
    usdcAddress,
    recipients,
    rewardAddress,
    distributionAmount,
  ]);

  return { distributor };
});

export default USDCDistributorModule; 