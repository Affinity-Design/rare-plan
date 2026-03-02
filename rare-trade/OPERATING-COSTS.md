# Rare Trade - Operating Costs & Margins

> Detailed cost analysis at 10, 100, 1K, 10K users
> LLM model selection and hosting infrastructure

---

## Executive Summary

| Users | Revenue/mo | Costs/mo | Margin | Margin % |
|-------|------------|----------|--------|----------|
| 10 | $840 | $21 | $819 | 98% |
| 100 | $8,900 | $377 | $8,523 | 96% |
| 1,000 | $141,500 | $1,788 | $139,712 | 99% |
| 10,000 | $2,515,000 | $19,000 | $2,496,000 | 99% |

**Key Insight**: GLM-5 is 90x cheaper than Claude Sonnet. Exceptional margins at all scales.

**Model Strategy**: GLM-5 default (included), premium models cost extra.

---

## LLM Model Selection

### Model Comparison (Cost per 1M tokens)

| Model | Input | Output | Total* | Speed | Quality | Best For |
|-------|-------|--------|--------|-------|---------|----------|
| **GLM-5** | $0.10 | $0.10 | **$0.20** | Fast | Good | ✅ Default (cheapest) |
| **Gemini 3 Flash** | $0.10 | $0.40 | **$0.50** | Very Fast | Good | ✅ High-frequency bots |
| **Claude 4.5 Haiku** | $0.80 | $4.00 | **$4.80** | Very Fast | Excellent | ✅ Premium tier |

*Based on 60/40 input/output ratio (1500 input + 500 output per decision)

### Cost Comparison

```
Cost per 1M tokens (blended):
├── GLM-5: $0.20 (90x cheaper than Haiku!)
├── Gemini Flash: $0.50 (10x cheaper than Haiku)
└── Claude Haiku: $4.80 (premium quality)

At 1,000 users (3B tokens/mo):
├── GLM-5: $600/mo
├── Gemini Flash: $1,500/mo
└── Claude Haiku: $14,400/mo
```

### Recommended Strategy

```yaml
# Default (Included in subscription)
default_models:
  standard_trading: "GLM-5"
    - Good quality
    - Insanely cheap ($0.20/1M)
    - Included in all tiers
    
  high_frequency: "Gemini 3 Flash"
    - Very fast responses
    - Cheap ($0.50/1M)
    - For HFT/scalping bots

# Premium Add-on (User pays extra)
premium_models:
  claude_4.5_haiku:
    add_on: +100 RARE/mo per bot
    use_when: "Need best reasoning quality"
    features:
      - Excellent pattern recognition
      - Better complex analysis
      - Superior decision making
```

### Model Routing Logic

```yaml
# Automatic model selection based on use case
routing_rules:
  # Routine decisions (90% of calls)
  routine_checks:
    model: GLM-5
    examples:
      - "Should I check price again?"
      - "Is RSI in normal range?"
      - "Any pending orders?"
      
  # High-frequency trading
  hft_scalping:
    model: Gemini 2.0 Flash
    examples:
      - Scalping (< 5 min timeframe)
      - Arbitrage opportunities
      - Quick momentum shifts
      
  # Complex analysis (Premium only)
  complex_decisions:
    model: Claude 3.5 Haiku
    requires: Premium add-on
    examples:
      - Multi-asset correlation
      - Complex pattern recognition
      - Major position changes
```

### On-Chain Models?

| Option | Pros | Cons | Verdict |
|--------|------|------|---------|
| **GLM-5 (Zhipu AI)** | Cheapest, fast, good | Centralized | ✅ Primary |
| **Gemini Flash** | Fast, cheap | Google | ✅ HF Trading |
| **Claude Haiku** | Best quality | Expensive | ✅ Premium |
| **On-Chain AI** | Decentralized | Too slow, expensive | ❌ Not viable |
| **Local Llama** | Free | Hardware costs | ⚠️ Enterprise only |

**Recommendation**: 
- Default: GLM-5 (cheapest, good enough for 90% of use cases)
- HF Trading: Gemini Flash (speed + low cost)
- Premium: Claude Haiku (users pay extra for best quality)

