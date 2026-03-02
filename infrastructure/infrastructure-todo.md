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
| 11 | Add database triggers for stats | Felix | ✅ Done |
| 12 | Create helper views (leaderboard, activity) | Felix | ✅ Done |
| 13 | React hooks for data fetching | Felix | ✅ Done |
| 14 | Real-time subscriptions | Felix | ✅ Done |

### API Routes
| # | Task | Assignee | Status |
|---|------|----------|--------|
| 1 | Create /api/auth routes | Felix | ⏳ Pending |
| 2 | Create /api/claims routes | Felix | ✅ Done | v3/fountain, v3/fee, v3/claims/log |
| 3 | Create /api/stakes routes | Felix | ✅ Done | v3/staking/tvl, v3/stakes/log |
| 4 | Create /api/lottery routes | Felix | ✅ Done | v3/lottery/status, v3/lottery/enter |
| 5 | Create /api/verify-captcha | Felix | ✅ Done | v3/verify/turnstile |
| 6 | Create /api/users/register | Felix | ✅ Done | v3/users/register |
| 7 | Create /api/stats/global | Felix | ✅ Done | v3/stats/global |

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

### ~~PhoneDB Migration~~
| # | Task | Assignee | Status |
|---|------|----------|--------|
| ~~1~~ | ~~Export old data~~ | ~~PaulySun~~ | ❌ N/A | FaunaDB sunset - data lost |
| ~~2~~ | ~~Map old schema~~ | ~~Felix~~ | ❌ N/A | Fresh start |
| ~~3~~ | ~~Migrate user data~~ | ~~Felix~~ | ❌ N/A | Fresh start |
| ~~4~~ | ~~Verify migration~~ | ~~Felix~~ | ❌ N/A | Fresh start |

> **Note:** FaunaDB sunset and all data was lost. Starting fresh with Supabase.

### Monitoring & Logging
| # | Task | Assignee | Status |
|---|------|----------|--------|
| 1 | Set up error tracking | Felix | ✅ Done | src/lib/error-tracking.ts |
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
| Supabase admin client | 2026-03-02 |
| Supabase React hooks | 2026-03-02 |
| Supabase real-time subscriptions | 2026-03-02 |
| Database triggers for stats | 2026-03-02 |
| Helper views (leaderboard, activity) | 2026-03-02 |
| Base chain viem client | 2026-03-02 |
| Chainlink price feeds | 2026-03-02 |
| Turnstile verify endpoint | 2026-03-02 |
| V3 API routes (fountain, fee, staking, lottery) | 2026-03-02 |
| Write API routes (claims, stakes, lottery, users) | 2026-03-02 |
| User stats API (Supabase-backed) | 2026-03-02 |
| Global stats API | 2026-03-02 |
| Turnstile widget component | 2026-03-02 |
| Countdown timer component | 2026-03-02 |
| Streak badge component | 2026-03-02 |
| Holding tier component | 2026-03-02 |
| Error tracking utility | 2026-03-02 |
| Frontend component audit | 2026-03-02 |
| Frontend overhaul plan | 2026-03-02 |
| FaunaDB migration | ❌ N/A | Data lost - fresh start |

---

*Last Updated: 2026-03-02*
