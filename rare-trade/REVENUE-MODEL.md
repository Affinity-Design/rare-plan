# Rare Revenue Model - Complete

> All fees flow to Rare Pool treasury

---

## 💰 Fee Structure

### Claims (RareFountain)

```yaml
Claim Fee: $0.15 USD in ETH
  - Calculated via Chainlink oracle
  - At ETH $3,000 → 0.00005 ETH
  - At ETH $2,000 → 0.000075 ETH
  - Auto-adjusts with ETH price
  
Flow:
  User claims 200 RARE → Pays $0.15 → Rare Pool
```

### Staking (RareStaking)

```yaml
Commit Fee: $5.00 USD in ETH
  - Flat fee to commit to stake
  - One-time fee per stake
  - At ETH $3,000 → 0.00167 ETH
  - At ETH $2,000 → 0.0025 ETH
  
Flow:
  User stakes 1,000 RARE → Pays $5 → Rare Pool
```

### Wager (RareWager)

```yaml
Entry Fee: $1.50 USD in ETH
  - Per bet placement
  - Oracle-calculated
  
Win Fee: 5% of profit
  - Only on winning bets
  - Paid in RARE
  
Flow:
  Place bet → Pay $1.50 → Rare Pool
  Win 100 RARE → Pay 5 RARE (5%) → Rare Pool
```

---

## 📊 Revenue Projections

### Conservative (100 users/day)

```yaml
Daily Activity:
  Claims: 100 × $0.15 = $15
  Stakes: 10 × $5 = $50
  Wagers: 500 × $1.50 = $750
  Win fees: 250 wins × 100 RARE × 5% = 1,250 RARE ($125)
  
Daily Total: $940 + 1,250 RARE
Monthly Total: $28,200 + 37,500 RARE ($3,750)
Yearly Total: $343,100 + 456,250 RARE ($45,625)

Combined: ~$390K/year
```

### Growth (500 users/day)

```yaml
Daily Activity:
  Claims: 500 × $0.15 = $75
  Stakes: 50 × $5 = $250
  Wagers: 2,500 × $1.50 = $3,750
  Win fees: 1,250 wins × 200 RARE × 5% = 12,500 RARE ($1,250)
  
Daily Total: $5,325 + 12,500 RARE
Monthly Total: $159,750 + 375,000 RARE ($37,500)
Yearly Total: $1.95M + 4.56M RARE ($456K)

Combined: ~$2.4M/year
```

### Viral (2,000 users/day)

```yaml
Daily Activity:
  Claims: 2,000 × $0.15 = $300
  Stakes: 200 × $5 = $1,000
  Wagers: 10,000 × $1.50 = $15,000
  Win fees: 5,000 wins × 500 RARE × 5% = 125,000 RARE ($12,500)
  
Daily Total: $18,800 + 125,000 RARE
Monthly Total: $564,000 + 3.75M RARE ($375K)
Yearly Total: $6.86M + 45.6M RARE ($4.56M)

Combined: ~$11.4M/year
```

---

## 🏗️ Contract Updates Needed

### RareFountainV3.sol

```solidity
// Add claim fee
uint256 public claimFeeUsd = 0.15e18; // $0.15 in 18 decimals

function claim() external payable nonReentrant {
    // Calculate ETH fee
    uint256 ethFee = calculateEthFee(claimFeeUsd);
    require(msg.value >= ethFee, "Insufficient fee");
    
    // Send fee to treasury
    (bool sent, ) = payable(treasury).call{value: ethFee}("");
    require(sent, "Fee transfer failed");
    
    // Refund excess
    if (msg.value > ethFee) {
        payable(msg.sender).transfer(msg.value - ethFee);
    }
    
    // Process claim
    // ... existing logic
}

// Admin can adjust fee
function setClaimFee(uint256 newFeeUsd) external onlyOwner {
    claimFeeUsd = newFeeUsd;
}
```

### RareStakingV3.sol

```solidity
// Add commit fee
uint256 public commitFeeUsd = 5e18; // $5.00 in 18 decimals

function stake(uint256 amount, uint256 term) external payable {
    // Calculate ETH fee
    uint256 ethFee = calculateEthFee(commitFeeUsd);
    require(msg.value >= ethFee, "Insufficient fee");
    
    // Send fee to treasury
    (bool sent, ) = payable(treasury).call{value: ethFee}("");
    require(sent, "Fee transfer failed");
    
    // Refund excess
    if (msg.value > ethFee) {
        payable(msg.sender).transfer(msg.value - ethFee);
    }
    
    // Process stake
    // ... existing logic
}

// Admin can adjust fee
function setCommitFee(uint256 newFeeUsd) external onlyOwner {
    commitFeeUsd = newFeeUsd;
}
```

---

## 📋 Complete Fee Summary

| Action | Fee | Currency | Flow |
|--------|-----|----------|------|
| **Claim** | $0.15 | ETH (oracle) | → Rare Pool |
| **Stake** | $5.00 | ETH (oracle) | → Rare Pool |
| **Wager bet** | $1.50 | ETH (oracle) | → Rare Pool |
| **Wager win** | 5% | RARE | → Rare Pool |

---

## 💡 Why These Fees Work

### Claims ($0.15)
```yaml
Low enough:
  - 200 RARE claim = $20-200 value
  - $0.15 = <1% of claim value
  - Users won't notice

High enough:
  - 1,000 claims/day = $150/day
  - $54,750/year
  - Pure profit
```

### Staking ($5.00)
```yaml
Worth it because:
  - Committing to 30-365 days
  - Higher stakes (1K-100K RARE)
  - $5 is <1% of typical stake
  - One-time fee

Revenue:
  - 100 stakes/day = $500/day
  - $182,500/year
```

### Wager ($1.50 + 5%)
```yaml
Entry ($1.50):
  - Lower than casino ($5-20)
  - Higher volume
  - Predictable revenue

Win (5%):
  - Only winners pay
  - Scales with bet size
  - Still good odds for players
```

---

## 🎯 Fee Adjustment Powers

### Admin Controls

```solidity
// All fees adjustable by owner
function setClaimFee(uint256 newFee) // Currently $0.15
function setCommitFee(uint256 newFee) // Currently $5.00
function setEntryFee(uint256 newFee) // Currently $1.50
function setWinFee(uint256 newPercent) // Currently 5%
```

### When to Adjust

```yaml
Increase fees when:
  - High demand (users will pay)
  - Need more revenue
  - Testing price sensitivity

Decrease fees when:
  - Low activity
  - Competition
  - Growth phase
```

---

## 📊 Revenue Breakdown by Product

### Claims (Stable)

```yaml
Daily users: 100-2,000
Revenue: $15-300/day
Growth: Linear with users
Margin: 100% (pure profit)
```

### Staking (Growing)

```yaml
Daily commits: 10-200
Revenue: $50-1,000/day
Growth: Linear with users
Margin: 100% (pure profit)
```

### Wager (Viral)

```yaml
Daily bets: 500-10,000
Revenue: $750-15,000/day (entry) + RARE fees
Growth: Exponential (viral potential)
Margin: 95%+ (minimal costs)
```

---

## 🚀 Implementation Priority

### Phase 1 (Deploy Now)
```yaml
✅ Claim fee: $0.15
✅ Commit fee: $5.00
✅ Wager entry: $1.50
✅ Wager win: 5%
```

### Phase 2 (Post-Launch)
```yaml
[ ] Dynamic fees (based on demand)
[ ] Fee discounts (for high volume)
[ ] Loyalty rewards (fee rebates)
```

---

*Revenue Model v2.0*
*Updated: 2026-03-04*
*Author: Felix*
