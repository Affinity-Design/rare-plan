# Rare Coin V3 - Perks & Bonus System

> Complete guide to staking perks, claimer streaks, and fee structure

---

## 💰 USD-Based Fees (Chainlink Oracle)

All fees are calculated in **USD** and converted to ETH using Chainlink price feeds.

| Fee Type | USD Amount | ETH Equivalent |
|----------|------------|----------------|
| **Claim Registration** | $0.10 | Auto-calculated via oracle |
| **Staking Entry** | $0.10 | Auto-calculated via oracle |

**Why?** This ensures fees remain consistent regardless of ETH price volatility.

---

## 🔥 Streak System (Claimers)

**Claim every day to build your streak multiplier!**

| Streak | Days | Bonus | Reset? |
|--------|------|-------|--------|
| **Tier 1** | 10 days | +1% | ❌ Miss = Reset |
| **Tier 2** | 30 days | +5% | ❌ Miss = Reset |
| **Tier 3** | 60 days | +15% | ❌ Miss = Reset |
| **Tier 4** | 150 days | +35% | ❌ Miss = Reset |
| **Tier 5** | 365 days | +100% | ❌ Miss = Reset |

**Example:**
- Claim 30 days in a row = +5% bonus on every claim
- Miss day 31 = Streak resets to 1
- Start over and build again!

---

## 💎 RARE Holding Perks (Replaces NFTs)

**Hold RARE to unlock permanent bonuses!**

| Tier | RARE Held | Bonus | Staking | Claiming |
|------|-----------|-------|---------|----------|
| **1** | 1 RARE | +1% | ✅ | ✅ |
| **2** | 10 RARE | +5% | ✅ | ✅ |
| **3** | 100 RARE | +15% | ✅ | ✅ |
| **4** | 1,000 RARE | +35% | ✅ | ✅ |
| **5** | 10,000 RARE | +100% | ✅ | ✅ |

**Example:**
- Hold 1,000 RARE = +35% bonus on staking rewards AND claim rewards
- This replaces the old NFT system - no need to buy NFTs!

---

## 📊 Combined Bonus Example

**Scenario:**
- You've claimed **60 days in a row** (Tier 3 Streak = +15%)
- You hold **1,000 RARE** (Tier 4 Holding = +35%)
- Base claim = 10 RARE

**Calculation:**
```
Total Bonus = 15% + 35% = 50%
Final Claim = 10 + (10 × 50%) = 15 RARE
```

**Maximum Possible Bonus:**
- Streak Tier 5 (+100%) + Holding Tier 5 (+100%) = **+200% bonus!**

---

## 🎰 Unclaimed Tokens → Lottery

At every epoch flip (24h), unclaimed tokens from the pool are automatically sent to the **Lottery Contract**.

**This ensures:**
- Constant prize pool for lottery
- No tokens go to waste
- Incentive to claim regularly

---

## ⏱️ Staking Terms & Multipliers

| Term | Lock Duration | Multiplier |
|------|---------------|------------|
| Short | 7 days | 1x |
| Medium | 28 days | 2x |
| Long | 84 days | 3x |

**Weekly claim cycle** - Claim staking rewards every 7 days.

---

## 🛠️ Technical Details

### Chainlink Oracle
- **Network:** Base Chain
- **Feed:** ETH/USD
- **Decimals:** 8 (Chainlink standard)
- **Update:** Every time `getEthPrice()` is called

### Fee Calculation
```solidity
function getClaimFeeInEth() public view returns (uint256) {
    int256 ethPrice = getEthPrice(); // e.g., $2500.00
    return (claimFeeUsd * 10**8) / uint256(ethPrice);
    // $0.10 / $2500 = 0.00004 ETH
}
```

---

## 📋 Quick Reference

| What | Amount/Threshold |
|------|------------------|
| **Claim Fee** | $0.10 USD in ETH |
| **Staking Fee** | $0.10 USD in ETH |
| **Streak Reset** | Missing 1 day |
| **Max Streak Bonus** | +100% (365 days) |
| **Max Holding Bonus** | +100% (10k RARE) |
| **Max Total Bonus** | +200% |

---

*Last Updated: 2026-03-01*
*Contract Version: V3 (Base Chain)*
