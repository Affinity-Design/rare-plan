# Rare Trade - Master Platform Vision

> AI-powered autonomous trading bot platform
> Users supply strategy, we supply the agents
> Winners share strategies, everyone profits

---

## Executive Summary

**The Product:** AI trading bot platform where users create, configure, and monetize autonomous trading strategies.

**Core Value Proposition:**
> "Create your own AI trading bot, connect it to Telegram, and let it trade for you. Or copy the best-performing bots and earn passive income."

**Lottery's Role:** Lead magnet to bring users to the platform.

**Key Differentiator:** Fully autonomous ReAct-compliant AI agents with memory, running 24/7, controllable via Telegram.

---

## Business Model

### Revenue Streams

| Stream | Price | Notes |
|--------|-------|-------|
| **Public Bot** | 500 RARE/mo | Visible to all, earns royalties |
| **Private Bot** | 2,000 RARE/mo | Only visible to creator |
| **Copy Bot** | 500 RARE + royalties | Duplicate successful bots |
| **Strategy Copy** | 500 RARE/clone | One-time copy fee |
| **API Access** | 5,000 RARE/mo | Direct API for power users |
| **Skill Marketplace** | 10% fee | Custom strategies/indicators |

### Royalty Structure

```
Bot Creator Earns:
├── 10% of profits from direct copiers
├── 5% of profits from sub-copiers (copiers of copiers)
└── Paid in RARE tokens automatically

Platform Earns:
├── 10% of all royalties
├── Subscription fees
└── Marketplace fees
```

### Token Economics

