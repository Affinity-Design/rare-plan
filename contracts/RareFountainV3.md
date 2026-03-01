# Rare Fountain V3

> Autonomous dual-pool distribution system with streak bonuses and 3-Tier whitelist

---

## 🎯 Overview

The Fountain is Rare Coin's distribution engine. Users register daily and claim RARE tokens through a fair, bot-proof system.

| Property | Value |
|----------|-------|
| **Network** | Base Chain |
| **Solidity** | 0.8.20 |
| **Distribution** | Dual-Pool Alternating |
| **Claim Fee** | $0.10 USD (via Chainlink) |

---

## 🛡️ 3-Tier Whitelist (Proof of Humanity)

To register, you must satisfy **ONE** of these:

| Tier | Requirement | How |
|------|-------------|-----|
| **1** | Manual Authorization | Manager whitelists you |
| **2** | Hold RARE | Hold ≥ threshold (configurable) |
| **3** | Basename | Own a Base ENS name |

---

## 🔥 Streak Bonus System

**Claim daily to unlock bonuses - NO RARE NEEDED!**

| Days | Bonus | Reset Rule |
|------|-------|------------|
| 10 | +1% | Miss 1 day = Reset |
| 30 | +5% | Miss 1 day = Reset |
| 60 | +15% | Miss 1 day = Reset |
| 150 | +35% | Miss 1 day = Reset |
| 365 | +100% | Miss 1 day = Reset |

```solidity
// Streak tracking
mapping(address => uint256) public claimStreak;
mapping(address => uint256) public lastClaimDay;

// If you miss a day, streak resets to 1!
if (lastClaimDay[msg.sender] < currentDay - 1) {
    claimStreak[msg.sender] = 1; // Reset!
}
```

---

## 💎 Holding Bonus System

**Hold RARE to unlock bonuses - NO STREAK NEEDED!**

| RARE Held | Bonus |
|-----------|-------|
| 1 | +1% |
| 10 | +5% |
| 100 | +15% |
| 1,000 | +35% |
| 10,000 | +100% |

```solidity
function getHoldingTier(address _user) public view returns (uint256) {
    uint256 balance = rareToken.balanceOf(_user);
    if (balance >= 10000 * 10**18) return 5; // +100%
    if (balance >= 1000 * 10**18) return 4;  // +35%
    // ...
}
```

---

## ⚠️ Important: Bonuses Don't Stack!

**You get the HIGHER bonus - not both!**

### Two Paths to Bonuses

| Path | Method | For Who |
|------|--------|---------|
| **Dedication** | Daily claims | Users with time |
| **Investment** | Hold RARE | Users with capital |

```solidity
function getTotalBonus(address _user) public view returns (uint256) {
    uint256 streakBonus = getStreakBonus(_user);
    uint256 holdingBonus = getHoldingBonus(_user);
    
    // Return the HIGHER - they don't stack!
    return streakBonus > holdingBonus ? streakBonus : holdingBonus;
}
```

### Example

```
Streak: 60 days (+15%)
Holding: 1,000 RARE (+35%)
Your Bonus: +35% (holding wins)
```

---

## 💰 USD-Based Fees (Chainlink)

Registration fee is always **$0.10 USD** regardless of ETH price.

```solidity
function getClaimFeeInEth() public view returns (uint256) {
    int256 ethPrice = getEthPrice(); // Chainlink ETH/USD
    return (claimFeeUsd * 10**8) / uint256(ethPrice);
}
```

**Fees go to:** Lottery contract (feeds prize pool)

---

## 🔄 Dual-Pool System

```
Day 1: Pool A Registration Open
Day 2: Pool B Registration Open → Pool A Claims Open
Day 3: Pool A Registration Open → Pool B Claims Open
(repeats)
```

**Benefits:**
- Prevents same-day claim exploits
- Allows time for bot detection
- Fair distribution over time

---

## 🎰 Unclaimed → Lottery

At every 24h flip, unclaimed tokens go to the lottery:

```solidity
function flipPool() external {
    uint256 unclaimed = calculateUnclaimed();
    rareToken.transfer(lotteryContract, unclaimed);
    // ...
}
```

**This ensures:**
- Constant lottery prize pool
- No wasted tokens
- Incentive to claim

---

## 📋 Contract Functions

### User Functions

| Function | Description |
|----------|-------------|
| `register()` | Register for current pool (pay fee) |
| `claim()` | Claim from previous pool |
| `isEligible(user)` | Check whitelist eligibility |
| `getStreakTier(user)` | Get streak bonus tier |
| `getHoldingTier(user)` | Get holding bonus tier |
| `getTotalBonus(user)` | Get max bonus (higher of two) |

### Anyone Can Call

| Function | Description |
|----------|-------------|
| `flipPool()` | Flip pools (24h cooldown) - **Unbrickable!** |

### Admin Functions

| Function | Description |
|----------|-------------|
| `setClaimFeeUsd(amount)` | Update fee ($0.10 default) |
| `setRareThreshold(amount)` | Update whitelist threshold |
| `setManualWhitelist(user, status)` | Manual whitelist |
| `pause()` / `unpause()` | Emergency controls |

---

## 🔒 Security Features

| Feature | Status |
|---------|--------|
| Solidity 0.8.20 | ✅ |
| ReentrancyGuard | ✅ |
| Pausable | ✅ |
| 24h Rate Limit | ✅ |
| 3-Tier Whitelist | ✅ |
| Autonomous Flip | ✅ (Unbrickable) |
| Chainlink Oracle | ✅ |

---

## 🚀 Example Flow

```
1. User holds 100 RARE (Tier 3 whitelist)
2. Calls register() with $0.10 ETH fee
3. Fee goes to lottery
4. Next day, calls claim()
5. If 30-day streak: Gets +5% bonus
6. OR if holding 100 RARE: Gets +15% bonus
7. Receives base claim + bonus
```

---

*Version: V3 (Base Chain)*
