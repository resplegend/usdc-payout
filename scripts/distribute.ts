import { ethers } from "ethers";
import * as dotenv from "dotenv";
dotenv.config();

const PRIVATE_KEY = process.env.PRIVATE_KEY!;
const RPC_URL = process.env.RPC_URL!;
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS!;

const ABI = [
  "function distribute() external"
];

async function main() {
  if (!PRIVATE_KEY || !RPC_URL || !CONTRACT_ADDRESS) {
    throw new Error("Missing environment variables");
  }
  const provider = new ethers.JsonRpcProvider(RPC_URL);
  const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
  const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, wallet);
  const tx = await contract.distribute();
  console.log("Distribution tx sent:", tx.hash);
  await tx.wait();
  console.log("Distribution complete");
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
}); 