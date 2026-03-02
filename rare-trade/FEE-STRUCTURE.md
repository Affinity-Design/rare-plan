# Rare Trade - Fee Structure

> Flexible, configurable fees that scale with RARE price
> Mix of RARE + ETH for sustainability
> ALL revenue → Rare Pool (centralized distribution)

---

## Current State Analysis

### RARE Token Context
- **Daily Distribution**: 200 RARE/day via claims
- **Circulating Supply**: ~560,000 RARE
- **Price Scenarios**:
  - At $0.10: 50 RARE = $5/mo ✅
  - At $0.50: 50 RARE = $25/mo ✅
  - At $1.00: 50 RARE = $50/mo ✅
  - At $5.00: 50 RARE = $250/mo ⚠️

### Design Goals
1. **Affordable**: Target ~$20-100/month for most users
2. **Sustainable**: Generate real revenue in ETH/stablecoins
3. **Configurable**: Adjustable via governance/contract
4. **Hybrid**: Mix RARE (utility) + ETH (revenue)
5. **Viral**: Profit sharing drives growth
6. **Anti-Spoof**: Track record required for marketplace

---

## Final Fee Structure

### Subscription Tiers (Hybrid RARE + ETH)

```yaml
bot_tiers:
  paper:
    rare: 0
    eth: 0
    features: "Simulation only, no real trades"
    
  basic:
    rare: 50          # $5-50 depending on price
    eth: 0.005        # ~$15 at 3k ETH
    total_usd: "~$20-65/mo"
    features: "1 bot, public, earn royalties"
    
  pro:
    rare: 100         # $10-100 depending on price
    eth: 0.01         # ~$30 at 3k ETH
    total_usd: "~$40-130/mo"
    features: "3 bots, privacy option, priority support"
    
  whale:
    rare: 250         # $25-250 depending on price
    eth: 0.025        # ~$75 at 3k ETH
    total_usd: "~$100-325/mo"
    features: "Unlimited bots, API access, priority"
```

### Privacy Options (Per Bot)

```yaml
privacy_modes:
  public:
    add_on: 0
    royalties: "✅ Earn 10% + 5%"
    visibility: "Full leaderboard visibility"
    clone_limits: "Unlimited clones"
    
  private:
    add_on: "+100 RARE/mo"
    royalties: "❌ No royalties"
    visibility: "Hidden from leaderboard"
    cloning: "Disabled"
    
  stealth:
    add_on: "+200 RARE/mo"
    royalties: "✅ Earn 10% + 5%"
    visibility: "Anonymous on leaderboard"
    clone_limits: "✅ SET MAX CLONES (exclusive perk)"
```

### LLM Model Tiers

```yaml
llm_models:
  glm_5:
    cost: "$0.20/1M tokens"
    included: "✅ Yes (default)"
    use_case: "Standard trading (85% of bots)"
    
  gemini_3_flash:
    cost: "$0.50/1M tokens"
    included: "✅ Yes (auto for HFT)"
    use_case: "High-frequency trading (10% of bots)"
    
  claude_4_5_haiku:
    cost: "$4.80/1M tokens"
    included: "❌ Premium add-on"
    add_on: "+100 RARE/mo per bot"
    use_case: "Premium quality (5% of bots)"
```

---

## Clone Marketplace

### Market-Set Pricing

```yaml
clone_marketplace:
  # Creator sets their own clone price
  creator_sets_price: true
  minimum_price: 50 RARE      # Floor to prevent spam
  maximum_price: No cap       # Market determines value
  
  revenue_split:
    creator: 80%              # Upfront payment
    platform: 20%             # → Rare Pool
    
  example_pricing:
    new_bot:
      performance: "30 days, 52% win, $150 profit"
      clone_price: 50 RARE
      creator_earns: 40 RARE
      platform_earns: 10 RARE
      
    proven_bot:
      performance: "90 days, 68% win, $2,400 profit"
      clone_price: 500 RARE
      creator_earns: 400 RARE
      platform_earns: 100 RARE
      
    top_bot:
      performance: "180 days, 82% win, $18,000 profit"
      clone_price: 2,000 RARE
      creator_earns: 1,600 RARE
      platform_earns: 400 RARE
      
    elite_bot:
      performance: "365 days, 91% win, $120,000 profit"
      clone_price: 10,000 RARE
      creator_earns: 8,000 RARE
      platform_earns: 2,000 RARE
```

### Clone Limits (Stealth Perk)

```yaml
# Only STEALTH tier can limit clones (exclusivity)
clone_limits:
  public_bots:
    limit: "Unlimited"
    note: "Cannot restrict clones"
    
  private_bots:
    cloning: "Disabled"
    note: "Hidden from marketplace"
    
  stealth_bots:
    limit: "✅ Creator sets max clones"
    options:
      - unlimited (default)
      - max 10 clones (ultra-exclusive)
      - max 50 clones (exclusive)
      - max 100 clones (semi-exclusive)
    benefit: "Scarcity drives demand + price"
    example:
      elite_bot:
        price: 5,000 RARE
        max_clones: 10
        status: "7/10 clones available"
        urgency: "Limited availability"
```

### Anti-Spoof Protection

