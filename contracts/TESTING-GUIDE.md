# V3 Contract Testing Guide - Base Sepolia

> Complete guide for testing V3 contracts on Base Sepolia testnet

---

## 🧪 Test Wallet (Burner)

| Item | Value |
|------|-------|
| **Address** | `0x4A98a5a52372183D007E62Dd9f7c3c033F06840D` |
| **Private Key** | In `.env.local` (do not commit!) |
| **Network** | Base Sepolia (Chain ID: 84532) |
| **Purpose** | Test contract deployment only ⚠️ |
| **Status** | ✅ Funded with test ETH |

---

## 💰 Funding the Wallet

### Current Balance
Check balance: https://sepolia.basescan.org/address/0x4A98a5a52372183D007E62Dd9f7c3c033F06840D

### Get More Test ETH
1. **QuickNode Faucet**: https://faucet.quicknode.com/base/sepolia
2. **Alchemy Faucet**: https://www.alchemy.com/faucets/base-sepolia
3. **Coinbase Faucet**: https://faucet.coinbase.com/

### Required Funding

| Purpose | Amount |
|---------|--------|
| Contract Deployment (4 contracts) | ~0.08 ETH |
| Testing Transactions | ~0.02 ETH |
| Buffer | ~0.02 ETH |
| **Total Needed** | **0.12 ETH** |

---

## 🚀 Deployment Steps

### 1. Pull Latest Code
```bash
cd /home/node/.openclaw/workspace-main/rarify-claim
git pull origin TEST
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Deploy All Contracts
```bash
npm run deploy:testnet
```

This will deploy:
- ✅ RareTokenV3
- ✅ RareWager
- ✅ RareStakingV3
- ✅ RareFountainV3

### 4. Verify Deployment
Contracts will be output in the console. Check them on Basescan.

---

## 📊 Token Distribution (After Deployment)

```yaml
Total Supply: 3,650,000 RARE

Distribution:
├── Deployer (You): 3,549,000 RARE (97.2%)
├── Fountain: 100,000 RARE (2.7%)
│   └── 500 days of claims (200 RARE/day)
├── Wager: 1,000 RARE (0.03%)
│   └── Initial betting pool
└── Staking: 50,000 RARE (1.4%)
    └── Rewards pool
```

---

## 📋 Contract Addresses (After Deployment)

| Contract | Address | Explorer |
|----------|---------|----------|
| RareTokenV3 | `0x...` | [View](https://sepolia.basescan.org/address/0x...) |
| RareFountainV3 | `0x...` | [View](https://sepolia.basescan.org/address/0x...) |
| RareStakingV3 | `0x...` | [View](https://sepolia.basescan.org/address/0x...) |
| RareWager | `0x...` | [View](https://sepolia.basescan.org/address/0x...) |

**Treasury (Rare Pool)**: `0x4A98a5a52372183D007E62Dd9f7c3c033F06840D`

---

## 🎮 Testing Each Contract

### 1. RareTokenV3 (Token)

```javascript
// Check balance
const balance = await token.balanceOf(deployerAddress);
console.log('Balance:', ethers.formatEther(balance), 'RARE');

// Approve Fountain
await token.approve(fountainAddress, ethers.MaxUint256);

// Transfer to test user
await token.transfer(userAddress, ethers.parseEther('1000'));
```

### 2. RareFountainV3 (Claims)

```javascript
// Check pool balance
const poolBalance = await fountain.poolBalance();
console.log('Pool:', ethers.formatEther(poolBalance), 'RARE');

// Register (whitelist required)
await fountain.setManualWhitelist(userAddress, true);

// Claim (will cost $0.15 in ETH)
await fountain.claim({ value: ethers.parseEther('0.00005') });

// Check unclaimed flow to Wager
const wagerBalance = await token.balanceOf(wagerAddress);
```

### 3. RareStakingV3 (Staking)

```javascript
// Approve staking
await token.approve(stakingAddress, ethers.MaxUint256);

// Stake (will cost $5.00 in ETH)
await staking.stake(
  ethers.parseEther('1000'), // 1000 RARE
  2, // 84-day term (3x multiplier)
  { value: ethers.parseEther('0.00167') } // $5 at 3K ETH
);

// Claim rewards
await staking.claimRewards(0); // Stake index

// Unstake
await staking.unstake(0);
```

### 4. RareWager (Betting Game)

```javascript
// Check pool
const poolStats = await wager.getPoolStats();
console.log('Pool:', ethers.formatEther(poolStats._poolBalance), 'RARE');
console.log('Max bet:', ethers.formatEther(poolStats._maxWager), 'RARE');