---

## Infrastructure Costs

### Hosting Stack

```yaml
# API & Backend
api:
  provider: "Fly.io"
  tier: "Shared CPU 1x" → "Dedicated CPU 2x"
  cost: $5-50/mo per instance
  scaling: "Auto-scale based on load"

# Database
database:
  provider: "Supabase"
  tier: "Free" → "Pro" → "Team"
  cost: $0 → $25 → $599/mo
  features: "Postgres + Realtime + Auth"

# Cache & Queue
cache:
  provider: "Upstash Redis"
  tier: "Pay per use"
  cost: $0.20 per 100K commands
  
# Message Queue
queue:
  provider: "BullMQ + Redis"
  cost: "Included in Redis"

# Agent Workers
workers:
  provider: "Fly.io Machines"
  cost: $0.0016/min per CPU
  scaling: "Per-agent isolation"

# Monitoring
monitoring:
  provider: "Sentry + Grafana"
  cost: $0-50/mo

# Telegram Bot
telegram:
  cost: "Free (Telegram API)"

# Blockchain RPC
rpc:
  provider: "Alchemy"
  tier: "Free" → "Growth" → "Enterprise"
  cost: $0 → $199 → Custom
```

---

## Cost Breakdown by Scale

### 10 Users (MVP/Beta)

```yaml
users: 10
bots_active: 15
trades_per_day: 50
llm_calls_per_day: 500

costs_monthly:
  # Infrastructure
  api_hosting: $10          # Fly.io small
  database: $0              # Supabase free
  redis: $5                 # Upstash
  rpc: $0                   # Alchemy free
  monitoring: $0            # Sentry free
  
  # LLM Costs (500 calls/day × 30 days)
  # Using GLM-5 (cheap!)
  tokens_per_call: 2000
  total_tokens: 30M tokens
  llm_cost: $6              # GLM-5 @ $0.20/1M
  
  # Total
  infrastructure: $15
  llm: $6
  total: $21/mo

revenue_monthly:
  # Mix: 5 basic, 3 pro, 2 whale
  rare: (5×50 + 3×100 + 2×250) = 1,050 RARE
  eth: (5×0.005 + 3×0.01 + 2×0.025) = 0.105 ETH
  
  # At RARE $0.50, ETH $3,000
  rare_value: $525
  eth_value: $315
  total: $840/mo

margin:
  revenue: $840
  costs: $21
  profit: $819
  margin_pct: 98%
```

### 100 Users (Early Growth)

```yaml
users: 100
bots_active: 150
trades_per_day: 500
llm_calls_per_day: 5,000

costs_monthly:
  # Infrastructure
  api_hosting: $50          # Fly.io 2 instances
  database: $25             # Supabase Pro
  redis: $20                # Upstash
  rpc: $199                 # Alchemy Growth
  monitoring: $26           # Sentry Team
  
  # LLM Costs (5,000 calls/day × 30 days)
  # 95% GLM-5, 5% premium (user-paid)
  glm5_tokens: 285M         # $57
  premium_tokens: 15M       # User pays extra
  llm_cost: $57
  
  # Total
  infrastructure: $320
  llm: $57
  total: $377/mo

revenue_monthly:
  # Mix: 50 basic, 30 pro, 20 whale
  rare: (50×50 + 30×100 + 20×250) = 10,500 RARE
  eth: (50×0.005 + 30×0.01 + 20×0.025) = 1.05 ETH
  
  # Premium model add-ons (20 users × 50 RARE)
  premium_rare: 1,000 RARE
  
  # At RARE $0.50, ETH $3,000
  rare_value: $5,250
  eth_value: $3,150
  premium_value: $500
  total: $8,900/mo

margin:
  revenue: $8,900
  costs: $377
  profit: $8,523
  margin_pct: 96%
```

### 1,000 Users (Growth)

