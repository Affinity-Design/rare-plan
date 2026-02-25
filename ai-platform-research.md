# AI Trading Platform - Pricing & Scope Research

## 1. Pricing Strategy

### The Challenge
- Price in USD ($5 creation fee)
- Pay in RARE (needs price conversion)
- Or use USDC (stable but no RARE utility)

### Options Analysis

#### Option A: Price in USD, Pay in RARE
```
$5 fee = ? RARE
Need: RARE/USD price feed on-chain
Problem: Price fluctuates, user doesn't know exact RARE amount
```

**On-chain price feed options:**
1. **Uniswap V3 TWAP** - Time-weighted average from RARE/USDC pool
2. **Chainlink** - Custom price feed (expensive to set up)
3. **Pyth Network** - Off-chain price, on-chain verification
4. **Manual oracle** - Manager updates price (centralized)

#### Option B: Price in USDC, RARE Holders Get Discounts
```
$5 fee in USDC
Hold 100 RARE → 10% discount → $4.50
Hold 1000 RARE → 25% discount → $3.75
Stake RARE → 50% discount → $2.50
```

**Benefits:**
- Stable pricing (USDC)
- RARE has utility (discounts)
- Easy to understand
- No price conversion needed

#### Option C: Hybrid (RECOMMENDED)
```
Base price: $5 USDC
Payment options:
  - Pay $5 USDC, OR
  - Pay equivalent RARE (5% discount)
  
RARE holder benefits:
  - Hold 100 RARE: 10% discount
  - Hold 1000 RARE: 20% discount
  - Stake RARE: 30% discount
```

**Why this works:**
- USDC pricing is stable
- RARE has utility (discounts)
- Users can choose payment method
- No complex on-chain price feeds

---

## 2. Base Chain DEX Research

### Major DEXes on Base

| DEX | TVL | Type | Notes |
|-----|-----|------|-------|
| **Uniswap V3** | $500M+ | AMM | Most liquid, established |
| **Aerodrome** | $300M+ | AMM | Base-native, veDAO model |
| **BaseSwap** | $50M+ | AMM | Base-native |
| **SushiSwap** | $30M+ | AMM | Multi-chain |
| **PancakeSwap** | $20M+ | AMM | Recently deployed |
| **Maverick** | $15M+ | AMM | Efficient liquidity |

### Recommended DEXes to Support

**Phase 1:**
1. **Uniswap V3** - Highest liquidity, standard
2. **Aerodrome** - Base-native, growing fast

**Phase 2:**
3. **BaseSwap** - Base-native alternative
4. **SushiSwap** - Multi-chain users

### DEX APIs

| DEX | API | Documentation |
|-----|-----|---------------|
| Uniswap | SDK + Quoter | docs.uniswap.org |
| Aerodrome | Same as Velodrome | docs.velodrome.finance |
| BaseSwap | Standard DEX API | docs.baseswap.fi |

---

## 3. Tool Architecture

### Core Philosophy
> "Our job is not to hunt strategy. Our job is to create a bridge to AI agents that people can load their own strategy, and we provide the execution layer."

### Three Core Tools

#### 1. ANALYZE Tool
```typescript
// What it does
analyze(pair: string, timeframe: string) {
  return {
    priceHistory: [...],
    volumeHistory: [...],
    indicators: { RSI, MACD, EMA, ... },
    patterns: ["ascending_triangle", "double_bottom"],
    sentiment: "bullish"
  }
}
```

#### 2. PLAN Tool
```typescript
// What it does
plan(analysis: Analysis, strategy: string) {
  return {
    action: "BUY" | "SELL" | "HOLD",
    pair: "RARE/USDC",
    amount: 100,
    reason: "RSI oversold + bullish pattern",
    confidence: 0.85
  }
}
```

#### 3. EXECUTE Tool
```typescript
// What it does
execute(plan: Plan) {
  return {
    txHash: "0x...",
    status: "success",
    boughtAmount: 95.5,
    pricePerToken: 1.05,
    gasUsed: 150000
  }
}
```

### Advanced Tools (Future)

#### 4. VISION Tool (Image Analysis)
```typescript
// What it does
vision(chartImage: Image) {
  return {
    patterns: ["head_and_shoulders", "trendline_break"],
    prediction: "Likely breakout upward",
    confidence: 0.78
  }
}
```

#### 5. MPC Tool (Multi-Party Computation)
```typescript
// What it does
mpc.signTransaction(tx: Transaction) {
  // Secure key management
  // No private key exposed
  return signedTx;
}
```

#### 6. Claude SKILL Injection
```typescript
// What it does
skill.connect(service: string) {
  // Connect to ANY external service
  // Twitter, Discord, News APIs, etc.
  return connection;
}
```

---

## 4. Platform Architecture

### User Flow

```
1. User connects wallet
2. User writes/pastes strategy (master prompt)
3. User selects tools (analyze, plan, execute)
4. User sets parameters (pairs, amounts, risk)
5. Bot runs autonomously
6. User monitors via dashboard/Telegram
```

