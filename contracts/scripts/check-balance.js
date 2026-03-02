/**
 * Check wallet balance on Base Sepolia
 */
const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  const balance = await hre.ethers.provider.getBalance(deployer.address);
  
  console.log("=".repeat(60));
  console.log("📊 WALLET STATUS");
  console.log("=".repeat(60));
  console.log("Address:", deployer.address);
  console.log("Balance:", hre.ethers.formatEther(balance), "ETH");
  console.log("Network:", hre.network.name);
  console.log("=".repeat(60));
  
  if (balance < hre.ethers.parseEther("0.05")) {
    console.log("⚠️  Low balance! Need at least 0.05 ETH for deployment.");
    console.log("");
    console.log("Fund this address with Base Sepolia ETH:");
    console.log(deployer.address);
  } else {
    console.log("✅ Sufficient balance for deployment!");
  }
}

main().catch(console.error);
