# Rare Trade - Profit Sharing & Royalties

> The key viral growth driver: **Win → Publish → Earn Forever**

---

## 💰 The Viral Loop

```
User Creates Bot → Bot Wins → Appears on Leaderboard
        ↓
Other Users See It → Click "Clone Bot" → Pay Clone Fee
        ↓
Original Creator Earns 10% of Cloner's Profits FOREVER
        ↓
Cloner's Bot Also Wins → Others Clone It
        ↓
Original Creator Earns 5% of Sub-Cloner's Profits (2 levels!)
        ↓
VIRAL GROWTH 🚀
```

---

## Royalty Structure

### Clone Fees (One-Time)

| Action | Fee | Who Gets It |
|--------|-----|-------------|
| Clone a bot | 500 RARE | 100% → Rare Pool |
| Premium bot clone | 1,000 RARE | 100% → Rare Pool |

### Profit Sharing (Recurring - FOREVER)

| Level | Relationship | Royalty | Example |
|-------|--------------|---------|---------|
| **Level 1** | Direct clone | **10%** of profits | A clones B → B gets 10% of A's profits |
| **Level 2** | Clone of clone | **5%** of profits | C clones A → B gets 5% of C's profits |
| **Level 3+** | Further clones | 0% | No royalties beyond 2 levels |

### Example Scenario

```
🏆 Bot "Alpha" by User X
├── Makes $1,000 profit this month
│
├── 📊 Leaderboard: #1 ranked
│
├── 👥 10 users clone it:
│   ├── Each pays 500 RARE clone fee → Rare Pool
│   ├── Each makes avg $500 profit
│   └── User X earns: 10 × 10% × $500 = $500
│
├── 🔗 5 of those clones get cloned again:
│   ├── 5 sub-clones make avg $300 profit
│   └── User X earns: 5 × 5% × $300 = $75
│
└── 💵 User X Total Monthly Royalty: $575
    (on top of their own bot's $1,000 profit!)
```

---

## Revenue Flow

### For Bot Creators

```yaml
Monthly Income Sources:
  1. Own Bot Profits:
     - Whatever the bot earns trading
     
  2. Direct Clone Royalties (10%):
     - 10 clones × $500 avg profit × 10% = $500
     
  3. Sub-Clone Royalties (5%):
     - 5 sub-clones × $300 avg profit × 5% = $75
     
  Total Monthly: $1,575 (from one winning bot!)
  
  Annual Potential: $18,900+ per winning bot
```

### For Rare Pool

```yaml
Monthly Revenue From Cloning:
  Clone Fees:
    - 100 clones × 500 RARE = 50,000 RARE
    
  Platform Royalties (from profits):
    - 5% of all cloned bot profits
    - Est: 100 clones × $500 profit × 5% = $2,500
    
  Total to Rare Pool: 50,000 RARE + $2,500
```

---

## Leaderboard Incentives

### Why Publish Your Bot?

| Benefit | Description |
|---------|-------------|
| **Passive Income** | Earn 10% + 5% royalties forever |
| **Fame** | Top of leaderboard = credibility |
| **Airdrops** | Top performers get RARE airdrops |
| **Status** | "Verified Winner" badge |
| **Community** | Build following, sell strategies |

### Privacy Option

| Tier | Visibility | Cost | Royalties |
|------|------------|------|-----------|
| **Public** | Full visibility | Standard | ✅ Earn royalties |
| **Private** | Hidden | +100 RARE/mo | ❌ No royalties |
| **Stealth** | Anonymous | +200 RARE/mo | ✅ Earn royalties (anon) |

---

## Profit Calculation Example

### Bot "MoonShot" Performance

```yaml
Bot Stats:
  Creator: User Alice
  Strategy: Swing trading
  Monthly Profit: $2,500
  Win Rate: 72%
  APY: 145%
  
Leaderboard Ranking: #3
  
Cloning Activity:
  Direct Clones: 25 users
  Sub-Clones: 12 users (clones of clones)
  
Clone Performance:
  Direct Clones Avg Profit: $1,800/mo
  Sub-Clones Avg Profit: $900/mo
  
Alice's Monthly Earnings:
  Own Bot Profit: $2,500
  
  Direct Clone Royalties:
    25 clones × $1,800 × 10% = $4,500
    
  Sub-Clone Royalties:
    12 sub-clones × $900 × 5% = $540
    
  Total Monthly: $7,540
  Annual: $90,480
```

---

## Anti-Gaming Measures

### Preventing Abuse

| Abuse | Prevention |
|-------|-------------|
| **Clone own bot** | Same wallet = no royalties |
| **Fake profits** | Only real trades count |
| **Wash trading** | Detect circular trades |
| **Sybil attacks** | KYC for royalties > $100/mo |
| **Bot farming** | Min 30 days active before royalties |

