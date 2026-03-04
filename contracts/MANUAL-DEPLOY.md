# Manual Deployment Guide - Base Sepolia

Since there are environment issues with automated deployment, here's how to deploy manually:

## Option 1: Remix IDE (Easiest)

### Step 1: Prepare Contracts
1. Go to https://remix.ethereum.org
2. Create folder structure:
   ```
   contracts/
   ├── RareTokenV3.sol
   ├── RareFountainV3.sol
   ├── RareStakingV3.sol
   └── RareLotteryV3.sol
   ```

### Step 2: Copy Contract Code
Copy each contract from `/rare-plan/contracts/contracts/` into Remix

### Step 3: Install Dependencies
In Remix file explorer, create `@openzeppelin/` folder and copy needed contracts:
- `contracts/token/ERC20/ERC20.sol`
- `contracts/token/ERC20/extensions/ERC20Burnable.sol`
- `contracts/token/ERC20/extensions/ERC20Permit.sol`
- `contracts/access/Ownable.sol`
- `contracts/security/ReentrancyGuard.sol`
- `contracts/token/ERC721/IERC721.sol`

### Step 4: Compile
- Compiler version: 0.8.20
- Enable optimization: 200 runs

### Step 5: Deploy to Base Sepolia

Deploy in this order:

#### 1. RareTokenV3
```solidity
constructor(address _fountain, address _owner)
```
**Args**: `[zeroAddress, yourWalletAddress]`

#### 2. RareLotteryV3
```solidity
constructor(address _rareToken, address _owner)
```
**Args**: `[tokenAddress, yourWalletAddress]`

#### 3. RareStakingV3
```solidity
constructor(
  address _rareToken,
  address _lpToken,
  address _treasury,
  address _chainlinkEthUsd,
  address _owner
)
```
**Args**: `[tokenAddress, tokenAddress, yourWalletAddress, "0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc88cb", yourWalletAddress]`

#### 4. RareFountainV3
```solidity
constructor(
  address _rareToken,
  address _staking,
  address _lottery,
  address _basenameRegistry,
  address _chainlinkEthUsd,
  address _owner
)
```
**Args**: `[tokenAddress, stakingAddress, lotteryAddress, zeroAddress, "0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc88cb", yourWalletAddress]`

### Step 6: Configure
After deployment, call these functions:

```javascript
// Fund contracts
await token.transfer(fountainAddress, "100000000000000000000000") // 100K RARE
await token.transfer(stakingAddress, "50000000000000000000000")   // 50K RARE
await token.transfer(lotteryAddress, "10000000000000000000000")   // 10K RARE

// Configure
await fountain.setPoolBalance("100000000000000000000") // 100 RARE
await fountain.setManualWhitelist(yourAddress, true)

// Unpause
await fountain.unpause()
await staking.unpause()
await lottery.unpause()

// Start lottery
await lottery.startLottery()
```

---

## Option 2: Local Deployment (Recommended)

If you have Node.js locally:

```bash
cd rare-plan/contracts
npm install
npx hardhat compile
npx hardhat run scripts/deploy-base-sepolia.js --network base-sepolia
```

This will output the contract addresses automatically.

---

## Environment Variables Needed

Add to `.env`:
```
PRIVATE_KEY=0xab1faa79cdbe182bf6374cb6fcfe2607f2057eb4c97bfbc1442a2a2a4bf6a783
BASE_SEPOLIA_RPC=https://sepolia.base.org
```

---

## After Deployment

Update `rarify-claim/.env.local`:
```
NEXT_PUBLIC_RARE_TOKEN_TESTNET=<deployed-token-address>
NEXT_PUBLIC_FOUNTAIN_TESTNET=<deployed-fountain-address>
NEXT_PUBLIC_STAKING_TESTNET=<deployed-staking-address>
NEXT_PUBLIC_LOTTERY_TESTNET=<deployed-lottery-address>
```

Then start the app:
```bash
cd rarify-claim
npm run dev
```

---

## Base Sepolia Testnet

- **Chain ID**: 84532
- **RPC**: https://sepolia.base.org
- **Explorer**: https://sepolia.basescan.org
- **Faucet**: https://faucet.quicknode.com/base/sepolia

---

*Need help? Check the deployment script output for contract addresses.*
