const hre = require("hardhat");

async function main() {
  const privateKey = "0xab1faa79cdbe182bf6374cb6fcfe2607f2057eb4c97bfbc1442a2a2a4bf6a783";
  const wallet = new hre.ethers.Wallet(privateKey);
  console.log("Address:", wallet.address);
}

main().catch(console.error);