### AI Agent Integration

```
┌─────────────────────────────────────────────────────────┐
│                    User's AI Agent                       │
│  (Claude, GPT, Gemini, or custom)                       │
│                                                         │
│  Strategy: "Buy RARE when RSI < 30, sell when > 70"    │
└────────────────────────┬────────────────────────────────┘
                         │
                         │ API calls
                         ▼
┌─────────────────────────────────────────────────────────┐
│               Rare Execution Layer                       │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │ ANALYZE  │  │   PLAN   │  │ EXECUTE  │             │
│  │          │  │          │  │          │             │
│  │ - Charts │  │ - Logic  │  │ - Trades │             │
│  │ - Volume │  │ - Rules  │  │ - Gas    │             │
│  │ - Trends │  │ - Conf.  │  │ - Status │             │
│  └──────────┘  └──────────┘  └──────────┘             │
│                                                         │
└────────────────────────┬────────────────────────────────┘
                         │
                         │ DEX calls
                         ▼
┌─────────────────────────────────────────────────────────┐
│                   Base Chain DEXes                       │
│  - Uniswap V3                                           │
│  - Aerodrome                                            │
└─────────────────────────────────────────────────────────┘
```

---

## 5. Pricing Recommendation

### Fee Structure

| Action | USDC Price | RARE Discount (if staking) |
|--------|------------|---------------------------|
| **Create Public Bot** | $5 | $3.50 (30% off) |
| **Create Private Bot** | $20 | $14 (30% off) |
| **Copy Bot** | $2 | $1.40 (30% off) |
| **AI Credits (per 1000)** | $1 | $0.70 (30% off) |

### RARE Utility

| RARE Held | Discount |
|-----------|----------|
| 0 RARE | 0% |
| 100 RARE | 10% |
| 1,000 RARE | 20% |
| 10,000 RARE (Staked) | 30% |

### Payment Options

```
Option 1: Pay in USDC (stable, easy)
Option 2: Pay in RARE (5% extra discount)
```

---

## 6. Technical Implementation

### Smart Contracts Needed

| Contract | Purpose |
|----------|---------|
| **BotRegistry** | Register bots, track ownership |
| **FeeCollector** | Collect fees (USDC or RARE) |
| **DiscountChecker** | Check RARE holdings for discounts |
| **RoyaltyDistributor** | Distribute royalties to bot creators |

### Off-Chain Infrastructure

| Component | Purpose |
|-----------|---------|
| **API Server** | Handle bot creation, execution |
| **AI Bridge** | Connect to Claude/Gemini/etc. |
| **DEX Connector** | Execute trades on DEXes |
| **Telegram Bot** | User control interface |
| **Database** | Store bot configs, history |

---

## 7. Development Priority

### Phase 1 (Weeks 1-4): Token + Core
- [ ] RareTokenV2
- [ ] RareFountainV2
- [ ] RareStakingV2
- [ ] RarePool
- [ ] FeeRegistry
- [ ] Deploy to Base testnet

### Phase 2 (Weeks 5-8): Bot Foundation
- [ ] BotRegistry contract
- [ ] FeeCollector contract
- [ ] Basic API server
- [ ] Uniswap integration
- [ ] Basic ANALYZE tool

### Phase 3 (Weeks 9-12): Execution Layer
- [ ] PLAN tool
- [ ] EXECUTE tool
- [ ] AI bridge (Claude/Gemini)
- [ ] Basic dashboard

### Phase 4 (Weeks 13-16): Marketplace
- [ ] Bot marketplace UI
- [ ] Copy functionality
- [ ] Royalty distribution
- [ ] Performance tracking

### Phase 5 (Weeks 17-20): Polish
- [ ] Telegram integration
- [ ] Advanced tools (Vision, MPC)
- [ ] Security audit
- [ ] Launch preparation

---

## 8. Key Decisions Needed

| Decision | Options | Recommendation |
|----------|---------|----------------|
| **Pricing currency** | USDC vs RARE | USDC with RARE discounts |
| **DEX support** | Uniswap only vs multi | Uniswap + Aerodrome |
| **AI integration** | Claude vs Gemini vs both | Both (user choice) |
| **Bot visibility** | Public vs private | Both options |

---

## 9. Questions Answered

### Pricing
✅ Use USDC for stable pricing
✅ RARE holders get discounts (utility)
✅ No complex on-chain price feeds needed

### Scope
✅ Base Chain exclusive first
✅ Uniswap V3 + Aerodrome
✅ Three core tools: Analyze, Plan, Execute
✅ Future: Vision, MPC, Claude SKILL injection

### Philosophy
✅ We provide execution layer
✅ Users bring their own strategies
✅ AI agents connect to our tools

### Timeline
✅ Build working prototype first
✅ No announcements until ready
✅ Show up with real product backbone

---

*Research Document v1.0*
*Created: 2026-02-24*
*Author: Felix*
