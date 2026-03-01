# Rare Claims (rare.claims) - Master TODO

> Unified plan for dApp frontend, API migration, and Supabase backend

---

## 🔥 Critical Path

| # | Task | Assignee | Status | Notes |
|---|------|----------|--------|-------|
| 1 | Deploy V3 contracts to Base testnet | Felix | ⏳ Pending | All 4 contracts ready |
| 2 | Migrate API to Base endpoints | Felix | ⏳ Pending | **BLOCKER for frontend** |
| 3 | FaunaDB → Supabase migration | Felix | ⏳ Pending | Data schema ready |
| 4 | Web3 wallet connection | Felix | ⏳ Pending | wagmi + viem |
| 5 | Deploy to rare.claims | PaulySun | ⏳ Pending | After all above |

---

## 📋 Contract Integration (V3)

### Contract Addresses (Base Chain - TBD)

| Contract | Address | Status |
|----------|---------|--------|
| RareTokenV3 | TBD | ⏳ Testnet pending |
| RareFountainV3 | TBD | ⏳ Testnet pending |
| RareStakingV3 | TBD | ⏳ Testnet pending |
| RareLotteryV3 | TBD | ⏳ Testnet pending |

### V3 Features to Integrate

#### Fountain (Claiming)
- [ ] **3-Tier Whitelist UI** - Show eligibility status
- [ ] **Streak Counter** - Display current streak + bonus tier
- [ ] **Holding Perks** - Show RARE balance tier
- [ ] **USD Fee Display** - Show $0.10 fee in ETH (via Chainlink)
- [ ] **Dual-Pool Status** - Pool A/B indicator
- [ ] **Claim Countdown** - 24h timer to next claim

#### Staking
- [ ] **Term Selection** - 7d/28d/84d with multipliers
- [ ] **Holding Perks Display** - Show bonus tier
- [ ] **USD Fee Display** - Show $0.10 fee in ETH
- [ ] **Weekly Claim Timer** - 7-day countdown
- [ ] **LP Calculator** - Estimate underlying RARE

#### Lottery
- [ ] **VRF Integration** - Display VRF status
- [ ] **Entry Limits** - Max 5 entries indicator
- [ ] **Prize Pool** - Live ETH + RARE total
- [ ] **Player Count** - Minimum 3 players
- [ ] **Draw Countdown** - Time to next draw

---

## 🔌 API Migration Plan

### Current State (Gnosis/xDAI)

| Endpoint | Purpose | Status |
|----------|---------|--------|
| `/api/claim` | Claim operations | ❌ Gnosis only |
| `/api/stake` | Staking operations | ❌ Gnosis only |
| `/api/lotto` | Lottery operations | ❌ Gnosis only |
| `/api/user/:address` | User stats | ❌ Gnosis only |

### New State (Base Chain)

| Endpoint | Purpose | Changes |
|----------|---------|---------|
| `/api/v3/claim` | Claim operations | Base RPC, V3 ABI |
| `/api/v3/stake` | Staking operations | Base RPC, V3 ABI |
| `/api/v3/lottery` | Lottery operations | Base RPC, V3 ABI |
| `/api/v3/user/:address` | User stats | Streak, holding tier |
| `/api/v3/price` | ETH/USD from Chainlink | New endpoint |
| `/api/v3/eligibility/:address` | 3-Tier check | New endpoint |

### API Architecture

```
┌─────────────────────────────────────────────────┐
│                  Frontend (Next.js)              │
│  rare.claims - React + wagmi + viem            │
└────────────────────┬────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
┌───────────────┐         ┌───────────────┐
│  Base RPC     │         │   Supabase    │
│  (Read/Write) │         │   (Storage)   │
└───────────────┘         └───────────────┘
        │                         │
        │                         │
        ▼                         ▼
┌───────────────┐         ┌───────────────┐
│  V3 Contracts │         │  User Data    │
│  Fountain     │         │  Streaks      │
│  Staking      │         │  History      │
│  Lottery      │         │  Analytics    │
└───────────────┘         └───────────────┘
```

### Implementation Files

