#!/usr/bin/env node

const { ethers } = require('ethers');
const solc = require('solc');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

// Simple Solidity compiler
function findImports(importPath) {
  try {
    let resolvedPath;
    if (importPath.startsWith('@openzeppelin')) {
      resolvedPath = path.join(__dirname, '../node_modules', importPath);
    } else if (importPath.startsWith('@chainlink')) {
      resolvedPath = path.join(__dirname, '../node_modules', importPath);
    } else {
      resolvedPath = path.join(__dirname, '../contracts', importPath);
    }
    
    return { contents: fs.readFileSync(resolvedPath, 'utf8') };
  } catch (e) {
    console.error(`Cannot find import: ${importPath}`);
    return { error: 'File not found' };
  }
}

function compileContract(fileName) {
  const contractPath = path.join(__dirname, '../contracts', fileName);
  const source = fs.readFileSync(contractPath, 'utf8');
  
  const input = JSON.stringify({
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
          '*': ['abi', 'evm.bytecode.object'],
        },
      },
    },
  });
  
  const output = JSON.parse(solc.compile(input, { import: findImports }));
  
  if (output.errors && output.errors.some(e => e.severity === 'error')) {
    console.error('Compilation errors:', JSON.stringify(output.errors, null, 2));
    throw new Error('Compilation failed');
  }
  
  return output.contracts[fileName];
}

async function main() {
  console.log("🔧 Compiling contracts...");
  
  try {
    const tokenCompiled = compileContract('RareTokenV3.sol');
    const lotteryCompiled = compileContract('RareLotteryV3.sol');
    const stakingCompiled = compileContract('RareStakingV3.sol');
    const fountainCompiled = compileContract('RareFountainV3.sol');
    
    console.log("✅ All contracts compiled successfully!\n");
    
    // Connect to Base Sepolia
    const provider = new ethers.JsonRpcProvider('https://sepolia.base.org');
    const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
    
    console.log("🚀 Deploying V3 Contracts to Base Sepolia...");
    console.log("Network: Base Sepolia (Chain ID: 84532)");
    console.log("Deployer:", wallet.address);
    console.log("Balance:", ethers.formatEther(await provider.getBalance(wallet.address)), "ETH\n");

    // Base Sepolia addresses
    const CHAINLINK_ETH_USD = "0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc88cb";
    const BASENAME_REGISTRY = ethers.ZeroAddress;

    // Get compiled artifacts
    const tokenArtifact = tokenCompiled['RareTokenV3'];
    const lotteryArtifact = lotteryCompiled['RareLotteryV3'];
    const stakingArtifact = stakingCompiled['RareStakingV3'];
    const fountainArtifact = fountainCompiled['RareFountainV3'];

    // 1. Deploy RareTokenV3
    console.log("1️⃣ Deploying RareTokenV3...");
    const tokenFactory = new ethers.ContractFactory(tokenArtifact.abi, '0x' + tokenArtifact.evm.bytecode.object, wallet);
    const token = await tokenFactory.deploy(ethers.ZeroAddress, wallet.address);
    await token.waitForDeployment();
    const tokenAddress = await token.getAddress();
    console.log("✅ RareTokenV3:", tokenAddress);

    // 2. Deploy RareLotteryV3
    console.log("\n2️⃣ Deploying RareLotteryV3...");
    const lotteryFactory = new ethers.ContractFactory(lotteryArtifact.abi, '0x' + lotteryArtifact.evm.bytecode.object, wallet);
    const lottery = await lotteryFactory.deploy(tokenAddress, wallet.address);
    await lottery.waitForDeployment();
    const lotteryAddress = await lottery.getAddress();
    console.log("✅ RareLotteryV3:", lotteryAddress);

    // 3. Deploy RareStakingV3
    console.log("\n3️⃣ Deploying RareStakingV3...");
    const stakingFactory = new ethers.ContractFactory(stakingArtifact.abi, '0x' + stakingArtifact.evm.bytecode.object, wallet);
    const staking = await stakingFactory.deploy(
      tokenAddress,
      tokenAddress,
      wallet.address,
      CHAINLINK_ETH_USD,
      wallet.address
    );
    await staking.waitForDeployment();
    const stakingAddress = await staking.getAddress();
    console.log("✅ RareStakingV3:", stakingAddress);

    // 4. Deploy RareFountainV3
    console.log("\n4️⃣ Deploying RareFountainV3...");
    const fountainFactory = new ethers.ContractFactory(fountainArtifact.abi, '0x' + fountainArtifact.evm.bytecode.object, wallet);
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
    console.error("\n❌ Error:", error.message);
    if (error.data) {
      console.error("Details:", error.data);
    }
    throw error;
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