```
┌─────────────────────────────────────────────────────────┐
│                    RARE TOKEN FLOW                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│   User Wallet ──▶ RARE Payment ──▶ Bot Activation      │
│        │                                    │          │
│        │                                    ▼          │
│        │         ┌─────────────────────────────────┐   │
│        │         │      TREASURY (50%)             │   │
│        │         │   - Development                 │   │
│        │         │   - Infrastructure              │   │
│        │         │   - Buyback & Burn              │   │
│        │         └─────────────────────────────────┘   │
│        │                                    │          │
│        │                                    ▼          │
│        │         ┌─────────────────────────────────┐   │
│        │         │      REWARDS (30%)              │   │
│        │         │   - Leaderboard prizes          │   │
│        │         │   - Royalties to creators       │   │
│        │         │   - Referral bonuses            │   │
│        │         └─────────────────────────────────┘   │
│        │                                    │          │
│        │                                    ▼          │
│        │         ┌─────────────────────────────────┐   │
│        └────────▶│      STAKING (20%)              │   │
│                  │   - Staker rewards              │   │
│                  │   - LP incentives               │   │
│                  └─────────────────────────────────┘   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Platform Architecture

### High-Level Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      RARE TRADE PLATFORM                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐       │
│  │   TELEGRAM   │    │   WEB APP    │    │   API/SDK    │       │
│  │     BOT      │    │  (Dashboard) │    │  (Power Ux)  │       │
│  │              │    │              │    │              │       │
│  │ - Commands   │    │ - Create Bot │    │ - Automation │       │
│  │ - Alerts     │    │ - Marketplace│    │ - Integration│       │
│  │ - Control    │    │ - Analytics  │    │ - Custom UI  │       │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘       │
│         │                   │                   │               │
│         └───────────────────┼───────────────────┘               │
│                             │                                   │
│                             ▼                                   │
│                  ┌─────────────────────┐                        │
│                  │    API GATEWAY      │                        │
│                  │  (Auth + Rate Ltd)  │                        │
│                  └──────────┬──────────┘                        │
│                             │                                   │
│         ┌───────────────────┼───────────────────┐               │
│         │                   │                   │               │
│         ▼                   ▼                   ▼               │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │    BOT      │    │  MARKET-    │    │  AI ENGINE  │         │
│  │  RUNNER     │    │  PLACE      │    │             │         │
│  │             │    │             │    │             │         │
│  │ - Execute   │    │ - Rankings  │    │ - Claude    │         │
│  │ - Monitor   │    │ - Copy      │    │ - Gemini    │         │
│  │ - Trade     │    │ - Royalties │    │ - Patterns  │         │
│  └──────┬──────┘    └──────┬──────┘    └──────┬──────┘         │
│         │                  │                   │               │
│         └──────────────────┼───────────────────┘               │
│                            │                                   │
│                            ▼                                   │
│                  ┌─────────────────────┐                        │
│                  │  AGENT ORCHESTRATOR │                        │
│                  │    (LangGraph)      │                        │
│                  │                     │                        │
│                  │  ReAct Loop:        │                        │
│                  │  OBSERVE → REASON   │                        │
│                  │    → DECIDE → ACT   │                        │
│                  │    → REFLECT        │                        │
│                  └──────────┬──────────┘                        │
│                             │                                   │
│         ┌───────────────────┼───────────────────┐               │
│         ▼                   ▼                   ▼               │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │   MEMORY    │    │   MARKET    │    │  EXECUTION  │         │
│  │  MANAGER    │    │    DATA     │    │   ENGINE    │         │
│  │  (MemGPT)   │    │   FEEDS     │    │             │         │
│  │             │    │             │    │             │         │
│  │ - Core      │    │ - DEX APIs  │    │ - Base      │         │
│  │ - Working   │    │ - Charts    │    │ - Ethereum  │         │
│  │ - Archive   │    │ - Prices    │    │ - Multi     │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Core Components

#### 1. Bot Runner (Agent Orchestrator)

```
┌─────────────────────────────────────────────────────┐
│              ReAct AGENT LOOP                       │
├─────────────────────────────────────────────────────┤
│                                                     │
│   ┌─────────┐    ┌─────────┐    ┌─────────┐       │
│   │ OBSERVE │───▶│  REASON │───▶│  DECIDE │       │
│   │         │    │         │    │         │       │
│   │ Market  │    │ Strategy│    │ Continue│       │
│   │ Data    │    │ Analysis│    │ or Exit │       │
│   └─────────┘    └────┬────┘    └────┬────┘       │
│        ▲              │              │             │
│        │              ▼              ▼             │
│        │       ┌──────────┐   ┌──────────┐        │
│        │       │   ACT    │   │ REFLECT  │        │
│        │       │          │   │          │        │
│        │       │ Execute  │   │ Learn &  │        │
│        │       │ Trade    │   │ Adjust   │        │
│        │       └──────────┘   └────┬─────┘        │
│        │                             │             │
│        └─────────────────────────────┘             │
│                                                     │
└─────────────────────────────────────────────────────┘
```

#### 2. Memory Manager (MemGPT Pattern)

```
┌─────────────────────────────────────────────────────┐
│                  AGENT MEMORY                       │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │  CORE MEMORY (Always in Context)            │   │
│  │  - Agent identity & type                    │   │
│  │  - Strategy rules                           │   │
│  │  - Risk profile                             │   │
│  │  - Active positions                         │   │
│  │  - Daily P&L                                │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │  WORKING MEMORY (Recent Context)            │   │
│  │  - Last 50 trades                           │   │
│  │  - Current market analysis                  │   │
│  │  - Pending actions                          │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │  ARCHIVAL MEMORY (Searchable History)       │   │
│  │  - Full trade history                       │   │
│  │  - Performance metrics                      │   │
│  │  - Learned patterns                         │   │
│  │  - Temporal knowledge graph                 │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## Bot Types & Features

### Bot Tiers

| Type | Price | Features | Visibility |
|------|-------|----------|------------|
| **Paper Bot** | Free | Simulation only, no real trades | Private |
| **Public Bot** | 500 RARE/mo | Real trading, earns royalties | Public |
| **Private Bot** | 2,000 RARE/mo | Real trading, no royalties | Private |
| **Copy Bot** | 500 RARE + royalty | Duplicates strategy | As original |

### Bot Capabilities

| Feature | Description |
|---------|-------------|
| **DEX Scanner** | Scan coin pairs across DEXes |
| **Trade History Analysis** | Analyze past trades for patterns |
| **Autonomous Trading** | Execute trades automatically 24/7 |
| **Strategy Configuration** | Master prompt defines behavior |
| **Tool Connections** | Chart scanner, DEX reader, alerts |
| **Telegram Control** | Command bot via Telegram |
| **Performance History** | Track all trades and results |
| **Memory & Learning** | Improves over time |

