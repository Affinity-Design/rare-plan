# Rare Trade - AI Agent Trading Platform

> Autonomous AI trading agents powered by RARE token
> Users supply strategy, we supply the agents

---

## Executive Summary

**Rare Trade** is a decentralized AI trading platform where:
- Users pay RARE to activate autonomous trading bots
- Users define strategy, agents execute trades
- Winners are posted to a public leaderboard
- Others can "copy" successful strategies
- Premium users keep their bots private
- All controlled via Telegram + API subscription

---

## Business Model

### Revenue Streams

| Stream | Description | Pricing |
|--------|-------------|---------|
| **Bot Activation** | Pay RARE to spawn a trading agent | 1,000 RARE/month |
| **Strategy Copy** | Copy a winning strategy | 500 RARE/clone |
| **Privacy Premium** | Hide bot from leaderboard | 2,000 RARE/month |
| **Skill Marketplace** | Sell/buy custom strategies | 10% fee |
| **API Access** | Direct API for power users | 5,000 RARE/month |

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
│        │         │   - Strategy creators           │   │
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
│                        RARE TRADE PLATFORM                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐       │
│  │   TELEGRAM   │    │   WEB APP    │    │   API/SDK    │       │
│  │     BOT      │    │  (Dashboard) │    │  (Power Ux)  │       │
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
│  │  AGENT      │    │  STATE      │    │  MARKET     │         │
│  │  ORCHESTRATOR│   │  MANAGER    │    │  DATA       │         │
│  │  (LangGraph)│    │  (MemGPT)   │    │  FEED       │         │
│  └──────┬──────┘    └──────┬──────┘    └──────┬──────┘         │
│         │                  │                   │               │
│         └──────────────────┼───────────────────┘               │
│                            │                                   │
│                            ▼                                   │
│                  ┌─────────────────────┐                        │
│                  │    EXECUTION        │                        │
│                  │    ENGINE           │                        │
│                  └──────────┬──────────┘                        │
│                             │                                   │
│         ┌───────────────────┼───────────────────┐               │
│         ▼                   ▼                   ▼               │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │    BASE     │    │  ETHEREUM   │    │   OTHER     │         │
│  │   (Primary) │    │  (Main)     │    │   CHAINS    │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Core Components

#### 1. Agent Orchestrator (LangGraph)

```
┌─────────────────────────────────────────────────────┐
│              ReAct AGENT LOOP                       │
├─────────────────────────────────────────────────────┤
│                                                     │
│   ┌─────────┐    ┌─────────┐    ┌─────────┐       │
│   │ OBSERVE │───▶│  REASON │───▶│   ACT   │       │
│   │         │    │         │    │         │       │
│   │ Market  │    │ Strategy│    │ Execute │       │
│   │ Data    │    │ Analysis│    │ Trade   │       │
│   └─────────┘    └────┬────┘    └────┬────┘       │
│        ▲              │              │             │
│        │              ▼              ▼             │
│        │       ┌──────────┐   ┌──────────┐        │
│        │       │  DECIDE  │   │  REFLECT │        │
│        │       │          │   │          │        │
│        │       │ Continue │   │ Learn &  │        │
│        │       │ or Exit  │   │ Adjust   │        │
│        │       └──────────┘   └────┬─────┘        │
│        │                             │             │
│        └─────────────────────────────┘             │
│                                                     │
└─────────────────────────────────────────────────────┘
```

#### 2. State Manager (MemGPT Pattern)

```typescript
interface AgentState {
  // Core Memory (always in context)
  core: {
    identity: string;        // Agent name, type
    strategy: Strategy;      // User-defined rules
    riskProfile: RiskLevel;  // Conservative/Moderate/Aggressive
    activePositions: Position[];
    dailyPnL: number;
  };
  
  // Working Memory (recent context)
  working: {
    recentTrades: Trade[];   // Last 50 trades
    marketContext: string;   // Current market analysis
    pendingActions: Action[];
  };
  
  // Archival Memory (searchable history)
  archival: {
    allTrades: Trade[];      // Full trade history
    performance: Metrics;    // Historical performance
    lessons: string[];       // Learned patterns
  };
}
```

#### 3. Telegram Bot Interface

```
User Commands:
├── /start - Create new agent
├── /deposit - Fund agent wallet
├── /strategy - Set trading rules
│   ├── /strategy set <type>
│   ├── /strategy params <json>
│   └── /strategy test
├── /status - View agent status
├── /pause - Pause trading
├── /resume - Resume trading
├── /withdraw - Withdraw funds
├── /leaderboard - View top performers
├── /copy <agent_id> - Copy a strategy
└── /premium - Upgrade to private

Admin Commands:
├── /admin agents - List all agents
├── /admin metrics - Platform metrics
└── /admin emergency - Emergency pause all
```

