const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  
  console.log("🚀 Deploying V3 Contracts to Base Sepolia...");
  console.log("Deployer:", deployer.address);
  console.log("Balance:", hre.ethers.formatEther(await hre.ethers.provider.getBalance(deployer.address)), "ETH");
  console.log("");

  // Base Sepolia addresses
  const CHAINLINK_ETH_USD = "0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc88cb";
  const BASENAME_REGISTRY = "0x0000000000000000000000000000000000000000"; // None on testnet

  // ============================================
  // 1. Deploy RareTokenV3
  // ============================================
  console.log("1️⃣ Deploying RareTokenV3...");
  const RareTokenV3 = await hre.ethers.getContractFactory("RareTokenV3");
  const token = await RareTokenV3.deploy(
    hre.ethers.ZeroAddress, // Fountain (update later)
    deployer.address         // Owner
  );
  await token.waitForDeployment();
  const tokenAddress = await token.getAddress();
  console.log("✅ RareTokenV3 deployed to:", tokenAddress);
  console.log("");

  // ============================================
  // 2. Deploy RareLotteryV3
  // ============================================
  console.log("2️⃣ Deploying RareLotteryV3...");
  const RareLotteryV3 = await hre.ethers.getContractFactory("RareLotteryV3");
  const lottery = await RareLotteryV3.deploy(
    tokenAddress,
    deployer.address
  );
  await lottery.waitForDeployment();
  const lotteryAddress = await lottery.getAddress();
  console.log("✅ RareLotteryV3 deployed to:", lotteryAddress);
  console.log("");

  // ============================================
  // 3. Deploy RareStakingV3
  // ============================================
  console.log("3️⃣ Deploying RareStakingV3...");
  const RareStakingV3 = await hre.ethers.getContractFactory("RareStakingV3");
  const staking = await RareStakingV3.deploy(
    tokenAddress,           // RARE token
    tokenAddress,           // LP token (placeholder - no Aerodrome LP yet)
    deployer.address,       // Treasury
    CHAINLINK_ETH_USD,      // Chainlink ETH/USD
    deployer.address        // Owner
  );
  await staking.waitForDeployment();
  const stakingAddress = await staking.getAddress();
  console.log("✅ RareStakingV3 deployed to:", stakingAddress);
  console.log("");

  // ============================================
  // 4. Deploy RareFountainV3
  // ============================================
  console.log("4️⃣ Deploying RareFountainV3...");
  const RareFountainV3 = await hre.ethers.getContractFactory("RareFountainV3");
  const fountain = await RareFountainV3.deploy(
    tokenAddress,
    stakingAddress,
    lotteryAddress,
    BASENAME_REGISTRY,
    CHAINLINK_ETH_USD,
    deployer.address
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
  await token.transfer(fountainAddress, hre.ethers.parseEther("100000"));
  
  // Fund Staking
  console.log("   - Funding Staking with 50,000 RARE...");
  await token.transfer(stakingAddress, hre.ethers.parseEther("50000"));
  
  // Fund Lottery
  console.log("   - Funding Lottery with 10,000 RARE...");
  await token.transfer(lotteryAddress, hre.ethers.parseEther("10000"));

  // Configure Fountain
  console.log("   - Setting Fountain pool balance...");
  await fountain.setPoolBalance(hre.ethers.parseEther("100"));
  
  // Add deployer to whitelist
  console.log("   - Adding deployer to whitelist...");
  await fountain.setManualWhitelist(deployer.address, true);
  
  // Unpause all
  console.log("   - Unpausing contracts...");
  await fountain.unpause();
  await staking.unpause();
  await lottery.unpause();
  
  // Start lottery
  console.log("   - Starting lottery...");
  await lottery.startLottery();

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
  console.log("");
  console.log("🔍 Verify on Basescan:");
  console.log(`npx hardhat verify --network base-sepolia ${tokenAddress} ${hre.ethers.ZeroAddress} ${deployer.address}`);
  console.log(`npx hardhat verify --network base-sepolia ${lotteryAddress} ${tokenAddress} ${deployer.address}`);
  console.log(`npx hardhat verify --network base-sepolia ${stakingAddress} ${tokenAddress} ${tokenAddress} ${deployer.address} ${CHAINLINK_ETH_USD} ${deployer.address}`);
  console.log(`npx hardhat verify --network base-sepolia ${fountainAddress} ${tokenAddress} ${stakingAddress} ${lotteryAddress} ${BASENAME_REGISTRY} ${CHAINLINK_ETH_USD} ${deployer.address}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