### Built-in Tools

| Tool | Description |
|------|-------------|
| **Chart Scanner** | Analyze price charts for patterns |
| **DEX Reader** | Read on-chain DEX data |
| **Price Alerts** | Notify on price movements |
| **Volume Tracker** | Monitor trading volume |
| **Whale Watcher** | Track large transactions |
| **Sentiment Analyzer** | Social media sentiment |
| **Pattern Recognition** | AI-detected chart patterns |

---

## Trading Strategies

### Strategy Types

| Type | Timeframe | Risk | Trades/Week | Best For |
|------|-----------|------|-------------|----------|
| **HFT** | Seconds | Very High | 1000+ | Arbitrage |
| **Scalp** | Minutes | High | 100-500 | Quick profits |
| **Intraday** | Hours | Medium | 20-50 | Day traders |
| **Swing** | Days | Medium | 5-20 | Trend followers |
| **Position** | Weeks | Low | 1-5 | Long-term growth |

### Default Strategies (Built-in)

```yaml
# 🐢 Conservative Swing
name: "Conservative Swing"
timeframe: "1D"
risk: "low"
rules:
  - max_position_size: 5% of portfolio
  - stop_loss: 10%
  - take_profit: 25%
  - max_drawdown: 15%
indicators:
  - RSI < 30 (buy signal)
  - RSI > 70 (sell signal)
  - Price > 200 EMA (trend confirmation)

# 🦊 Moderate Intraday
name: "Moderate Intraday"
timeframe: "4h"
risk: "medium"
rules:
  - max_position_size: 10% of portfolio
  - stop_loss: 5%
  - take_profit: 15%
  - max_trades_per_day: 10
indicators:
  - Volume spike > 2x average
  - MACD crossover
  - Support/resistance levels

# 🦅 Aggressive Scalp
name: "Aggressive Scalp"
timeframe: "5m"
risk: "high"
rules:
  - max_position_size: 15% of portfolio
  - stop_loss: 3%
  - take_profit: 5%
  - max_trades_per_day: 50
indicators:
  - Volume spike detection
  - Price breakout from consolidation
  - Quick momentum shifts
```

### User Strategy Format

```
Strategy: "Only buy when RSI < 30, sell when RSI > 70.
          Max position size: 5% of portfolio.
          Stop loss: 5%. Take profit: 10%."

Strategy: "Follow whale movements. Buy when whales buy,
          sell when whales sell. Use 20% position size.
          No stop loss."

Strategy: "Monitor RARE price on DEX A vs DEX B.
          Buy on cheaper, sell on more expensive.
          Min profit: 0.5%."
```

---

## Bot Marketplace

### Ranking System

```
🏆 Leaderboard
├── 🥇 Bot Alpha      - 145% APY - 89% Win - 1,234 copiers
├── 🥈 Bot Beta       - 98% APY  - 82% Win - 892 copiers
├── 🥉 Bot Gamma      - 76% APY  - 78% Win - 567 copiers
├── 4  Bot Delta      - 54% APY  - 71% Win - 423 copiers
├── 5  Bot Epsilon    - 45% APY  - 68% Win - 312 copiers
├── ...
└── 100 Bot Omega     - 5% APY   - 52% Win - 12 copiers
```

### Leaderboard Categories

| Category | Criteria |
|----------|----------|
| 🏆 **All-Time Best** | Highest total return (min 90 days) |
| 📈 **Monthly Winner** | Best monthly return |
| 🎯 **Most Accurate** | Highest win rate (min 100 trades) |
| 💎 **Most Copied** | Most strategy copies sold |
| ⚡ **Best HFT** | Best high-frequency bot |
| 🐢 **Best Swing** | Best swing trader |
| 🆕 **Rising Star** | Best new bot (< 30 days) |

### Metrics Tracked

| Metric | Description |
|--------|-------------|
| **APY** | Annual percentage yield |
| **Win Rate** | % of profitable trades |
| **Total Trades** | Number of trades made |
| **Total Volume** | $ traded |
| **Max Drawdown** | Largest loss from peak |
| **Sharpe Ratio** | Risk-adjusted return |
| **Copiers** | Users copying this bot |
| **Royalties Earned** | RARE earned from copiers |

