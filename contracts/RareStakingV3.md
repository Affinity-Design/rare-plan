# Rare Staking V3

> Time-weighted LP staking with holding perks and Chainlink USD fees

---

## 🎯 Overview

Stake RARE/ETH LP tokens to earn RARE dividends. Longer locks = higher multipliers.

| Property | Value |
|----------|-------|
| **Network** | Base Chain |
| **Solidity** | 0.8.20 |
| **Entry Fee** | $0.10 USD (via Chainlink) |
| **Claim Cycle** | Weekly (7 days) |

---

## ⏱️ Term System

| Term | Lock Duration | Multiplier | Best For |
|------|---------------|------------|----------|
| **Short** | 7 days | 1x | Flexible stakers |
| **Medium** | 28 days | 2x | Balanced approach |
| **Long** | 84 days | 3x | Maximum rewards |

**Your weight in the pool = LP Amount × Multiplier**

---

## 💎 Holding Perks (Replaces NFTs)

**Hold RARE to boost your staking rewards!**

| RARE Held | Bonus |
|-----------|-------|
| 1 | +1% |
| 10 | +5% |
| 100 | +15% |
| 1,000 | +35% |
| 10,000 | +100% |

```solidity
function getHoldingBonus(address _user) public view returns (uint256) {
    uint256 tier = getPerkTier(_user);
    if (tier == 5) return 10000; // +100%
    if (tier == 4) return 3500;  // +35%
    // ...
}

// Applied to rewards
uint256 totalReward = baseReward + (baseReward * holdingBonus / 10000);
```

---

## 💰 USD-Based Entry Fee (Chainlink)

Entry fee is always **$0.10 USD** regardless of ETH price.

```solidity
uint256 public entryFeeUsd = 0.1 * 10**18; // $0.10

function getEntryFeeInEth() public view returns (uint256) {
    int256 ethPrice = getEthPrice(); // Chainlink
    return (entryFeeUsd * 10**8) / uint256(ethPrice);
}
```

**Fees go to:** Treasury address

---

## 📈 How Rewards Work

### Weekly Claim Cycle
- Claim rewards every **7 days**
- Rewards come from RARE dividend pool

### Calculation
```
Your Weight = (LP Amount × Multiplier)
Your Share = Your Weight / Total LP Staked
Base Reward = Pool Balance × Your Share × 1%
Total Reward = Base Reward + Holding Bonus
```

### Example
```
You stake: 100 LP for 84 days (3x)
Total LP staked: 10,000 LP
Pool balance: 1,000 RARE
You hold: 1,000 RARE (+35% bonus)

Your weight = 100 × 3 = 300
Your share = 300 / 10,000 = 3%
Base reward = 1,000 × 3% × 1% = 0.3 RARE
Holding bonus = 0.3 × 35% = 0.105 RARE
Total weekly reward = 0.405 RARE
```

---

## 📋 Contract Functions

### User Functions

| Function | Description |
|----------|-------------|
| `stake(amount, term)` | Stake LP tokens (0=7d, 1=28d, 2=84d) |
| `claimReward(stakeIndex)` | Claim weekly rewards |
| `unstake(stakeIndex)` | Withdraw after term expires |
| `getPerkTier(user)` | Check holding tier |
| `getHoldingBonus(user)` | Check bonus percentage |
| `getEntryFeeInEth()` | Get current ETH fee |

### View Functions

| Function | Description |
|----------|-------------|
| `getEthPrice()` | Current ETH/USD from Chainlink |
| `userStakes(user, index)` | View stake details |

### Admin Functions

| Function | Description |
|----------|-------------|
| `setEntryFeeUsd(amount)` | Update entry fee |
| `setTreasury(address)` | Update fee recipient |
| `setPriceFeed(address)` | Update Chainlink feed |
| `pause()` / `unpause()` | Emergency controls |

---

## 🔄 Staking Flow

```
1. Provide Liquidity → Get RARE/ETH LP from Aerodrome
2. Approve LP Tokens → Allow contract to spend
3. Stake LP → Choose term (7/28/84 days) + pay $0.10 fee
4. Wait 7 Days → First claim becomes available
5. Claim Weekly → Collect RARE dividends + holding bonus
6. Unstake → After term expires, get LP back
```

---

## 🔒 Security Features

| Feature | Status |
|---------|--------|
| Solidity 0.8.20 | ✅ |
| ReentrancyGuard | ✅ |
| Pausable | ✅ |
| State Before Transfer | ✅ |
| Treasury System | ✅ |
| Chainlink Oracle | ✅ |
| Term Lock Enforcement | ✅ |

---

## ⚠️ Important Notes

- **Cannot unstake** before term expires
- **Can claim rewards** weekly during lock
- **Holding bonus** checked at claim time
- **Multiple stakes** allowed per address
- **Fee in ETH** calculated at stake time

---

## 🔗 Integration

### LP Token
- **Pair:** RARE/ETH on Aerodrome
- **Standard:** ERC-20

### Chainlink Feed
- **Network:** Base Chain
- **Feed:** ETH/USD
- **Decimals:** 8

---

*Version: V3 (Base Chain)*