```yaml
users: 1,000
bots_active: 1,500
trades_per_day: 5,000
llm_calls_per_day: 50,000

costs_monthly:
  # Infrastructure
  api_hosting: $300         # Fly.io 6 instances
  database: $599            # Supabase Team
  redis: $100               # Upstash
  rpc: $199                 # Alchemy Growth
  monitoring: $50           # Sentry + Grafana
  
  # LLM Costs (50,000 calls/day × 30 days)
  # 90% GLM-5, 10% premium (user-paid)
  glm5_tokens: 2.7B         # $540
  premium_tokens: 300M      # User pays extra
  llm_cost: $540
  
  # Total
  infrastructure: $1,248
  llm: $540
  total: $1,788/mo

revenue_monthly:
  # Mix: 500 basic, 300 pro, 200 whale
  rare: (500×50 + 300×100 + 200×250) = 105,000 RARE
  eth: (500×0.005 + 300×0.01 + 200×0.025) = 10.5 ETH
  
  # Premium model add-ons (100 users × 50 RARE)
  premium_rare: 5,000 RARE
  
  # At RARE $1.00, ETH $3,000
  rare_value: $105,000
  eth_value: $31,500
  premium_value: $5,000
  total: $141,500/mo

margin:
  revenue: $141,500
  costs: $1,788
  profit: $139,712
  margin_pct: 99%
```

### 10,000 Users (Scale)

```yaml
users: 10,000
bots_active: 15,000
trades_per_day: 50,000
llm_calls_per_day: 500,000

costs_monthly:
  # Infrastructure
  api_hosting: $2,000       # Fly.io 20 instances
  database: $599            # Supabase Team (multiple)
  redis: $300               # Upstash
  rpc: $500                 # Alchemy Enterprise
  monitoring: $100          # Full stack
  
  # CDN & Storage
  cdn: $100
  
  # LLM Costs (500,000 calls/day × 30 days)
  # 85% GLM-5, 15% premium (user-paid)
  glm5_tokens: 25.5B        # $5,100
  premium_tokens: 4.5B      # User pays extra
  llm_cost: $5,100
  
  # DevOps & Support
  devops: $5,000            # Part-time SRE
  support_tools: $200
  
  # Total
  infrastructure: $8,699
  llm: $5,100
  operations: $5,200
  total: $18,999/mo

revenue_monthly:
  # Mix: 5,000 basic, 3,000 pro, 2,000 whale
  rare: 1,050,000 RARE
  eth: 105 ETH
  
  # Premium model add-ons (1,000 users × 50 RARE avg)
  premium_rare: 50,000 RARE
  
  # At RARE $2.00, ETH $3,000
  rare_value: $2,100,000
  eth_value: $315,000
  premium_value: $100,000
  total: $2,515,000/mo

margin:
  revenue: $2,515,000
  costs: $18,999
  profit: $2,496,001
  margin_pct: 99%
```

---

## Detailed Cost Categories

### 1. LLM Costs (Primary Variable - Now Much Cheaper!)

```yaml
# Token Usage Per Agent Decision
avg_tokens_per_decision:
  input: 1500    # Market data + context
  output: 500    # Decision + reasoning
  total: 2000

# Decisions Per Bot Per Day
decisions_per_strategy:
  hft: 100       # Every 15 min
  scalp: 50      # Every 30 min
  intraday: 12   # Every 2 hours
  swing: 4       # Every 6 hours
  position: 1    # Daily

# Average: 20 decisions/day per bot
avg_decisions_per_bot: 20

# LLM Cost Per Bot Per Month (at 1,200 tokens/decision × 20/day × 30 days)
tokens_per_bot_month: 1.2M

# Model Costs Per Bot Per Month
llm_cost_per_bot_month:
  glm_5: 1.2M × $0.20/1M = **$0.24**      # DEFAULT (insanely cheap!)
  gemini_3_flash: 1.2M × $0.50/1M = **$0.60**  # HIGH-FREQ
  claude_4_5_haiku: 1.2M × $4.80/1M = **$5.76**  # PREMIUM

# Cost Comparison
cost_comparison:
  glm_5_vs_haiku: "24x cheaper"
  glm_5_vs_gemini: "2.5x cheaper"
  
# At Scale (1,000 bots) - Monthly LLM Cost
model_mix_at_scale:
  # 85% use GLM-5 (default)
  glm_5: 850 bots × $0.24 = $204
  
  # 10% use Gemini Flash (HFT)
  gemini: 100 bots × $0.60 = $60
  
  # 5% use Claude Haiku (premium, user pays)
  haiku: 50 bots × $5.76 = $288 (user pays +100 RARE/mo)
  
platform_llm_cost: $264/mo  # Only pay for GLM-5 + Gemini
premium_revenue: 50 × 100 RARE = 5,000 RARE/mo ($5,000)
  sonnet_users: 50
  addon_fee: 200 RARE/mo
  revenue: 10,000 RARE/mo ($10,000)
```

