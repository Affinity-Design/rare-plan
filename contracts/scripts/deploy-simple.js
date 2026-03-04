const { ethers } = require('ethers');
const solc = require('solc');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

// Simple Solidity compiler
function compileContract(fileName, contractName) {
  const contractPath = path.join(__dirname, '../contracts', fileName);
  const source = fs.readFileSync(contractPath, 'utf8');
  
  const input = {
    language: 'Solidity',
    sources: {
      [fileName]: {
        content: source,
      },
    },
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      },
      outputSelection: {
        '*': {
          '*': ['abi', 'evm.bytecode'],
        },
      },
    },
  };
  
  // Find all imports
  const imports = source.match(/import\s+['"]([^'"]+)['"];/g) || [];
  imports.forEach(imp => {
    const importPath = imp.match(/['"]([^'"]+)['"]/)[1];
    if (importPath.startsWith('@openzeppelin')) {
      const ozPath = path.join(__dirname, '../node_modules', importPath);
      if (fs.existsSync(ozPath)) {
        input.sources[importPath] = {
          content: fs.readFileSync(ozPath, 'utf8')
        };
      }
    }
  });
  
  const output = JSON.parse(solc.compile(JSON.stringify(input)));
  
  if (output.errors) {
    console.error('Compilation errors:', output.errors);
    throw new Error('Compilation failed');
  }
  
  return output.contracts[fileName][contractName];
}

async function main() {
  console.log("🔧 Compiling contracts...");
  
  // This is a simplified version - in reality we need to handle all imports
  // For now, let's just try to deploy using pre-compiled artifacts if they exist
  
  const artifactsDir = path.join(__dirname, '../artifacts/contracts');
  
  if (!fs.existsSync(artifactsDir)) {
    console.error("❌ No artifacts found. Please compile contracts first.");
    console.log("Run: npx hardhat compile");
    process.exit(1);
  }
  
  // Connect to Base Sepolia
  const provider = new ethers.JsonRpcProvider(process.env.BASE_SEPOLIA_RPC || 'https://sepolia.base.org');
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  
  console.log("\n🚀 Deploying V3 Contracts to Base Sepolia...");
  console.log("Network: Base Sepolia (Chain ID: 84532)");
  console.log("Deployer:", wallet.address);
  console.log("Balance:", ethers.formatEther(await provider.getBalance(wallet.address)), "ETH\n");

  // Load contract artifacts
  const tokenArtifact = JSON.parse(fs.readFileSync(path.join(artifactsDir, 'RareTokenV3.sol/RareTokenV3.json')));
  const lotteryArtifact = JSON.parse(fs.readFileSync(path.join(artifactsDir, 'RareLotteryV3.sol/RareLotteryV3.json')));
  const stakingArtifact = JSON.parse(fs.readFileSync(path.join(artifactsDir, 'RareStakingV3.sol/RareStakingV3.json')));
  const fountainArtifact = JSON.parse(fs.readFileSync(path.join(artifactsDir, 'RareFountainV3.sol/RareFountainV3.json')));

  // Base Sepolia addresses
  const CHAINLINK_ETH_USD = "0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc88cb";
  const BASENAME_REGISTRY = ethers.ZeroAddress;

  try {
    // 1. Deploy RareTokenV3
    console.log("1️⃣ Deploying RareTokenV3...");
    const tokenFactory = new ethers.ContractFactory(tokenArtifact.abi, tokenArtifact.bytecode, wallet);
    const token = await tokenFactory.deploy(ethers.ZeroAddress, wallet.address);
    await token.waitForDeployment();
    const tokenAddress = await token.getAddress();
    console.log("✅ RareTokenV3:", tokenAddress);

    // 2. Deploy RareLotteryV3
    console.log("\n2️⃣ Deploying RareLotteryV3...");
    const lotteryFactory = new ethers.ContractFactory(lotteryArtifact.abi, lotteryArtifact.bytecode, wallet);
    const lottery = await lotteryFactory.deploy(tokenAddress, wallet.address);
    await lottery.waitForDeployment();
    const lotteryAddress = await lottery.getAddress();
    console.log("✅ RareLotteryV3:", lotteryAddress);

    // 3. Deploy RareStakingV3
    console.log("\n3️⃣ Deploying RareStakingV3...");
    const stakingFactory = new ethers.ContractFactory(stakingArtifact.abi, stakingArtifact.bytecode, wallet);
    const staking = await stakingFactory.deploy(tokenAddress, tokenAddress, wallet.address, CHAINLINK_ETH_USD, wallet.address);
    await staking.waitForDeployment();
    const stakingAddress = await staking.getAddress();
    console.log("✅ RareStakingV3:", stakingAddress);

    // 4. Deploy RareFountainV3
    console.log("\n4️⃣ Deploying RareFountainV3...");
    const fountainFactory = new ethers.ContractFactory(fountainArtifact.abi, fountainArtifact.bytecode, wallet);
    const fountain = await fountainFactory.deploy(tokenAddress, stakingAddress, lotteryAddress, BASENAME_REGISTRY, CHAINLINK_ETH_USD, wallet.address);
    await fountain.waitForDeployment();
    const fountainAddress = await fountain.getAddress();
    console.log("✅ RareFountainV3:", fountainAddress);

    // 5. Configure
    console.log("\n5️⃣ Configuring contracts...");
    
    console.log("   - Funding Fountain (100K RARE)...");
    await (await token.transfer(fountainAddress, ethers.parseEther("100000"))).wait();
    
    console.log("   - Funding Staking (50K RARE)...");
    await (await token.transfer(stakingAddress, ethers.parseEther("50000"))).wait();
    
    console.log("   - Funding Lottery (10K RARE)...");
    await (await token.transfer(lotteryAddress, ethers.parseEther("10000"))).wait();

    console.log("   - Setting pool balance...");
    await (await fountain.setPoolBalance(ethers.parseEther("100"))).wait();
    
    console.log("   - Whitelisting deployer...");
    await (await fountain.setManualWhitelist(wallet.address, true)).wait();
    
    console.log("   - Unpausing contracts...");
    await (await fountain.unpause()).wait();
    await (await staking.unpause()).wait();
    await (await lottery.unpause()).wait();
    
    console.log("   - Starting lottery...");
    await (await lottery.startLottery()).wait();

    console.log("\n" + "=".repeat(60));
    console.log("✅ DEPLOYMENT COMPLETE - BASE SEPOLIA");
    console.log("=".repeat(60));
    console.log("RareTokenV3:    ", tokenAddress);
    console.log("RareFountainV3: ", fountainAddress);
    console.log("RareStakingV3:  ", stakingAddress);
    console.log("RareLotteryV3:  ", lotteryAddress);
    console.log("=".repeat(60));
    
    console.log("\n📝 Add to .env.local:");
    console.log(`NEXT_PUBLIC_RARE_TOKEN_TESTNET=${tokenAddress}`);
    console.log(`NEXT_PUBLIC_FOUNTAIN_TESTNET=${fountainAddress}`);
    console.log(`NEXT_PUBLIC_STAKING_TESTNET=${stakingAddress}`);
    console.log(`NEXT_PUBLIC_LOTTERY_TESTNET=${lotteryAddress}`);
    
  } catch (error) {
    console.error("\n❌ Deployment failed:", error);
    throw error;
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