```yaml
verification:
  # Bots MUST have track record to be clonable
  listing_requirements:
    age: "≥30 days active"
    trades: "≥20 executed trades"
    profit: "≥$100 total profit"
    win_rate: "≥40%"
    verified: "All trades on-chain verified"
    
  anti_gaming:
    - No wash trading (detected & banned)
    - No self-cloning (same wallet blocked)
    - No flash loan manipulation
    - Real volume only
    
  transparency:
    - Full trade history visible
    - Performance metrics verified
    - Clone count displayed
    - Creator reputation score
```

---

## Platform Fee (Public Bots Only)

```yaml
platform_fee:
  rate: "1% of winning trades"
  applies_to: "PUBLIC & STEALTH BOTS ONLY"
  flow: "→ Rare Pool"
  note: "Private bots pay privacy premium instead"
  
  exemption:
    private_bots: "No platform fee (pay +100 RARE/mo)"
    stealth_bots: "1% platform fee applies (anonymous)"
```

---

## Royalties (Ongoing Profit Sharing)

```yaml
royalties:
  # Creator earns from clones (separate from clone fee)
  level_1:
    rate: "10% of clone's profits"
    duration: "Forever"
    paid_in: "RARE"
    
  level_2:
    rate: "5% of sub-clone's profits"
    duration: "Forever"
    paid_in: "RARE"
    
  # Requirements to earn
  requirements:
    - Bot must be public (or stealth)
    - Min 30 days active
    - Min $100 profit generated
    - Win rate > 40%
```

---

## Example Trade Flow

```yaml
# PUBLIC BOT (1% platform fee applies)
trade:
  profit: $100
  
  # Original bot (not cloned)
  distribution:
    user_keeps: $99        # 99%
    platform_fee: $1       # 1% → Rare Pool
    
  # Cloned bot (Level 1)
  distribution:
    user_keeps: $89        # 89%
    platform_fee: $1       # 1% → Rare Pool
    royalty_level_1: $10   # 10% → Creator
    
  # Sub-cloned bot (Level 2)
  distribution:
    user_keeps: $84        # 84%
    platform_fee: $1       # 1% → Rare Pool
    royalty_level_1: $10   # 10% → Direct parent
    royalty_level_2: $5    # 5% → Original creator

# PRIVATE BOT (No platform fee - pays +100 RARE/mo instead)
trade:
  profit: $100
  
  # Private bots don't earn royalties (hidden from leaderboard)
  user_keeps: $100         # 100%
  platform_fee: $0         # No fee - privacy premium paid
```

---

## Clone Marketplace Example

```yaml
# Complete flow example
bot_creation:
  creator: Alice
  bot_name: "MoonShot Alpha"
  strategy: "Swing trading"
  
track_record:
  day_30: "Not eligible yet"
  day_31: 
    status: "✅ Eligible for marketplace"
    trades: 24
    profit: $156
    win_rate: 62%
    
clone_pricing:
  alice_sets_price: 500 RARE
  
  if_sold:
    alice_earns: 400 RARE (80%)
    platform_earns: 100 RARE (20% → Rare Pool)
    
clone_limits:
  mode: "Stealth (+200 RARE/mo)"
  max_clones: 50
  current_clones: 12
  remaining: 38
  
ongoing_royalties:
  per_clone_profit: $1,000/mo
  alice_earns: 12 clones × 10% × $1,000 = $1,200/mo
  forever: "As long as clones are active"
```

---

## Per-Action Fees (ETH)

```yaml
action_fees:
  trade_execution: 0.0001 ETH    # ~$0.30 per trade
  skill_purchase: 0.001 ETH      # ~$3 per skill
  withdrawal: 0.0005 ETH         # ~$1.50 (security fee)
```

---

## Skill Marketplace

```yaml
skill_fees:
  platform_fee: 10% of sale price
  flow: "→ Rare Pool"
  
  skill_types:
    indicator: "100-500 RARE (one-time)"
    strategy: "50-200 RARE/month"
    risk_tool: "75-150 RARE/month"
```

---

## Revenue Summary

### All Revenue Streams → Rare Pool

| Source | Amount | Flow |
|--------|--------|------|
| **Subscriptions** | 50-250 RARE + ETH | → Rare Pool |
| **Clone fees** | 50-10,000+ RARE (20%) | → Rare Pool |
| **Platform fee** | 1% of winning trades | → Rare Pool |
| **Privacy premium** | +100-200 RARE/mo | → Rare Pool |
| **Premium LLM** | +100 RARE/mo | → Rare Pool |
| **Skill marketplace** | 10% fee | → Rare Pool |

### Creator Earnings

| Source | Amount | Notes |
|--------|--------|-------|
| **Clone fee** | 80% upfront | One-time per clone |
| **Level 1 royalty** | 10% of profits | Forever |
| **Level 2 royalty** | 5% of profits | Forever |

---

## Key Benefits

### Market-Set Pricing
- ✅ Creators control their price
- ✅ Best bots naturally charge more
- ✅ Low barrier for new bots (50 RARE min)
- ✅ No arbitrary platform pricing

### Anti-Spoof Protection
- ✅ 30-day track record required
- ✅ All trades on-chain verified
- ✅ Performance metrics transparent
- ✅ No gaming the system

### Stealth Perks
- ✅ Set clone limits (exclusivity)
- ✅ Scarcity drives demand
- ✅ Higher prices for limited access
- ✅ Premium positioning

### Dual Income for Creators
- ✅ 80% of clone fee (upfront)
- ✅ 10% + 5% royalties (ongoing)
- ✅ Earn forever from winning bots

---

*Fee Structure v3.0*
*Updated: 2026-03-02*
*Author: Felix*