### 2. Infrastructure Costs

```yaml
# Fixed Costs
fixed_monthly:
  - Database: $25-599
  - Monitoring: $0-100
  - RPC: $0-500
  
# Variable Costs
variable_monthly:
  - API hosting: $5-2,000 (scales with users)
  - Redis: $5-300 (scales with usage)
  - Bandwidth: $10-500
  
# Per-User Infrastructure Cost
per_user_cost:
  at_100_users: $3.20/user
  at_1000_users: $1.25/user
  at_10000_users: $0.84/user
```

### 3. Operational Costs

```yaml
# At 1,000+ Users
operational:
  devops_engineer: $5,000/mo (part-time)
  security_audit: $2,000/mo (averaged)
  legal_compliance: $1,000/mo
  customer_support: $2,000/mo
  marketing: $5,000/mo
  
# Total Operations
at_1000_users: $15,000/mo
at_10000_users: $50,000/mo
```

---

## Margin Analysis

### Revenue vs Costs

```
         10 Users    100 Users    1K Users     10K Users
         ────────    ─────────    ─────────    ──────────
Revenue    $840       $8,400      $136,500    $2,415,000
Costs       $27         $449       $3,108       $31,199
         ────────    ─────────    ─────────    ──────────
Profit     $813       $7,951     $133,392    $2,383,801
Margin     97%         95%         98%          99%
```

### Cost Structure

```
Costs Breakdown at 1,000 Users:
├── Infrastructure: 40% ($1,248)
│   ├── API hosting: $300
│   ├── Database: $599
│   ├── Redis: $100
│   ├── RPC: $199
│   └── Monitoring: $50
│
├── LLM: 60% ($1,860)
│   ├── Gemini Flash: $960
│   ├── Claude Haiku: $225
│   └── Claude Sonnet: $675
│
└── Operations: (add at scale)
```

---

## Cost Optimization Strategies

### 1. LLM Optimization

```yaml
# Caching
cache_strategies:
  - Cache market analysis for 5 min
  - Cache pattern recognition results
  - Store common indicators
  
  savings: 30% reduction in LLM calls

# Model Routing
smart_routing:
  - Routine checks → Gemini Flash
  - Standard trades → Claude Haiku
  - Complex decisions → Claude Sonnet
  
  savings: 50% reduction vs all-Sonnet

# Batch Processing
batching:
  - Combine multiple bot decisions
  - Process in parallel
  
  savings: 20% efficiency gain
```

### 2. Infrastructure Optimization

```yaml
# Auto-scaling
scaling_rules:
  - Scale down at night (low activity)
  - Pre-scale before market open
  - Use spot instances for workers
  
  savings: 40% on compute

# Database
db_optimization:
  - Use read replicas
  - Archive old trade data
  - Optimize queries
  
  savings: 30% on DB costs
```

### 3. Free Tier Maximization

```yaml
# Free Tiers Available
free_resources:
  supabase:
    - 500MB database
    - 1GB storage
    - 5GB bandwidth
    
  alchemy:
    - 300M compute units
    - 10M requests
    
  fly_io:
    - $5 free credit
    
  upstash:
    - 10K commands/day
    
# Total Free Value: ~$100/mo
```

---

## Break-Even Analysis

### Minimum Viable Scale