### Royalty Eligibility

```yaml
Requirements:
  - Bot must be public
  - Min 30 days active
  - Min $100 profit generated
  - Win rate > 40%
  - Max drawdown < 50%
  - Real trades only (no wash trading)
  
Verification:
  - On-chain trade verification
  - Profit/loss calculation
  - Anti-gaming algorithms
```

---

## Smart Contract Implementation

### RoyaltyDistributor.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RoyaltyDistributor {
    struct BotLineage {
        address creator;           // Original creator
        address directCloneParent; // Who they cloned from
        uint256 level;             // 0 = original, 1 = direct clone, 2+ = sub-clone
    }
    
    mapping(address => BotLineage) public botLineage;
    mapping(address => uint256) public pendingRoyalties;
    
    // 10% to direct parent, 5% to grandparent
    uint256 constant DIRECT_ROYALTY = 1000;  // 10% (basis points)
    uint256 constant SUB_ROYALTY = 500;      // 5%
    
    event ProfitShared(
        address indexed bot,
        uint256 profit,
        address parent,
        uint256 parentRoyalty,
        address grandparent,
        uint256 grandparentRoyalty
    );
    
    function distributeProfit(address bot, uint256 profit) external {
        BotLineage memory lineage = botLineage[bot];
        
        // Level 1: Direct clone → 10% to original creator
        if (lineage.level >= 1 && lineage.directCloneParent != address(0)) {
            uint256 directRoyalty = (profit * DIRECT_ROYALTY) / 10000;
            pendingRoyalties[lineage.directCloneParent] += directRoyalty;
            
            // Level 2: Sub-clone → 5% to original creator
            if (lineage.level >= 2) {
                address grandparent = botLineage[lineage.directCloneParent].creator;
                if (grandparent != address(0)) {
                    uint256 subRoyalty = (profit * SUB_ROYALTY) / 10000;
                    pendingRoyalties[grandparent] += subRoyalty;
                    
                    emit ProfitShared(bot, profit, lineage.directCloneParent, directRoyalty, grandparent, subRoyalty);
                }
            }
        }
    }
    
    function claimRoyalties() external {
        uint256 amount = pendingRoyalties[msg.sender];
        require(amount > 0, "No royalties to claim");
        
        pendingRoyalties[msg.sender] = 0;
        
        // Transfer RARE tokens
        IERC20(rareToken).transfer(msg.sender, amount);
    }
}
```

---

## Revenue Projections

### Conservative Scenario (1,000 users)

```yaml
Active Bots: 1,500
Public Bots: 1,000 (67%)
Cloned Bots: 200 (20% of public)

Clone Fees:
  200 clones × 500 RARE = 100,000 RARE → Rare Pool
  
Monthly Royalties (at $500 avg profit):
  Level 1: 200 × $500 × 10% = $10,000 to creators
  Level 2: 50 × $300 × 5% = $750 to original creators
  
Platform Share (5%):
  200 × $500 × 5% = $5,000 → Rare Pool
  
Total Monthly to Rare Pool:
  100,000 RARE + $5,000
```

### Growth Scenario (10,000 users)

```yaml
Active Bots: 15,000
Public Bots: 10,000 (67%)
Cloned Bots: 3,000 (30% of public)

Clone Fees:
  3,000 clones × 500 RARE = 1,500,000 RARE → Rare Pool
  
Monthly Royalties:
  Level 1: 3,000 × $1,000 × 10% = $300,000 to creators
  Level 2: 1,000 × $500 × 5% = $25,000 to original creators
  
Platform Share (5%):
  3,000 × $1,000 × 5% = $150,000 → Rare Pool
  
Total Monthly to Rare Pool:
  1,500,000 RARE + $150,000
  
Top Creators Earning:
  Top 10 creators: $10,000 - $50,000/mo in royalties
```

---

## Summary

### Why This Drives Growth

```
1. Incentive to Win
   └── Better bot = more clones = more passive income

2. Incentive to Share
   └── Public bots earn royalties, private don't

3. Viral Growth
   └── Winners tell friends → more users → more clones

4. Quality Filter
   └── Only winning bots get cloned

5. Network Effect
   └── More users = more potential cloners = higher royalties
```

### Key Numbers

| Metric | Value |
|--------|-------|
| **Clone fee** | 500 RARE (one-time) |
| **Level 1 royalty** | 10% of profits (forever) |
| **Level 2 royalty** | 5% of profits (forever) |
| **Platform share** | 5% of cloned bot profits |
| **Top creator potential** | $50,000+/mo |

---

*Profit Sharing v1.0*
*Created: 2026-03-02*
*Author: Felix*