---

## Telegram Control

### Command Reference

| Command | Description |
|---------|-------------|
| `/start` | Create new bot |
| `/deposit` | Get deposit address |
| `/balance` | Check RARE balance |
| `/create` | Create new trading bot |
| `/strategy` | Configure trading rules |
| `/tools` | Connect tools (charts, DEX) |
| `/launch` | Start trading |
| `/pause` | Pause trading |
| `/status` | View performance |
| `/history` | View trade history |
| `/withdraw` | Withdraw funds |
| `/leaderboard` | Top performers |
| `/copy <id>` | Copy a strategy |
| `/premium` | Upgrade to private |

### Example Session

```
👤 You: /status

🤖 Rare Trade Bot:
📊 Bot Alpha Performance

Today: +12.4%
Week: +34.2%
Month: +89.1%

Active Position: Long RARE/USDC
Entry: $0.42 | Current: $0.51 (+21%)

Next Trade: Monitoring RSI...
Estimated: 2 hours

Commands: /pause /history /close

👤 You: /pause

🤖 Rare Trade Bot:
⏸️ Bot Alpha paused

Current position preserved
Resume anytime: /resume
Close position: /close

👤 You: /resume

🤖 Rare Trade Bot:
▶️ Bot Alpha resumed

Monitoring markets...
Next update: 1 hour
```

---

## Skill Marketplace

### Anthropic Skills Convention

Users can create and sell custom trading skills:

| Type | Description | Example Price |
|------|-------------|---------------|
| **Indicator** | Custom indicators | 100 RARE one-time |
| **Strategy** | Complete strategies | 50 RARE/month |
| **Risk** | Risk management tools | 75 RARE/month |
| **Utility** | Helper functions | Free - 200 RARE |

### Example Skills

```javascript
// RSI Divergence Detector
export function analyze(candles, rsi) {
  const divergences = [];
  for (let i = 2; i < candles.length; i++) {
    // Bullish divergence
    if (candles[i].low < candles[i-1].low && rsi[i] > rsi[i-1]) {
      divergences.push({
        type: 'bullish',
        index: i,
        confidence: calculateConfidence(i)
      });
    }
  }
  return divergences;
}

// Kelly Criterion Position Sizer
export function calculateSize(winRate, avgWin, avgLoss, portfolio) {
  const kelly = (winRate * avgWin - (1 - winRate) * avgLoss) / avgWin;
  const fractionalKelly = kelly * 0.5; // Use half-Kelly for safety
  return portfolio * Math.max(0, Math.min(0.25, fractionalKelly));
}
```

---

## Technical Stack

### Infrastructure

```yaml
# Frontend
web_app:
  framework: "Next.js 14"
  styling: "TailwindCSS"
  state: "Zustand + React Query"
  charts: "TradingView Lightweight Charts"

telegram_bot:
  framework: "grammY"  # TypeScript Telegram framework
  state: "Redis"

# Backend
api:
  framework: "Hono"  # Fast, TypeScript-friendly
  runtime: "Bun"     # Fast JS runtime
  database: "PostgreSQL + Supabase"
  cache: "Redis"
  queue: "BullMQ"

# AI/Agents
agent_framework:
  orchestration: "LangGraph"
  memory: "MemGPT pattern"
  llm_primary: "Claude 3.5 Sonnet"
  llm_fallback: "Gemini 3.1 Flash"

# Blockchain
chains:
  primary: "Base"
  supported: ["Ethereum", "Solana", "Arbitrum"]
  rpc: "Alchemy"
  wallets: "Coinbase CDP Agentic Wallets"

# Infrastructure
hosting:
  api: "Fly.io"
  agents: "Kubernetes (auto-scaling)"
  database: "Supabase"
  cache: "Upstash Redis"
  monitoring: "Sentry + Grafana"
```

### Smart Contracts

