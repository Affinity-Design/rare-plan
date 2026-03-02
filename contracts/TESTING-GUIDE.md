# V3 Contract Testing Guide

> Complete guide for testing V3 contracts on Base Sepolia testnet

---

## 🧪 Test Wallet (Burner)

| Item | Value |
|------|-------|
| **Address** | `0x2516637f3E59CFd6d54BB8f295f0F62DC0d5CdCE` |
| **Private Key** | In `.env` (do not commit!) |
| **Network** | Base Sepolia |
| **Status** | ⏳ Awaiting funding |

---

## 💰 Funding the Wallet

### Option 1: Direct Transfer
Send Base Sepolia ETH from your existing wallet:
```
To: 0x2516637f3E59CFd6d54BB8f295f0F62DC0d5CdCE
Amount: 0.1 ETH (testnet)
```

### Option 2: Use Alchemy Faucet
1. Go to https://www.alchemy.com/faucets/base-sepolia
2. Enter your wallet address (must have 0.001+ ETH on mainnet)
3. Claim 0.1 ETH
4. Transfer to test wallet above

### Option 3: Coinbase Wallet Faucet
1. Go to https://faucet.coinbase.com/
2. Connect Coinbase wallet
3. Select Base Sepolia
4. Claim test ETH

---

## 📋 Required Funding

| Purpose | Amount |
|---------|--------|
| Contract Deployment | ~0.05 ETH |
| Testing Transactions | ~0.02 ETH |
| Buffer | ~0.03 ETH |
| **Total Needed** | **0.1 ETH** |

---

## 🚀 Deployment Steps

### 1. Install Dependencies
```bash
cd rare-plan/contracts
npm install
```

### 2. Check Wallet Balance
```bash
npx hardhat run scripts/check-balance.js --network base-sepolia
```

### 3. Deploy Contracts
```bash
npm run deploy:sepolia
```

### 4. Verify Deployment
Contracts will be verified automatically on Basescan.

---

## 🧪 Testing Commands

### Check Contract Status
```bash
# Check Fountain
npx hardhat run scripts/check-fountain.js --network base-sepolia

# Check Staking
npx hardhat run scripts/check-staking.js --network base-sepolia

# Check Lottery
npx hardhat run scripts/check-lottery.js --network base-sepolia
```

### Run Test Transactions
```bash
# Register for Fountain
npx hardhat run scripts/test-register.js --network base-sepolia

# Claim from Fountain
npx hardhat run scripts/test-claim.js --network base-sepolia

# Enter Lottery
npx hardhat run scripts/test-lottery.js --network base-sepolia
```

---

## 📊 Contract Addresses (After Deployment)

| Contract | Address | Explorer |
|----------|---------|----------|
| RareTokenV3 | `0x...` | [Link](https://sepolia.basescan.org/address/0x...) |
| RareFountainV3 | `0x...` | [Link](https://sepolia.basescan.org/address/0x...) |
| RareStakingV3 | `0x...` | [Link](https://sepolia.basescan.org/address/0x...) |
| RareLotteryV3 | `0x...` | [Link](https://sepolia.basescan.org/address/0x...) |

---

## ⚙️ Post-Deployment Configuration

### 1. Update Frontend .env
```bash
# rarify-claim/.env.local
NEXT_PUBLIC_NETWORK=testnet
NEXT_PUBLIC_RARE_TOKEN_TESTNET=0x...
NEXT_PUBLIC_FOUNTAIN_TESTNET=0x...
NEXT_PUBLIC_STAKING_TESTNET=0x...
NEXT_PUBLIC_LOTTERY_TESTNET=0x...
```

### 2. Add Test Users to Whitelist
```javascript
// Using Hardhat console
const fountain = await ethers.getContractAt("RareFountainV3", "0x...");
await fountain.setManualWhitelist("0xUserAddress", true);
```

### 3. Fund Contracts
```javascript
// Fund Fountain
const token = await ethers.getContractAt("RareTokenV3", "0x...");
await token.transfer(fountainAddress, ethers.parseEther("100000"));

// Fund Staking
await token.transfer(stakingAddress, ethers.parseEther("50000"));
```

---

## 🔗 Useful Links

| Resource | URL |
|----------|-----|
| Base Sepolia Faucet | https://www.alchemy.com/faucets/base-sepolia |
| Coinbase Faucet | https://faucet.coinbase.com/ |
| Base Sepolia Explorer | https://sepolia.basescan.org/ |
| Chainlink ETH/USD Feed | `0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc88cb` |

---

## ⚠️ Security Notes

- **Never commit `.env` file** - it contains the private key
- **This is a burner wallet** - do not use for mainnet or real funds
- **Test ETH has no value** - only for testing on Sepolia
- **Rotate keys** after testing if wallet was shared

---

*Testing Guide v1.0*
*Created: 2026-03-02*
