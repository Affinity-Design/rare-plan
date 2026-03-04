# Rare Wager Integration - Architecture Update

> Cleaner model: No lottery, just wager. All unclaimed flows to wager pool.

---

## 🔄 New Flow

### Token Flow

```yaml
Daily Distribution (200 RARE):
  ├─→ Claimed RARE → User Wallets (active users)
  └─→ Unclaimed RARE → Wager Pool 💰
  
Wager Pool:
  ├─ Grows from unclaimed tokens
  ├─ Users bet against it
  └─ Winners take from pool, losers add to pool
```

### Revenue Streams

```yaml
1. Gas Fees (User pays):
   - ETH for transactions
   - Goes to validators/network
   
2. Entry Fee (User pays):
   - $1.50 in ETH per bet
   - Goes to Rare Pool treasury
   
3. Win Fee (5%):
   - 5% of profit on winning bets
   - Goes to Rare Pool treasury
   
4. Wager Pool Growth:
   - Unclaimed RARE flows in
   - Losing bets add to pool
   - Creates bigger prize pool
```

---

## 💡 Why This Is Better

### Old Model (Lottery + Wager)

```yaml
Problems:
  ❌ Two games to maintain
  ❌ Unclaimed split between two pools
  ❌ Lottery has no guaranteed winner
  ❌ More complex UI/UX
  ❌ Less liquidity per game
```

### New Model (Wager Only)

```yaml
Benefits:
  ✅ One game to focus on
  ✅ All unclaimed → Wager pool
  ✅ Every bet has winner (50/50)
  ✅ Simpler UI
  ✅ Deeper liquidity
  ✅ More engaging (immediate results)
```

---

## 🏗️ Contract Changes

### RareFountainV3.sol

```solidity
// OLD
address public lotteryContract;

function flipPool() {
    // Send unclaimed to lottery
    rareToken.transfer(lotteryContract, unclaimed);
}

// NEW
address public wagerContract;

function flipPool() {
    // Send unclaimed to wager pool
    rareToken.transfer(wagerContract, unclaimed);
}
```

### Deployment Order

```yaml
1. Deploy RareTokenV3
2. Deploy RareWager (with token address)
3. Deploy RareFountainV3 (with wager address)
4. Fund Fountain (100K RARE)
5. Fund Wager (1K RARE initial + receives unclaimed)
```

---

## 📊 Economics

### Wager Pool Growth

```yaml
Day 1:
  Initial: 1,000 RARE
  Unclaimed (50%): 100 RARE
  Pool end: 1,100 RARE
  
Day 30:
  Pool: ~4,000 RARE (from unclaimed)
  Bets won: -2,000 RARE
  Bets lost: +3,000 RARE
  Net pool: ~5,000 RARE
  
Day 365:
  Pool: ~50,000 RARE
  Self-sustaining from losing bets
```

### Revenue Projections

```yaml
Conservative (100 players/day):
  Entry fees: 500 bets × $1.50 = $750/day
  Win fees: 250 wins × 200 RARE × 5% = 2,500 RARE ($250)
  Total daily: $1,000
  
Monthly: $30,000
Yearly: $365,000

Growth (1000 players/day):
  Entry fees: 5,000 bets × $1.50 = $7,500/day
  Win fees: 2,500 wins × 1,000 RARE × 5% = 125,000 RARE ($12,500)
  Total daily: $20,000
  
Monthly: $600,000
Yearly: $7.3M
```

---

## 🎮 Smart Wallet Integration

### Features (User Pays Gas)

```yaml
✅ Passkey login (FaceID/TouchID)
✅ Session keys for auto-betting
✅ Transaction batching
✅ Social recovery
✅ USD payment (Coinbase handles swap)
✅ Spending limits

❌ NO gas sponsorship (we make money on fees)
```

### User Experience

```yaml
Traditional Wallet:
  1. Connect MetaMask
  2. Sign transaction (pay gas)
  3. Place bet (pay $1.50 entry)
  4. Wait 5 min
  5. Claim win (pay gas)

Smart Wallet:
  1. Login with FaceID
  2. Place bet (USD or ETH, pay $1.50 entry)
  3. Wait 5 min
  4. Auto-credited (no claim needed)
  
Both pay gas - we don't sponsor.
```

---

## 🚀 Deployment Steps

### Step 1: Deploy Contracts

```bash
# In rare-plan/contracts/

# 1. Token
npx hardhat run scripts/deploy-token.js --network base-sepolia

# 2. Wager
npx hardhat run scripts/deploy-wager.js --network base-sepolia

# 3. Fountain (updated with wager address)
npx hardhat run scripts/deploy-fountain.js --network base-sepolia

# 4. Configure
# - Fund Fountain with 100K RARE
# - Fund Wager with 1K RARE
# - Set wager address in Fountain
```

### Step 2: Verify

```bash
# Verify on Basescan
npx hardhat verify --network base-sepolia <WAGER_ADDRESS> \
  <RARE_TOKEN> \
  <ETH_USD_FEED> \
  <BTC_USD_FEED> \
  <TREASURY> \
  1000000000000000000000 # 1000 RARE initial
```

### Step 3: Frontend

```bash
# Update .env.local
NEXT_PUBLIC_RARE_TOKEN_TESTNET=<token>
NEXT_PUBLIC_FOUNTAIN_TESTNET=<fountain>
NEXT_PUBLIC_WAGER_TESTNET=<wager>
NEXT_PUBLIC_NO_LOTTERY=true

# Start app
npm run dev
```

---

## 📋 Summary

### What Changed

| Aspect | Before | After |
|--------|--------|-------|
| **Games** | Lottery + Wager | Wager only ✅ |
| **Unclaimed flow** | Split | All to Wager ✅ |
| **Gas sponsorship** | Considered | No ✅ |
| **Complexity** | High | Low ✅ |
| **Liquidity** | Split | Concentrated ✅ |

### What Stays

- ✅ Claims still work (200 RARE/day)
- ✅ Staking still works
- ✅ Entry fee ($1.50)
- ✅ Win fee (5%)
- ✅ All revenue to Rare Pool

### Revenue Model

```yaml
Entry fee: $1.50/bet → Rare Pool
Win fee: 5% → Rare Pool
Gas: User pays → Network
Unclaimed: → Wager Pool (grows game)
```

---

## 🎯 Next Steps

1. ✅ Contracts updated (Fountain → Wager)
2. ⏳ Test on Base Sepolia
3. ⏳ Add smart wallet SDK to frontend
4. ⏳ Deploy to mainnet
5. ⏳ Launch! 🚀

---

*Architecture v4.0*
*Updated: 2026-03-04*
*Author: Felix*
