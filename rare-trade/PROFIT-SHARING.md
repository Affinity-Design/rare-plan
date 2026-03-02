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

### Clone Marketplace (Market-Set Pricing)

```yaml
pricing:
  creator_sets_price: true    # User controls price
  minimum: 50 RARE            # Floor to prevent spam
  maximum: No cap             # Market determines value

revenue_split:
  creator: 80%                # Upfront payment
  platform: 20%               # → Rare Pool
```

### Clone Fee Examples

| Bot Level | Performance | Price | Creator Earns | Platform Earns |
|-----------|-------------|-------|---------------|----------------|
| **New** | 30d, 52% win, $150 | 50 RARE | 40 RARE | 10 RARE |
| **Proven** | 90d, 68% win, $2.4K | 500 RARE | 400 RARE | 100 RARE |
| **Top** | 180d, 82% win, $18K | 2,000 RARE | 1,600 RARE | 400 RARE |
| **Elite** | 365d, 91% win, $120K | 10,000 RARE | 8,000 RARE | 2,000 RARE |

### Clone Limits (Stealth Perk Only)

| Bot Type | Clone Limits | Notes |
|----------|--------------|-------|
| **Public** | Unlimited | Cannot restrict |
| **Private** | Disabled | Hidden from marketplace |
| **Stealth** | ✅ **Creator sets max** | 10, 50, 100, or unlimited |

### Anti-Spoof Protection

```yaml
listing_requirements:
  min_age: "≥30 days active"
  min_trades: "≥20 executed trades"
  min_profit: "≥$100 total profit"
  win_rate: "≥40%"
  verified: "All trades on-chain"
  
anti_gaming:
  - No wash trading (banned)
  - No self-cloning (blocked)
  - No flash loan manipulation
  - Real volume only
```

### Platform Fee (Public Bots Only)

| Action | Fee | Applies To |
|--------|-----|------------|
| **Winning trade** | **1% of profit** | Public & Stealth bots only |
| **Private bots** | **0%** | Pay +100 RARE/mo instead |

### Ongoing Royalties (Forever)

| Level | Relationship | Royalty | Example |
|-------|--------------|---------|---------|
| **Platform** | All winning trades | **1%** | $100 profit → $1 to Rare Pool |
| **Level 1** | Direct clone | **10%** of profits | A clones B → B gets 10% of A's profits |
| **Level 2** | Clone of clone | **5%** of profits | C clones A → B gets 5% of C's profits |
| **Level 3+** | Further clones | 0% | No royalties beyond 2 levels |

### Example Scenario

```
🏆 Bot "Alpha" by User X (PUBLIC)
├── Track record: 90 days, 68% win, $2,400 profit
├── Clone price: 500 RARE (Alice set this)
│
├── 💰 FIRST CLONE (User Y buys):
│   ├── Y pays: 500 RARE
│   ├── Alice earns: 400 RARE (80%)
│   └── Platform earns: 100 RARE (20%) → Rare Pool
│
├── Makes $1,000 profit this month
│   ├── User X keeps: $990 (99%)
│   └── Platform fee: $10 (1%) → Rare Pool
│
├── 📊 Leaderboard: #1 ranked
│
├── 👥 10 users clone it:
│   ├── Each pays 500 RARE clone fee
│   │   ├── Alice earns: 400 RARE × 10 = 4,000 RARE
│   │   └── Platform earns: 100 RARE × 10 = 1,000 RARE
│   ├── Each makes avg $500 profit
│   ├── Each pays: 1% platform ($5) + 10% royalty ($50)
│   └── Alice earns: 10 × 10% × $500 = $500/month
│
├── 🔗 5 of those clones get cloned again:
│   ├── 5 sub-clones make avg $300 profit
│   ├── Each pays: 1% platform ($3) + 10% L1 ($30) + 5% L2 ($15)
│   └── Alice earns: 5 × 5% × $300 = $75/month
│
└── 💵 Alice's Total Earnings:
    ├── Clone fees (10 buyers): 4,000 RARE (one-time)
    ├── Own bot profit: $990/month
    ├── L1 royalties: $500/month
    ├── L2 royalties: $75/month
    └── Monthly recurring: $1,565 + 4,000 RARE upfront
    
PRIVATE BOT EXAMPLE:
├── Makes $1,000 profit
├── User keeps: $1,000 (100%)
├── Platform fee: $0 (exempt)
├── Clone fees: $0 (disabled)
└── Pays: +100 RARE/mo privacy premium instead
    
Rare Pool Earns (from PUBLIC bots):
├── Platform fee (Alice): $10
├── Platform fee (10 clones): 10 × $5 = $50
├── Platform fee (5 sub-clones): 5 × $3 = $15
├── Clone fees: 11 × 100 RARE = 1,100 RARE
└── Total: $75 + 1,100 RARE
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
Monthly Revenue Sources:
  1. Platform Fee (1% of ALL winning trades):
     - 1,000 bots × $500 avg profit × 1% = $5,000
     
  2. Clone Fees:
     - 100 clones × 500 RARE = 50,000 RARE
    
  3. Subscription Fees:
     - All tiers (50-250 RARE/mo) → Rare Pool
     
  Total Monthly to Rare Pool: $5,000 + 50,000 RARE + subscriptions
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
| **Platform fee** | 1% of all winning trades → Rare Pool |
| **Clone fee** | 500 RARE (one-time) → Rare Pool |
| **Level 1 royalty** | 10% of profits (forever) → Creator |
| **Level 2 royalty** | 5% of profits (forever) → Creator |
| **Top creator potential** | $50,000+/mo |

### User Keeps (After Fees)

| Bot Type | Platform | Royalties | User Keeps |
|----------|----------|-----------|------------|
| **Private bot** | 0% | 0% | **100%** ⭐ |
| **Original public** | 1% | 0% | **99%** |
| **Cloned public (L1)** | 1% | 10% | **89%** |
| **Sub-cloned public (L2)** | 1% | 15% | **84%** |

**Private bots**: No platform fee, but pay +100 RARE/mo and earn no royalties

---

*Profit Sharing v1.0*
*Created: 2026-03-02*
*Author: Felix*