---

## Trading Strategies

### Strategy Types

| Type | Timeframe | Risk | Description |
|------|-----------|------|-------------|
| **HFT** | Seconds | High | High-frequency arbitrage |
| **Scalp** | Minutes | Med-High | Quick profit taking |
| **Intraday** | Hours | Medium | Day trading patterns |
| **Swing** | Days | Medium | Multi-day trends |
| **Position** | Weeks | Low | Long-term positions |

### Default Strategies (Built-in)

```yaml
# Conservative Swing
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

# Aggressive Scalp
name: "Aggressive Scalp"
timeframe: "5m"
risk: "high"
rules:
  - max_position_size: 15% of portfolio
  - stop_loss: 3%
  - take_profit: 5%
  - max_trades_per_day: 50
indicators:
  - Volume spike > 2x average
  - Price breakout from consolidation
  - MACD crossover

# Smart Swing (AI-Enhanced)
name: "Smart Swing"
timeframe: "4h"
risk: "medium"
rules:
  - max_position_size: 10%
  - dynamic_stop_loss: ATR * 2
  - take_profit: risk * 2
ai_features:
  - sentiment_analysis: true
  - pattern_recognition: true
  - adaptive_sizing: true
```

### User Strategy Format

```typescript
interface UserStrategy {
  id: string;
  name: string;
  description: string;
  
  // Trading pairs
  pairs: string[];  // ["BTC/USDC", "ETH/USDC", "RARE/USDC"]
  
  // Chain preference
  chain: "base" | "ethereum" | "solana" | "multi";
  
  // Risk parameters
  risk: {
    maxPositionSize: number;  // % of portfolio
    maxDrawdown: number;      // % max loss
    stopLoss: number;         // % per trade
    takeProfit: number;       // % target
  };
  
  // Entry rules
  entry: {
    indicators: Indicator[];
    conditions: Condition[];
    aiAssist: boolean;
  };
  
  // Exit rules
  exit: {
    indicators: Indicator[];
    conditions: Condition[];
    trailing: boolean;
  };
  
  // Schedule
  schedule: {
    active: boolean;
    timezone: string;
    tradingHours: { start: string; end: string }[];
  };
}
```

---

## Leaderboard System

### Metrics

```typescript
interface LeaderboardEntry {
  rank: number;
  agentId: string;
  ownerId: string;  // Optional (private bots hide this)
  isPrivate: boolean;
  
  // Performance
  metrics: {
    totalReturn: number;      // % ROI
    monthlyReturn: number;
    winRate: number;          // % winning trades
    sharpeRatio: number;
    maxDrawdown: number;
    totalTrades: number;
    avgHoldingTime: number;   // hours
  };
  
  // Strategy info (public bots only)
  strategyPreview: {
    type: string;
    timeframe: string;
    riskLevel: string;
    topPairs: string[];
  };
  
  // Copy pricing
  copyPrice: number;  // RARE tokens
  copyCount: number;  // How many times copied
  
  // Timestamps
  createdAt: Date;
  updatedAt: Date;
}
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

---

## Skill Marketplace

### Anthropic Skills Convention

Users can create and sell custom trading skills:

```typescript
interface TradingSkill {
  id: string;
  name: string;
  description: string;
  author: string;
  version: string;
  
  // Skill definition
  type: "indicator" | "strategy" | "risk" | "utility";
  config: {
    inputs: SkillInput[];
    outputs: SkillOutput[];
    parameters: SkillParam[];
  };
  
  // Pricing
  price: {
    oneTime: number;      // RARE tokens
    subscription: number; // RARE/month
  };
  
  // Stats
  stats: {
    downloads: number;
    rating: number;
    reviews: number;
  };
  
  // Code (sandboxed)
  code: string;  // JavaScript/TypeScript
}
```

### Skill Examples

```yaml
# Example: RSI Divergence Detector
name: "RSI Divergence Pro"
type: "indicator"
description: "Detects bullish/bearish RSI divergences"
price:
  oneTime: 100 RARE
  subscription: 0
code: |
  export function analyze(candles, rsi) {
    const divergences = [];
    for (let i = 2; i < candles.length; i++) {
      // Bullish divergence
      if (candles[i].low < candles[i-1].low && 
          rsi[i] > rsi[i-1]) {
        divergences.push({
          type: 'bullish',
          index: i,
          confidence: calculateConfidence(i)
        });
      }
    }
    return divergences;
  }

