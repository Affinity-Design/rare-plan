# Rare Trade - Operating Costs & Margins

> Detailed cost analysis at 10, 100, 1K, 10K users
> LLM model selection and hosting infrastructure

---

## Executive Summary

| Users | Revenue/mo | Costs/mo | Margin | Margin % |
|-------|------------|----------|--------|----------|
| 10 | $1,500 | $200 | $1,300 | 87% |
| 100 | $15,000 | $800 | $14,200 | 95% |
| 1,000 | $150,000 | $5,500 | $144,500 | 96% |
| 10,000 | $1,500,000 | $35,000 | $1,465,000 | 98% |

**Key Insight**: High margins at all scales. LLM costs are the main variable.

---

## LLM Model Selection

### Model Comparison

| Model | Cost/Input | Cost/Output | Speed | Quality | Best For |
|-------|------------|-------------|-------|---------|----------|
| **Claude 3.5 Sonnet** | $3/1M tokens | $15/1M | Fast | Excellent | Primary agent |
| **Claude 3 Haiku** | $0.25/1M | $1.25/1M | Very Fast | Good | High-frequency |
| **Gemini 2.0 Flash** | $0.10/1M | $0.40/1M | Very Fast | Good | Backup/cheap |
| **GPT-4o-mini** | $0.15/1M | $0.60/1M | Fast | Good | Alternative |
| **DeepSeek V3** | $0.27/1M | $1.10/1M | Fast | Good | Cost saver |
| **Local Llama 3.1** | Free | Free | Medium | Decent | On-chain option |

### Recommended Strategy

```yaml
# Tiered Model Usage
strategy_decisions:
  high_frequency: "Claude 3 Haiku"      # Scalp/HFT bots
  standard_trading: "Gemini 2.0 Flash"   # Swing/intraday
  complex_analysis: "Claude 3.5 Sonnet"  # Deep reasoning
  fallback: "GPT-4o-mini"                # If primary fails

# Cost Optimization
optimization:
  - Cache frequent analysis patterns
  - Batch decisions when possible
  - Use smaller models for routine checks
  - Only use Sonnet for critical decisions
```

### On-Chain Models?

| Option | Pros | Cons | Verdict |
|--------|------|------|---------|
| **AI-as-a-Service** | Fast, cheap, powerful | Centralized | ✅ Primary |
| **On-Chain (Olas/AutoGPT)** | Decentralized | Expensive, slow | ❌ Not viable |
| **Local (Llama)** | Free, private | Hardware costs | ⚠️ Optional |

**Recommendation**: Use cloud APIs (Claude/Gemini) for now. On-chain AI is too expensive and slow for trading. Consider local Llama for privacy-focused enterprise tier.

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
  # Using Gemini Flash (cheap)
  tokens_per_call: 2000
  total_tokens: 30M tokens
  llm_cost: $12             # Gemini Flash rates
  
  # Total
  infrastructure: $15
  llm: $12
  total: $27/mo

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
  costs: $27
  profit: $813
  margin_pct: 97%
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
  # Mix: 70% Gemini Flash, 30% Claude Haiku
  gemini_tokens: 210M       # $84
  claude_tokens: 90M        # $45
  llm_cost: $129
  
  # Total
  infrastructure: $320
  llm: $129
  total: $449/mo

revenue_monthly:
  # Mix: 50 basic, 30 pro, 20 whale
  rare: (50×50 + 30×100 + 20×250) = 10,500 RARE
  eth: (50×0.005 + 30×0.01 + 20×0.025) = 1.05 ETH
  
  # At RARE $0.50, ETH $3,000
  rare_value: $5,250
  eth_value: $3,150
  total: $8,400/mo

margin:
  revenue: $8,400
  costs: $449
  profit: $7,951
  margin_pct: 95%
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
  # Mix: 80% Gemini Flash, 15% Claude Haiku, 5% Sonnet
  gemini_tokens: 2.4B       # $960
  claude_haiku: 450M        # $225
  claude_sonnet: 150M       # $675
  llm_cost: $1,860
  
  # Total
  infrastructure: $1,248
  llm: $1,860
  total: $3,108/mo

revenue_monthly:
  # Mix: 500 basic, 300 pro, 200 whale
  rare: (500×50 + 300×100 + 200×250) = 105,000 RARE
  eth: (500×0.005 + 300×0.01 + 200×0.025) = 10.5 ETH
  
  # At RARE $1.00, ETH $3,000
  rare_value: $105,000
  eth_value: $31,500
  total: $136,500/mo

margin:
  revenue: $136,500
  costs: $3,108
  profit: $133,392
  margin_pct: 98%
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
  # Bulk discounts apply
  gemini_tokens: 24B        # $9,600
  claude_haiku: 4.5B        # $2,000
  claude_sonnet: 1.5B       # $6,000
  llm_cost: $17,600
  
  # DevOps & Support
  devops: $5,000            # Part-time SRE
  support_tools: $200
  
  # Total
  infrastructure: $8,399
  llm: $17,600
  operations: $5,200
  total: $31,199/mo

revenue_monthly:
  # Mix: 5,000 basic, 3,000 pro, 2,000 whale
  rare: 1,050,000 RARE
  eth: 105 ETH
  
  # At RARE $2.00, ETH $3,000
  rare_value: $2,100,000
  eth_value: $315,000
  total: $2,415,000/mo

margin:
  revenue: $2,415,000
  costs: $31,199
  profit: $2,383,801
  margin_pct: 99%
```

---

## Detailed Cost Categories

### 1. LLM Costs (Primary Variable)

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

# LLM Cost Per Bot Per Month
llm_cost_per_bot:
  gemini_flash: 20 × 30 × 2000 × $0.00025 = $0.30
  claude_haiku: 20 × 30 × 2000 × $0.000375 = $0.45
  claude_sonnet: 20 × 30 × 2000 × $0.0045 = $5.40

# At Scale (1,000 bots)
gemini_total: $300/mo
haiku_total: $450/mo
sonnet_total: $5,400/mo
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

1. **Primary**: Gemini 2.0 Flash (cheapest, fast)
2. **Secondary**: Claude 3 Haiku (better reasoning)
3. **Complex**: Claude 3.5 Sonnet (critical decisions only)
4. **Skip**: On-chain models (too expensive)

### Infrastructure

1. **Start**: Fly.io + Supabase Free + Alchemy Free
2. **Scale**: Upgrade as needed (auto-scale)
3. **Optimize**: Caching, batching, smart routing

### Cost Management

1. **Monitor**: Daily cost tracking
2. **Alerts**: Notify at 80% budget
3. **Optimize**: Weekly cost review
4. **Scale**: Only when profitable

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
