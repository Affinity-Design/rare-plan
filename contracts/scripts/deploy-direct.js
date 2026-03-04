const { ethers } = require('ethers');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

async function main() {
  // Connect to Base Sepolia
  const provider = new ethers.JsonRpcProvider(process.env.BASE_SEPOLIA_RPC || 'https://sepolia.base.org');
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  
  console.log("🚀 Deploying V3 Contracts to Base Sepolia...");
  console.log("Deployer:", wallet.address);
  console.log("Balance:", ethers.formatEther(await provider.getBalance(wallet.address)), "ETH");
  console.log("");

  // Base Sepolia addresses
  const CHAINLINK_ETH_USD = "0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc88cb";
  const BASENAME_REGISTRY = "0x0000000000000000000000000000000000000000";

  // Load contract artifacts
  const tokenArtifact = JSON.parse(fs.readFileSync(path.join(__dirname, '../artifacts/contracts/RareTokenV3.sol/RareTokenV3.json')));
  const lotteryArtifact = JSON.parse(fs.readFileSync(path.join(__dirname, '../artifacts/contracts/RareLotteryV3.sol/RareLotteryV3.json')));
  const stakingArtifact = JSON.parse(fs.readFileSync(path.join(__dirname, '../artifacts/contracts/RareStakingV3.sol/RareStakingV3.json')));
  const fountainArtifact = JSON.parse(fs.readFileSync(path.join(__dirname, '../artifacts/contracts/RareFountainV3.sol/RareFountainV3.json')));

  // ============================================
  // 1. Deploy RareTokenV3
  // ============================================
  console.log("1️⃣ Deploying RareTokenV3...");
  const tokenFactory = new ethers.ContractFactory(tokenArtifact.abi, tokenArtifact.bytecode, wallet);
  const token = await tokenFactory.deploy(ethers.ZeroAddress, wallet.address);
  await token.waitForDeployment();
  const tokenAddress = await token.getAddress();
  console.log("✅ RareTokenV3 deployed to:", tokenAddress);
  console.log("");

  // ============================================
  // 2. Deploy RareLotteryV3
  // ============================================
  console.log("2️⃣ Deploying RareLotteryV3...");
  const lotteryFactory = new ethers.ContractFactory(lotteryArtifact.abi, lotteryArtifact.bytecode, wallet);
  const lottery = await lotteryFactory.deploy(tokenAddress, wallet.address);
  await lottery.waitForDeployment();
  const lotteryAddress = await lottery.getAddress();
  console.log("✅ RareLotteryV3 deployed to:", lotteryAddress);
  console.log("");

  // ============================================
  // 3. Deploy RareStakingV3
  // ============================================
  console.log("3️⃣ Deploying RareStakingV3...");
  const stakingFactory = new ethers.ContractFactory(stakingArtifact.abi, stakingArtifact.bytecode, wallet);
  const staking = await stakingFactory.deploy(
    tokenAddress,
    tokenAddress,
    wallet.address,
    CHAINLINK_ETH_USD,
    wallet.address
  );
  await staking.waitForDeployment();
  const stakingAddress = await staking.getAddress();
  console.log("✅ RareStakingV3 deployed to:", stakingAddress);
  console.log("");

  // ============================================
  // 4. Deploy RareFountainV3
  // ============================================
  console.log("4️⃣ Deploying RareFountainV3...");
  const fountainFactory = new ethers.ContractFactory(fountainArtifact.abi, fountainArtifact.bytecode, wallet);
  const fountain = await fountainFactory.deploy(
    tokenAddress,
    stakingAddress,
    lotteryAddress,
    BASENAME_REGISTRY,
    CHAINLINK_ETH_USD,
    wallet.address
  );
  await fountain.waitForDeployment();
  const fountainAddress = await fountain.getAddress();
  console.log("✅ RareFountainV3 deployed to:", fountainAddress);
  console.log("");

  // ============================================
  // 5. Configure Contracts
  // ============================================
  console.log("5️⃣ Configuring contracts...");

  // Fund Fountain
  console.log("   - Funding Fountain with 100,000 RARE...");
  await (await token.transfer(fountainAddress, ethers.parseEther("100000"))).wait();
  
  // Fund Staking
  console.log("   - Funding Staking with 50,000 RARE...");
  await (await token.transfer(stakingAddress, ethers.parseEther("50000"))).wait();
  
  // Fund Lottery
  console.log("   - Funding Lottery with 10,000 RARE...");
  await (await token.transfer(lotteryAddress, ethers.parseEther("10000"))).wait();

  // Configure Fountain
  console.log("   - Setting Fountain pool balance...");
  await (await fountain.setPoolBalance(ethers.parseEther("100"))).wait();
  
  // Add deployer to whitelist
  console.log("   - Adding deployer to whitelist...");
  await (await fountain.setManualWhitelist(wallet.address, true)).wait();
  
  // Unpause all
  console.log("   - Unpausing contracts...");
  await (await fountain.unpause()).wait();
  await (await staking.unpause()).wait();
  await (await lottery.unpause()).wait();
  
  // Start lottery
  console.log("   - Starting lottery...");
  await (await lottery.startLottery()).wait();

  console.log("");
  console.log("✅ Configuration complete!");
  console.log("");

  // ============================================
  // Summary
  // ============================================
  console.log("=".repeat(60));
  console.log("📋 DEPLOYMENT SUMMARY - BASE SEPOLIA");
  console.log("=".repeat(60));
  console.log("RareTokenV3:    ", tokenAddress);
  console.log("RareFountainV3: ", fountainAddress);
  console.log("RareStakingV3:  ", stakingAddress);
  console.log("RareLotteryV3:  ", lotteryAddress);
  console.log("=".repeat(60));
  console.log("");
  console.log("📝 Update your .env.local:");
  console.log(`NEXT_PUBLIC_RARE_TOKEN_TESTNET=${tokenAddress}`);
  console.log(`NEXT_PUBLIC_FOUNTAIN_TESTNET=${fountainAddress}`);
  console.log(`NEXT_PUBLIC_STAKING_TESTNET=${stakingAddress}`);
  console.log(`NEXT_PUBLIC_LOTTERY_TESTNET=${lotteryAddress}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