# Example: Smart Position Sizer
name: "Kelly Criterion Sizer"
type: "risk"
description: "Uses Kelly Criterion for optimal position sizing"
price:
  oneTime: 0
  subscription: 50 RARE/month
code: |
  export function calculateSize(winRate, avgWin, avgLoss, portfolio) {
    const kelly = (winRate * avgWin - (1 - winRate) * avgLoss) / avgWin;
    const fractionalKelly = kelly * 0.5; // Use half-Kelly for safety
    return portfolio * Math.max(0, Math.min(0.25, fractionalKelly));
  }
```

---

## Infrastructure

### Tech Stack

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
  llm: "Claude 3.5 Sonnet (primary)"
  fallback: "GPT-4o"

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

### Scaling Architecture

```
┌────────────────────────────────────────────────────────────┐
│                    AUTO-SCALING LAYER                      │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    │
│  │   AGENT     │    │   AGENT     │    │   AGENT     │    │
│  │  POD 1-10   │    │  POD 11-20  │    │  POD 21-30  │    │
│  │  (HFT)      │    │  (Intraday) │    │  (Swing)    │    │
│  └──────┬──────┘    └──────┬──────┘    └──────┬──────┘    │
│         │                  │                  │           │
│         └──────────────────┼──────────────────┘           │
│                            │                              │
│                            ▼                              │
│                  ┌─────────────────────┐                  │
│                  │   MESSAGE QUEUE     │                  │
│                  │   (BullMQ + Redis)  │                  │
│                  └──────────┬──────────┘                  │
│                             │                             │
│         ┌───────────────────┼───────────────────┐         │
│         ▼                   ▼                   ▼         │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐   │
│  │   TRADE     │    │   STATE     │    │   ANALYTICS │   │
│  │  EXECUTOR   │    │  PERSIST    │    │  WRITER     │   │
│  │  WORKERS    │    │  WORKERS    │    │  WORKERS    │   │
│  └─────────────┘    └─────────────┘    └─────────────┘   │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

---

## Security

### API Key Management

```typescript
interface APIAuth {
  // User authentication
  userId: string;
  walletAddress: string;
  
  // Subscription status
  subscription: {
    active: boolean;
    tier: "free" | "basic" | "premium" | "enterprise";
    expiresAt: Date;
    rareBalance: number;
  };
  
  // API keys
  keys: {
    telegram: string;    // Bot token (user-specific)
    api: string;         // REST API key
    websocket: string;   // WS connection key
  };
  
  // Rate limits
  rateLimit: {
    requestsPerMinute: number;
    tradesPerDay: number;
  };
}
```

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

---

## MVP Roadmap

### Phase 1: Foundation (Week 1-2)
- [ ] API scaffold (Hono + Bun)
- [ ] Database schema (Supabase)
- [ ] Telegram bot basics
- [ ] Subscription system
- [ ] Basic agent loop (ReAct)

### Phase 2: Trading (Week 3-4)
- [ ] Base chain integration
- [ ] DEX aggregator (1inch API)
- [ ] Basic strategies (3 built-in)
- [ ] Paper trading mode
- [ ] Trade execution engine

### Phase 3: Intelligence (Week 5-6)
- [ ] LangGraph orchestration
- [ ] MemGPT state management
- [ ] Market data feeds
- [ ] Technical indicators
- [ ] Performance tracking

### Phase 4: Social (Week 7-8)
- [ ] Leaderboard system
- [ ] Copy trading
- [ ] Privacy premium
- [ ] Public profiles

### Phase 5: Marketplace (Week 9-10)
- [ ] Skill publishing
- [ ] Skill marketplace
- [ ] Revenue sharing
- [ ] Skill sandbox

### Phase 6: Scale (Week 11-12)
- [ ] Multi-chain support
- [ ] Auto-scaling
- [ ] Advanced strategies
- [ ] Enterprise features

---

## Success Metrics

| Metric | Target (Month 3) | Target (Month 6) |
|--------|------------------|------------------|
| Active Agents | 100 | 1,000 |
| Daily Trades | 500 | 10,000 |
| RARE Burned | 50,000 | 500,000 |
| Copy Trades | 50 | 2,000 |
| Skills Listed | 20 | 200 |
| Revenue (USD) | $5,000 | $50,000 |

---

## Next Steps

1. **Review this plan** - Feedback on architecture/model
2. **Prioritize MVP** - What to build first
3. **Set up infrastructure** - Supabase, Fly.io accounts
4. **Start coding** - Begin with API scaffold

---

*Created by Felix | Rare Coin*
*Last Updated: 2026-03-02*
