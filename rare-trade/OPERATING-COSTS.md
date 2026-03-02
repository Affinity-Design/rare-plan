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

| Model | Input | Output | Total* | Quality | Best For |
|-------|-------|--------|--------|---------|----------|
| **GLM-5** | $0.10 | $0.10 | **$0.20** | Good | ✅ Primary (default) |
| **Gemini 2.0 Flash** | $0.10 | $0.40 | $0.50 | Good | Backup |
| **GPT-4o-mini** | $0.15 | $0.60 | $0.75 | Good | Alternative |
| **DeepSeek V3** | $0.27 | $1.10 | $1.37 | Good | Cost saver |
| **Claude 3 Haiku** | $0.25 | $1.25 | $1.50 | Better | Premium tier |
| **Claude 3.5 Sonnet** | $3.00 | $15.00 | **$18.00** | Best | ⚠️ Expensive! |
| **Local Llama 3.1** | Free | Free | $0 | Decent | Enterprise |

*Based on 60/40 input/output ratio

### Cost Difference

```
GLM-5 vs Claude Sonnet:
- GLM-5: $0.20 per 1M tokens
- Claude Sonnet: $18.00 per 1M tokens
- Difference: 90x more expensive!

At 1,000 users (1.5B tokens/mo):
- GLM-5: $300/mo
- Claude Sonnet: $27,000/mo
- Savings: $26,700/mo
```

### Recommended Strategy

```yaml
# Default (Included in subscription)
default_model: "GLM-5"
  - All basic/pro bots use GLM-5
  - Included in standard pricing
  - Good enough for 90% of use cases

# Premium Add-on (User pays extra)
premium_models:
  claude_haiku:
    add_on: +50 RARE/mo per bot
    use_when: "Need better reasoning"
    
  claude_sonnet:
    add_on: +200 RARE/mo per bot
    use_when: "Critical decisions, complex analysis"

# Model Selection
model_tiers:
  standard:
    model: "GLM-5"
    cost_to_user: "Included"
    
  better:
    model: "Claude 3 Haiku"
    cost_to_user: "+50 RARE/mo"
    
  best:
    model: "Claude 3.5 Sonnet"
    cost_to_user: "+200 RARE/mo"
```

### On-Chain Models?

| Option | Pros | Cons | Verdict |
|--------|------|------|---------|
| **GLM-5 (Zhipu AI)** | Cheap, fast, powerful | Centralized | ✅ Primary |
| **Gemini Flash** | Cheap, fast | Google | ✅ Backup |
| **On-Chain AI** | Decentralized | Expensive, slow | ❌ Not viable |
| **Local Llama** | Free, private | Hardware costs | ⚠️ Enterprise only |

**Recommendation**: Use GLM-5 as default. Users who want premium models (Claude) pay extra. This keeps base costs low while offering premium options.

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

# LLM Cost Per Bot Per Month (GLM-5)
llm_cost_per_bot_glm5:
  tokens: 20 × 30 × 2000 = 1.2M tokens
  cost: 1.2M × $0.20/1M = $0.24/mo per bot

# Compare to Claude Sonnet
llm_cost_per_bot_sonnet:
  cost: 1.2M × $18/1M = $21.60/mo per bot
  
# Savings: 90x cheaper with GLM-5!

# At Scale (1,000 bots)
glm5_total: $240/mo
claude_haiku_total: $1,800/mo
claude_sonnet_total: $21,600/mo

# Premium Model Add-on Revenue
premium_addons:
  # 10% of users upgrade to Claude Haiku
  haiku_users: 100
  addon_fee: 50 RARE/mo
  revenue: 5,000 RARE/mo ($5,000)
  
  # 5% of users upgrade to Claude Sonnet
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

### LLM Strategy

1. **Primary**: GLM-5 (cheapest - $0.20/1M tokens)
2. **Backup**: Gemini 2.0 Flash
3. **Premium**: Claude (users pay extra +50-200 RARE/mo)
4. **Skip**: On-chain AI (too expensive, slow)

### Premium Model Strategy

```
Default (Included):
├── GLM-5 for all decisions
└── No extra cost

Premium Add-ons:
├── Better Reasoning (+50 RARE/mo)
│   └── Claude Haiku for complex decisions
└── Best Quality (+200 RARE/mo)
    └── Claude Sonnet for all decisions

User Choice:
├── 90% will use default (GLM-5)
├── 8% will pay for Haiku (+$50-100)
└── 2% will pay for Sonnet (+$200-500)
```

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