| Contract | Purpose |
|----------|---------|
| **BotRegistry** | Register bots, track ownership |
| **BotPerformance** | Track trades, APY, rankings |
| **RoyaltyDistributor** | Distribute royalties to creators |
| **BotFactory** | Create new bots |
| **SubscriptionManager** | Handle RARE payments |

---

## Security

### Subscription Enforcement

```
Every API Request:
1. Validate API key
2. Check subscription status
3. Verify RARE balance ≥ required
4. If expired → Block access
5. If balance low → Warning + grace period
6. Log usage for billing
```

### API Key Management

- User-specific Telegram bot tokens
- Rate limiting per tier
- Encrypted wallet keys
- 2FA for withdrawals

---

## Development Roadmap

### Phase 1: Foundation (Weeks 1-4)
- [x] Vision document
- [ ] API scaffold (Hono + Bun)
- [ ] Database schema (Supabase)
- [ ] Telegram bot basics
- [ ] Subscription system
- [ ] Basic agent loop (ReAct)

### Phase 2: Trading (Weeks 5-8)
- [ ] Base chain integration
- [ ] DEX aggregator (1inch API)
- [ ] Basic strategies (3 built-in)
- [ ] Paper trading mode
- [ ] Trade execution engine

### Phase 3: AI Integration (Weeks 9-12)
- [ ] LangGraph orchestration
- [ ] MemGPT state management
- [ ] Market data feeds
- [ ] Technical indicators
- [ ] Pattern recognition
- [ ] Performance tracking

### Phase 4: Marketplace (Weeks 13-16)
- [ ] Leaderboard system
- [ ] Copy trading
- [ ] Privacy premium
- [ ] Public profiles
- [ ] Royalty distribution

### Phase 5: Skills (Weeks 17-20)
- [ ] Skill publishing
- [ ] Skill marketplace
- [ ] Revenue sharing
- [ ] Skill sandbox

### Phase 6: Scale (Weeks 21-24)
- [ ] Multi-chain support
- [ ] Auto-scaling
- [ ] Advanced strategies
- [ ] Enterprise features
- [ ] Security audit

---

## Competitive Advantage

| Feature | Rare Trade | Competitors |
|---------|------------|-------------|
| **AI-powered agents** | ✅ ReAct + MemGPT | Some |
| **No-code setup** | ✅ | Some |
| **Telegram control** | ✅ Full commands | Few |
| **Bot marketplace** | ✅ Rankings + copy | Few |
| **Royalties** | ✅ 10% + 5% sub | Rare |
| **Skill marketplace** | ✅ Sell strategies | None |
| **Base Chain native** | ✅ Primary chain | Few |
| **RARE token integration** | ✅ Required | None |
| **Memory & learning** | ✅ MemGPT | None |

---

## Success Metrics

| Metric | Month 3 | Month 6 | Year 1 |
|--------|---------|---------|--------|
| Active Bots | 100 | 1,000 | 10,000 |
| Daily Trades | 500 | 10,000 | 100,000 |
| RARE Burned | 50K | 500K | 5M |
| Copy Trades | 50 | 2,000 | 50,000 |
| Skills Listed | 20 | 200 | 2,000 |
| Volume Traded | $1M | $10M | $100M |
| Platform Revenue | $5K | $50K | $500K |

---

## Questions to Answer

### Pricing
- [ ] Finalize bot creation fees
- [ ] Royalty percentages (10/5 split?)
- [ ] Skill marketplace fees

### Technical
- [ ] Which DEXes to support first?
- [ ] Multi-chain at launch or later?
- [ ] How to handle failed trades?

### Legal
- [ ] Trading bot disclaimers
- [ ] Jurisdiction restrictions
- [ ] Insurance for losses?

---

## Next Steps

1. **Finalize pricing** - Confirm fee structure
2. **Design contracts** - BotRegistry, RoyaltyDistributor
3. **Build AI engine** - LangGraph + MemGPT
4. **Create Telegram bot** - Command interface
5. **Build marketplace UI** - Rankings, copying
6. **Set up infrastructure** - Supabase, Fly.io

---

*Master Vision Document v2.0*
*Merged from ai-trading-platform-vision.md + PLATFORM-PLAN.md*
*Created: 2026-02-24*
*Updated: 2026-03-02*
*Author: Felix*
