# Infrastructure TODO

> Backend, database, and infrastructure tasks

---

## 🔥 Critical

| # | Task | Assignee | Status | Notes |
|---|------|----------|--------|-------|
| 1 | Create Supabase tables | Felix | ✅ Done | Migration SQL in repo |
| 2 | Set up Row Level Security | Felix | ✅ Done | Policies in migration |
| 3 | Configure Base Chain RPC | Felix | ✅ Done | Fallback RPCs configured |
| 4 | Set up Cloudflare Turnstile | Felix | ✅ Done | Verify endpoint ready |

---

## 🟡 In Progress

### Supabase
| # | Task | Assignee | Status |
|---|------|----------|--------|
| 1 | Create users table | Felix | ✅ Done |
| 2 | Create registrations table | Felix | ✅ Done |
| 3 | Create claims table | Felix | ✅ Done |
| 4 | Create stakes table | Felix | ✅ Done |
| 5 | Create lottery_entries table | Felix | ✅ Done |
| 6 | Create lottery_winners table | Felix | ✅ Done |
| 7 | Create blog_posts table | Felix | ✅ Done |
| 8 | Create claim_periods table | Felix | ✅ Done |
| 9 | Create settings table | Felix | ✅ Done |
| 10 | Create bot_detections table | Felix | ✅ Done |

### API Routes
| # | Task | Assignee | Status |
|---|------|----------|--------|
| 1 | Create /api/auth routes | Felix | ⏳ Pending |
| 2 | Create /api/claims routes | Felix | ✅ Done | v3/fountain, v3/fee |
| 3 | Create /api/stakes routes | Felix | ✅ Done | v3/staking/tvl |
| 4 | Create /api/lottery routes | Felix | ✅ Done | v3/lottery/status |
| 5 | Create /api/verify-captcha | Felix | ✅ Done | v3/verify/turnstile |

---

## ⏳ Pending

### Base Chain Setup
| # | Task | Assignee | Status |
|---|------|----------|--------|
| 1 | Get Base RPC URL | PaulySun | ✅ Done | Using public RPCs |
| 2 | Configure wagmi for Base | Felix | ✅ Done | In src/config |
| 3 | Test Base connection | Felix | ✅ Done | Viem client ready |
| 4 | Set up event listeners | Felix | ⏳ Pending |

### Cloudflare Turnstile
| # | Task | Assignee | Status |
|---|------|----------|--------|
| 1 | Create Turnstile account | PaulySun | ⏳ Pending |
| 2 | Get site key | PaulySun | ⏳ Pending |
| 3 | Get secret key | PaulySun | ⏳ Pending |
| 4 | Add widget to frontend | Felix | ⏳ Pending |
| 5 | Add server verification | Felix | ✅ Done | API endpoint ready |

### PhoneDB Migration
| # | Task | Assignee | Status |
|---|------|----------|--------|
| 1 | Export old data (if possible) | PaulySun | ⏳ Pending |
| 2 | Map old schema to new | Felix | ⏳ Pending |
| 3 | Migrate user data | Felix | ⏳ Pending |
| 4 | Verify migration | Felix | ⏳ Pending |

### Monitoring & Logging
| # | Task | Assignee | Status |
|---|------|----------|--------|
| 1 | Set up error tracking | Felix | ⏳ Pending |
| 2 | Set up uptime monitoring | Felix | ⏳ Pending |
| 3 | Configure log aggregation | Felix | ⏳ Pending |
| 4 | Set up alerts | Felix | ⏳ Pending |

---

## 🚫 Blockers

| Blocker | Resolution |
|---------|------------|
| Turnstile keys missing | PaulySun to create account + get keys |
| Contract addresses (testnet) | Need to deploy V3 contracts |

---

## ✅ Completed

| Task | Completed |
|------|-----------|
| Supabase project created | 2026-02-24 |
| Database schema designed | 2026-02-24 |
| RLS policies defined | 2026-02-24 |
| API keys secured | 2026-02-24 |
| Supabase migration SQL | 2026-03-02 |
| Supabase client library | 2026-03-02 |
| Base chain viem client | 2026-03-02 |
| Chainlink price feeds | 2026-03-02 |
| Turnstile verify endpoint | 2026-03-02 |
| V3 API routes (fountain, fee, staking, lottery) | 2026-03-02 |
| User stats API (Supabase-backed) | 2026-03-02 |

---

*Last Updated: 2026-02-24*