// Place bet (will cost $1.50 in ETH)
await wager.placeBet(
  ethers.parseEther('100'), // 100 RARE
  true, // UP direction
  { value: await wager.calculateEthFee() }
);

// Wait 5 minutes...

// Resolve bet
await wager.resolveBet(betId);

// Check if won
const bet = await wager.bets(betId);
console.log('Won:', bet.won);
console.log('Payout:', ethers.formatEther(bet.payout), 'RARE');
```

---

## 💵 Fee Structure

| Action | Fee | Currency | Notes |
|--------|-----|----------|-------|
| **Claim** | $0.15 | ETH (oracle) | Per claim |
| **Stake** | $5.00 | ETH (oracle) | Per commit |
| **Wager bet** | $1.50 | ETH (oracle) | Per bet |
| **Wager win** | 5% | RARE | Only on wins |

All fees go to treasury: `0x4A98a5a52372183D007E62Dd9f7c3c033F06840D`

---

## ⚙️ Post-Deployment Configuration

### 1. Update Frontend .env
```bash
# rarify-claim/.env.local
NEXT_PUBLIC_NETWORK=testnet
NEXT_PUBLIC_RARE_TOKEN_TESTNET=0x...
NEXT_PUBLIC_FOUNTAIN_TESTNET=0x...
NEXT_PUBLIC_STAKING_TESTNET=0x...
NEXT_PUBLIC_WAGER_TESTNET=0x...
```

### 2. Add Test Users to Whitelist
```javascript
// Using deployment script or Hardhat console
const fountain = await ethers.getContractAt("RareFountainV3", fountainAddress);
await fountain.setManualWhitelist("0xUserAddress", true);
```

### 3. Test the Full Flow
```bash
# Start the app
cd rarify-claim
npm run dev

# Open http://localhost:3000
# Connect wallet
# Claim RARE
# Stake RARE
# Place bets
```

---

## 🔗 Useful Links

| Resource | URL |
|----------|-----|
| Base Sepolia Explorer | https://sepolia.basescan.org/ |
| Deployer Address | https://sepolia.basescan.org/address/0x4A98a5a52372183D007E62Dd9f7c3c033F06840D |
| QuickNode Faucet | https://faucet.quicknode.com/base/sepolia |
| Alchemy Faucet | https://www.alchemy.com/faucets/base-sepolia |
| Coinbase Faucet | https://faucet.coinbase.com/ |
| Chainlink ETH/USD Feed | `0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc88cb` |

---

## 🧪 Test Scenarios

### Scenario 1: Basic Claims
1. Whitelist test user
2. User claims 200 RARE (pays $0.15)
3. Check balance increased
4. Verify pool decreased

### Scenario 2: Staking
1. User approves 1000 RARE
2. User stakes for 84 days (pays $5)
3. Wait, claim rewards
4. Unstake after term

### Scenario 3: Wager
1. User places bet on BTC UP (pays $1.50)
2. Wait 5 minutes
3. Resolve bet
4. If won, receive payout minus 5% fee
5. If lost, wager goes to pool

### Scenario 4: Unclaimed Flow
1. Skip claiming for 24 hours
2. Pool flips
3. Unclaimed RARE goes to Wager pool
4. Wager pool grows

---

## ⚠️ Security Notes

- **Never commit `.env.local`** - contains private key
- **This is a burner wallet** - do not use for mainnet
- **Test ETH has no value** - only for testing
- **Rotate keys** before mainnet deployment
- **All fees are real on mainnet** - test thoroughly

---

## 📊 Expected Gas Costs

| Contract | Deploy Gas | Cost (at 20 gwei) |
|----------|------------|-------------------|
| RareTokenV3 | ~1.2M | ~0.024 ETH |
| RareWager | ~3.5M | ~0.07 ETH |
| RareStakingV3 | ~2.8M | ~0.056 ETH |
| RareFountainV3 | ~4.2M | ~0.084 ETH |
| **Total** | **~11.7M** | **~0.234 ETH** |

*Note: Base Sepolia gas is cheaper, actual costs will be lower*

---

## 🐛 Troubleshooting

### "Insufficient ETH"
- Get more from faucets
- Check balance on Basescan

### "Compilation failed"
- Run `npm install` again
- Check Solidity version (0.8.20)

### "Contract not deployed"
- Check deployer address has ETH
- Check RPC URL is correct
- Try increasing gas limit

### "Oracle price stale"
- Chainlink feeds update every 1 min
- Wait and retry

---

*Testing Guide v2.0*
*Updated: 2026-03-04*
*Test Wallet: 0x4A98a5a52372183D007E62Dd9f7c3c033F06840D*