```yaml
# Monthly Fixed Costs
fixed_costs: $500/mo (at scale)

# Revenue Per User (Average)
avg_revenue_per_user: $136/mo (at $1 RARE)

# Break-Even
break_even_users: 4 users

# Realistic Break-Even (with operations)
realistic_break_even: 50 users
```

### Payback Period

```yaml
# Development Costs
development: $50,000 (one-time)

# At 100 Users
monthly_profit: $7,951
payback_months: 6.3 months

# At 1,000 Users
monthly_profit: $133,392
payback_months: 0.4 months
```

---

## Projections Summary

### Year 1 Financials

| Month | Users | Revenue | Costs | Profit | Cumulative |
|-------|-------|---------|-------|--------|------------|
| 1 | 10 | $840 | $27 | $813 | $813 |
| 3 | 50 | $4,200 | $200 | $4,000 | $8,813 |
| 6 | 200 | $16,800 | $800 | $16,000 | $56,813 |
| 9 | 500 | $68,250 | $2,000 | $66,250 | $198,063 |
| 12 | 1,000 | $136,500 | $3,108 | $133,392 | $560,000 |

### Year 2 Financials

| Quarter | Users | Revenue/Q | Costs/Q | Profit/Q |
|---------|-------|-----------|---------|----------|
| Q1 | 2,000 | $409,500 | $12,000 | $397,500 |
| Q2 | 4,000 | $819,000 | $24,000 | $795,000 |
| Q3 | 7,000 | $1,433,250 | $45,000 | $1,388,250 |
| Q4 | 10,000 | $2,415,000 | $93,600 | $2,321,400 |

---

## Recommendations

### LLM Strategy (Three-Tier Model)

**1. GLM-5 (Default - 85% of use)**
- Cost: $0.20/1M tokens (90x cheaper than Haiku!)
- Use: All standard trading bots
- Included: In all subscription tiers
- Quality: Good enough for 90% of decisions

**2. Gemini 2.0 Flash (High-Frequency - 10% of use)**
- Cost: $0.50/1M tokens
- Use: HFT, scalping, arbitrage bots
- Auto-switch: When bot makes >50 trades/day
- Quality: Fast + good

**3. Claude 3.5 Haiku (Premium - 5% of use)**
- Cost: $4.80/1M tokens
- Use: Complex analysis, major decisions
- Add-on: +100 RARE/mo per bot
- Quality: Excellent reasoning

### Model Selection Logic

```
Bot requests decision → Check bot type:
│
├── Standard Bot (< 20 trades/day)
│   └── Use GLM-5 ($0.24/mo)
│
├── High-Frequency Bot (> 50 trades/day)
│   └── Use Gemini Flash ($0.60/mo)
│
└── Premium Bot (user pays +100 RARE)
    └── Use Claude Haiku ($5.76/mo)
```

### Why This Works

```
Cost at 1,000 users:
├── 850 GLM-5 bots: $204/mo
├── 100 Gemini bots: $60/mo
├── 50 Haiku bots: $288/mo (user pays!)
└── Platform pays: $264/mo total

vs All-Haiku: $14,400/mo
Savings: $14,136/mo (98% cheaper!)
```

### Infrastructure

1. **Start**: Fly.io + Supabase Free + Alchemy Free
2. **Scale**: Upgrade as needed (auto-scale)
3. **Optimize**: Caching, batching, smart routing

---

## Summary

| Scale | Revenue | Costs | Margin | Status |
|-------|---------|-------|--------|--------|
| 10 users | $840/mo | $27/mo | 97% | ✅ Profitable immediately |
| 100 users | $8.4K/mo | $449/mo | 95% | ✅ Very profitable |
| 1K users | $136K/mo | $3K/mo | 98% | ✅ Highly profitable |
| 10K users | $2.4M/mo | $31K/mo | 99% | ✅ Extremely profitable |

**Conclusion**: Rare Trade has exceptional unit economics. Even at small scale, margins exceed 95%. Primary cost is LLM usage, which can be optimized aggressively.

---

*Operating Costs v1.0*
*Created: 2026-03-02*
*Author: Felix*
