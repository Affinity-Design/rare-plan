# Rare Wager - Price Prediction Game

> Simple, fair, profitable

---

## 🎮 How It Works

### For Players

1. **Place Bet**
   - Choose amount (50-10,000 RARE)
   - Choose direction (UP or DOWN)
   - Pay $1.50 entry fee in ETH
   - Wager RARE tokens

2. **Wait 5 Minutes**

3. **Outcome**
   - **WIN**: Get your RARE back + matching profit (minus 5% fee)
   - **LOSE**: RARE goes to pool

### Example

```yaml
Current pool: 5,000 RARE
Entry fee: $1.50 in ETH (0.0005 ETH at $3K ETH)

You bet:
  Amount: 500 RARE
  Direction: UP
  Entry fee: 0.0005 ETH
  BTC price: $67,000

5 minutes later:
  BTC price: $67,500 (UP ✅)

You win:
  Profit: 500 RARE
  Fee (5%): 25 RARE → Rare Pool
  You receive: 975 RARE (500 original + 475 profit)

Total cost to you:
  0.0005 ETH entry fee
  25 RARE win fee
```

---

## 💰 Fee Model

### Hybrid Structure

| Fee Type | Amount | When | Where |
|----------|--------|------|-------|
| **Entry** | $1.50 USD in ETH | Every bet | → Rare Pool |
| **Win Fee** | 5% of profit | Win only | → Rare Pool |
| **Lose Fee** | 0% | Lose only | RARE stays in game pool |

### Why Hybrid?

```
✅ Entry fee = Predictable revenue
✅ Win fee = Scales with whales
✅ Oracle-priced = Stable in USD
✅ Adjustable = Can raise/lower fees
```

---

## 📊 Revenue Projections

### At Different Scales

**10 players/day (50 bets)**
```yaml
Entry fees: 50 × $1.50 = $75/day
Win fees (50%): 25 wins × 200 RARE × 5% = 250 RARE ($25)

Daily: $100
Monthly: $3,000
Yearly: $36,500
```

**100 players/day (500 bets)**
```yaml
Entry fees: 500 × $1.50 = $750/day
Win fees (50%): 250 wins × 500 RARE × 5% = 6,250 RARE ($625)

Daily: $1,375
Monthly: $41,250
Yearly: $495,000
```

**1000 players/day (5,000 bets)**
```yaml
Entry fees: 5,000 × $1.50 = $7,500/day
Win fees (50%): 2,500 wins × 1,000 RARE × 5% = 125,000 RARE ($12,500)

Daily: $20,000
Monthly: $600,000
Yearly: $7.3M
```

---

## 🔒 Safety Features

### Pool Protection

| Feature | Value | Purpose |
|---------|-------|---------|
| **Max wager** | 10% of pool | Prevent draining |
| **Min wager** | 50 RARE | Spam prevention |
| **Cooldown** | 10 minutes | Rate limiting |
| **Reserve** | 10% of pool | Always has liquidity |

### Oracle Security

```solidity
// Uses Chainlink price feeds
- ETH/USD: Calculate entry fee
- BTC/USD: Determine win/lose

// Staleness check
- Rejects prices > 5 minutes old
- Fallback to last good price
```

### Anti-Gaming

```yaml
- Cooldown between bets (10 min)
- Max bets per address tracked
- No flash loan manipulation (5 min lock)
- Pool cap per bet (10%)
```

---

## ⚙️ Admin Controls

### Adjustable Parameters

```solidity
// Entry fee (currently $1.50)
function setEntryFee(uint256 newFeeUsd)

// Win fee (currently 5%)
function setWinFee(uint256 newPercent)

// Add liquidity
function depositPool(uint256 amount)

// Remove liquidity (with reserve check)
function withdrawPool(uint256 amount)

// Emergency controls
function pause()
function unpause()
function emergencyWithdraw()
```

---

## 🚀 Deployment

### Constructor Args

```solidity
constructor(
    address _rareToken,      // RARE token address
    address _ethUsdFeed,     // Chainlink ETH/USD
    address _btcUsdFeed,     // Chainlink BTC/USD
    address _treasury,       // Rare Pool treasury
    uint256 _initialPool     // Starting pool (1,000 RARE)
)
```

### Base Sepolia Addresses

```yaml
ETH/USD Feed: 0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc88cb
BTC/USD Feed: (need to find/confirm)
RARE Token: (deploy first)
Treasury: (Rare Pool address)
```

### Deployment Steps

1. **Deploy RARE token** (if not already)
2. **Deploy RareWager** with args
3. **Fund pool** with 1,000 RARE
4. **Test with small bets**
5. **Verify on Basescan**
6. **Launch!**

---

## 📈 Integration

### Frontend Needs

```javascript
// Place bet
await wager.placeBet(
  ethers.parseEther("500"),  // 500 RARE
  true,                       // UP
  { value: await wager.calculateEthFee() }
)

// Check status
const bet = await wager.bets(betId)
const maxWager = await wager.getMaxWager()
const poolStats = await wager.getPoolStats()

// Resolve bet
await wager.resolveBet(betId)
```

### Events to Listen

```solidity
event BetPlaced(betId, player, amount, direction, startPrice, ethFee)
event BetResolved(betId, player, won, endPrice, payout, fee)
```

---

## 💡 Future Enhancements

### Phase 2 Features

- [ ] Multiple assets (ETH, SOL, etc.)
- [ ] Different timeframes (1 min, 15 min, 1 hour)
- [ ] Leaderboard with rewards
- [ ] Tournaments
- [ ] Copy betting (follow winners)

---

## 📋 Quick Reference

| Parameter | Value |
|-----------|-------|
| Entry fee | $1.50 USD in ETH |
| Win fee | 5% of profit |
| Min wager | 50 RARE |
| Max wager | 10,000 RARE or 10% of pool |
| Duration | 5 minutes |
| Cooldown | 10 minutes |
| Pool cap | 10% per bet |
| Reserve | 10% of pool |

---

*Rare Wager v1.0*
*Created: 2026-03-04*
*Author: Felix*