```typescript
// lib/api/base-client.ts
import { createPublicClient, createWalletClient, http } from 'viem'
import { base } from 'wagmi/chains'

export const publicClient = createPublicClient({
  chain: base,
  transport: http('https://mainnet.base.org'),
})

export const walletClient = createWalletClient({
  chain: base,
  transport: http(),
})

// Contract instances
export const fountainContract = {
  address: '0x...' as `0x${string}`,
  abi: RareFountainV3ABI,
}

export const stakingContract = {
  address: '0x...' as `0x${string}`,
  abi: RareStakingV3ABI,
}

export const lotteryContract = {
  address: '0x...' as `0x${string}`,
  abi: RareLotteryV3ABI,
}
```

---

## 🗄️ FaunaDB → Supabase Migration

### Current FaunaDB Schema

```javascript
// Users collection
{
  address: String,
  claims: Number,
  stakes: Array,
  lotteryEntries: Number,
  lastClaim: Timestamp,
}

// Claims collection
{
  user: Ref(Users),
  amount: Number,
  timestamp: Timestamp,
  pool: String, // "A" or "B"
}
```

### New Supabase Schema

```sql
-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_address TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- V3 fields
  claim_streak INTEGER DEFAULT 0,
  last_claim_day INTEGER DEFAULT 0,
  holding_tier INTEGER DEFAULT 0,
  
  -- Stats
  total_claims INTEGER DEFAULT 0,
  total_rare_claimed DECIMAL(38,18) DEFAULT 0,
  total_stakes INTEGER DEFAULT 0,
  total_lottery_entries INTEGER DEFAULT 0
);

-- Claims history
CREATE TABLE claims (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  amount DECIMAL(38,18) NOT NULL,
  bonus_applied INTEGER DEFAULT 0, -- basis points
  pool_cycle INTEGER NOT NULL,
  tx_hash TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Stakes
CREATE TABLE stakes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  amount DECIMAL(38,18) NOT NULL,
  term INTEGER NOT NULL, -- 0=7d, 1=28d, 2=84d
  multiplier INTEGER NOT NULL,
  start_time TIMESTAMPTZ DEFAULT NOW(),
  end_time TIMESTAMPTZ NOT NULL,
  last_claim_time TIMESTAMPTZ,
  active BOOLEAN DEFAULT TRUE,
  tx_hash TEXT
);

-- Lottery entries
CREATE TABLE lottery_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  lottery_round INTEGER NOT NULL,
  entry_count INTEGER DEFAULT 1,
  tx_hash TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Lottery rounds
CREATE TABLE lottery_rounds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  round_number INTEGER UNIQUE NOT NULL,
  start_time TIMESTAMPTZ DEFAULT NOW(),
  end_time TIMESTAMPTZ,
  winner_address TEXT,
  prize_eth DECIMAL(38,18),
  prize_rare DECIMAL(38,18),
  total_entries INTEGER DEFAULT 0,
  status TEXT DEFAULT 'active' -- 'active', 'drawing', 'completed'
);

-- Streak history (for analytics)
CREATE TABLE streak_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  streak_before INTEGER,
  streak_after INTEGER,
  event_type TEXT, -- 'continue', 'reset', 'milestone'
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_users_wallet ON users(wallet_address);
CREATE INDEX idx_claims_user ON claims(user_id);
CREATE INDEX idx_claims_created ON claims(created_at DESC);
CREATE INDEX idx_stakes_user ON stakes(user_id);
CREATE INDEX idx_stakes_active ON stakes(active) WHERE active = TRUE;
CREATE INDEX idx_lottery_round ON lottery_entries(lottery_round);
```

### Migration Script

