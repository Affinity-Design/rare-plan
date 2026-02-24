# Infrastructure TODO

> Backend, database, and infrastructure tasks

---

## 🔥 Critical

| # | Task | Assignee | Status | Notes |
|---|------|----------|--------|-------|
| 1 | Create Supabase tables | Felix | ⏳ Pending | Schema ready |
| 2 | Set up Row Level Security | Felix | ⏳ Pending | Policies defined |
| 3 | Configure Base Chain RPC | Felix | ⏳ Pending | Need RPC URL |
| 4 | Set up Cloudflare Turnstile | Felix | ⏳ Pending | Need site key |

---

## 🟡 In Progress

### Supabase
| # | Task | Assignee | Status |
|---|------|----------|--------|
| 1 | Create users table | Felix | ⏳ Pending |
| 2 | Create registrations table | Felix | ⏳ Pending |
| 3 | Create claims table | Felix | ⏳ Pending |
| 4 | Create stakes table | Felix | ⏳ Pending |
| 5 | Create lottery_entries table | Felix | ⏳ Pending |
| 6 | Create lottery_winners table | Felix | ⏳ Pending |
| 7 | Create blog_posts table | Felix | ⏳ Pending |
| 8 | Create claim_periods table | Felix | ⏳ Pending |
| 9 | Create settings table | Felix | ⏳ Pending |
| 10 | Create bot_detections table | Felix | ⏳ Pending |

### API Routes
| # | Task | Assignee | Status |
|---|------|----------|--------|
| 1 | Create /api/auth routes | Felix | ⏳ Pending |
| 2 | Create /api/claims routes | Felix | ⏳ Pending |
| 3 | Create /api/stakes routes | Felix | ⏳ Pending |
| 4 | Create /api/lottery routes | Felix | ⏳ Pending |
| 5 | Create /api/verify-captcha | Felix | ⏳ Pending |

---

## ⏳ Pending

### Base Chain Setup
| # | Task | Assignee | Status |
|---|------|----------|--------|
| 1 | Get Base RPC URL | PaulySun | ⏳ Pending |
| 2 | Configure wagmi for Base | Felix | ⏳ Pending |
| 3 | Test Base connection | Felix | ⏳ Pending |
| 4 | Set up event listeners | Felix | ⏳ Pending |

### Cloudflare Turnstile
| # | Task | Assignee | Status |
|---|------|----------|--------|
| 1 | Create Turnstile account | PaulySun | ⏳ Pending |
| 2 | Get site key | PaulySun | ⏳ Pending |
| 3 | Get secret key | PaulySun | ⏳ Pending |
| 4 | Add widget to frontend | Felix | ⏳ Pending |
| 5 | Add server verification | Felix | ⏳ Pending |

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
| Base RPC URL unknown | PaulySun to provide |
| Turnstile keys missing | PaulySun to create account |

---

## ✅ Completed

| Task | Completed |
|------|-----------|
| Supabase project created | 2026-02-24 |
| Database schema designed | 2026-02-24 |
| RLS policies defined | 2026-02-24 |
| API keys secured | 2026-02-24 |

---

*Last Updated: 2026-02-24*