```typescript
// scripts/migrate-fauna-to-supabase.ts
import { Client as FaunaClient, query } from 'faunadb'
import { createClient } from '@supabase/supabase-js'

const fauna = new FaunaClient({
  secret: process.env.FAUNA_SECRET!
})

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_KEY!
)

async function migrateUsers() {
  // Fetch all users from FaunaDB
  const { data: faunaUsers } = await fauna.query(
    query.Map(
      query.Paginate(query.Documents(query.Collection('users'))),
      query.Lambda('ref', query.Get(query.Ref))
    )
  )

  // Transform and insert into Supabase
  for (const user of faunaUsers.data) {
    const { data, error } = await supabase
      .from('users')
      .upsert({
        wallet_address: user.data.address.toLowerCase(),
        total_claims: user.data.claims || 0,
        total_lottery_entries: user.data.lotteryEntries || 0,
        created_at: user.data.lastClaim || new Date().toISOString()
      })

    if (error) {
      console.error(`Failed to migrate user ${user.data.address}:`, error)
    } else {
      console.log(`Migrated user: ${user.data.address}`)
    }
  }

  console.log(`Migration complete: ${faunaUsers.data.length} users`)
}

migrateUsers()
```

### Supabase Connection

```typescript
// lib/supabase/client.ts
import { createClient } from '@supabase/supabase-js'

export const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

// Server-side admin client
export const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)
```

---

## 🎨 Frontend Components

### Phase 1: Core UI (Week 1)

| Component | Status | Notes |
|-----------|--------|-------|
| Wallet Connect | ⏳ Pending | wagmi + RainbowKit |
| Glass Card | ✅ Done | Reusable container |
| Stat Card | ⏳ Pending | For metrics display |
| Countdown Timer | ⏳ Pending | For claims/lottery |
| Streak Badge | ⏳ Pending | Visual tier indicator |
| Holding Tier Badge | ⏳ Pending | RARE balance tier |
| Fee Display | ⏳ Pending | USD → ETH via Chainlink |

### Phase 2: Page Implementations (Week 2)

| Page | Status | Features |
|------|--------|----------|
| `/claim` | ⏳ Pending | Streak, holding tier, whitelist status, fee |
| `/stake` | ⏳ Pending | Term selection, APY, holding perks |
| `/lottery` | ⏳ Pending | Prize pool, entry limit, VRF status |
| `/profile` | ⏳ Pending | History, stats, streak tracking |
| `/swap` | ⏳ Pending | DEX integration (optional) |

### Phase 3: Web3 Integration (Week 3)

| Feature | Status | Notes |
|---------|--------|-------|
| Base Chain config | ⏳ Pending | RPC endpoints |
| Contract ABIs | ⏳ Pending | Import from V3 contracts |
| Read functions | ⏳ Pending | viem publicClient |
| Write functions | ⏳ Pending | viem walletClient |
| Transaction tracking | ⏳ Pending | Toast notifications |

---

## 🚀 Deployment Checklist

### Pre-Deployment

- [ ] V3 contracts deployed to Base mainnet
- [ ] Contract addresses added to environment
- [ ] Supabase tables created
- [ ] FaunaDB data migrated
- [ ] API endpoints tested
- [ ] Chainlink price feeds verified
- [ ] Cloudflare Turnstile configured

### Deployment

- [ ] Build frontend (`npm run build`)
- [ ] Deploy to Vercel
- [ ] Connect `rare.claims` domain
- [ ] Enable Vercel Analytics
- [ ] Test all flows on mainnet

### Post-Deployment

- [ ] Monitor error logs
- [ ] Track user signups
- [ ] Verify streak tracking
- [ ] Check lottery draws
- [ ] Monitor gas usage

---

## 📅 Timeline

| Week | Phase | Deliverables |
|------|-------|--------------|
| **1** | Contracts | Deploy V3 to Base testnet, verify ABIs |
| **2** | API | Migrate endpoints to Base, Supabase setup |
| **3** | Frontend | Core components, wallet connection |
| **4** | Integration | Connect UI to contracts + API |
| **5** | Testing | Full flow testing on testnet |
| **6** | Deploy | Mainnet deployment + monitoring |

---

## 🔗 Related Files

| File | Purpose |
|------|---------|
| `contracts/PERKS-SYSTEM.md` | Streak & holding bonus docs |
| `contracts/migration-plan.md` | Gnosis → Base migration |
| `contracts/MASTER-AUDIT-V3.md` | Security audit |

---

*Last Updated: 2026-03-01*
*Status: Ready for implementation*
