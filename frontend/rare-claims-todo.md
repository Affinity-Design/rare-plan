# Rare Claims Frontend TODO

> Actionable task list for frontend overhaul

---

## 🔥 Critical (Do First)

### Layout Components
| # | Task | Status | Notes |
|---|------|--------|-------|
| 1 | Create Header.tsx | ✅ Done | Logo + Nav + Wallet + Mobile menu |
| 2 | Create Footer.tsx | ✅ Done | Links + Social + Copyright |
| 3 | Create Navigation.tsx | ✅ Done | Claim/Stake/Lottery links |
| 4 | Create Layout.tsx | ✅ Done | Wrap all pages |
| 5 | Create MobileNav.tsx | ✅ Done | Integrated in Header |

### Missing UI Components
| # | Task | Status | Notes |
|---|------|--------|-------|
| 1 | Create Modal.tsx | ✅ Done | Backdrop + ESC close |
| 2 | Create Toast.tsx | ✅ Done | Provider + hook + variants |
| 3 | Create Skeleton.tsx | ✅ Done | Card, stats, table variants |
| 4 | Create EmptyState.tsx | ✅ Done | NoClaims, NoStakes, etc. |
| 5 | Create ErrorBoundary.tsx | ✅ Done | Retry + refresh options |

### Web3 Integration
| # | Task | Status | Notes |
|---|------|--------|-------|
| 1 | Create Web3Provider.tsx | ✅ Done | Wagmi config for Base |
| 2 | Update WalletConnect.tsx | ⏳ Pending | Use wagmi hooks |
| 3 | Create WalletModal.tsx | ✅ Done | Premium connection UI |
| 4 | Create NetworkSwitcher.tsx | ✅ Done | Base testnet/mainnet |

---

## 🟡 In Progress

### Page Rewrites
| # | Task | Status | Notes |
|---|------|--------|-------|
| 1 | Rewrite index.tsx (Home) | ✅ Done | Hero + Stats + How it works + Features |
| 2 | Rewrite register.js → claim.tsx | ✅ Done | Main claim flow with eligibility check |
| 3 | Rewrite stake.js | ✅ Done | Staking with term selection |
| 4 | Rewrite lotto.js → lottery.tsx | ✅ Done | Lottery with countdown |
| 5 | Create profile.tsx | ✅ Done | User dashboard |

### Component Polish
| # | Task | Status | Notes |
|---|------|--------|-------|
| 1 | Button - Add loading spinner | ✅ Done | Animated spinner |
| 2 | Button - Add glow effect | ✅ Done | Glow + pulse props |
| 3 | Badge - Add shimmer animation | ✅ Done | Animated shimmer |
| 4 | Card - Add hover animations | ✅ Done | Hover + interactive props |
| 5 | Input - Improve focus ring | ⏳ Pending |

---

## ⏳ Pending

### Contract Integration
| # | Task | Status | Notes |
|---|------|--------|-------|
| 1 | Import V3 ABIs | ⏳ Blocked | Need contract addresses |
| 2 | Create useFountain hook | ⏳ Blocked | Need addresses |
| 3 | Create useStaking hook | ⏳ Blocked | Need addresses |
| 4 | Create useLottery hook | ⏳ Blocked | Need addresses |
| 5 | Create useToken hook | ⏳ Blocked | Need addresses |

### Animations
| # | Task | Status | Notes |
|---|------|--------|-------|
| 1 | Add gradientFlow keyframes | ✅ Done | gradient-shift animation |
| 2 | Add floatY animation | ✅ Done | float-gentle animation |
| 3 | Add glowPulse animation | ✅ Done | glow-pulse animation |
| 4 | Add coinGlow animation | ✅ Done | Multiple glow effects |
| 5 | Add shimmer animation | ✅ Done | text-shimmer, skeleton-wave |

### Feature Components
| # | Task | Status | Notes |
|---|------|--------|-------|
| 1 | Create StakeCard.tsx | ⏳ Pending | Staking interface |
| 2 | Create LotteryCard.tsx | ⏳ Pending | Lottery interface |
| 3 | Update ClaimCard.tsx | ⏳ Pending | V3 integration |
| 4 | Create StatsCard.tsx | ⏳ Pending | Global stats |
| 5 | Create HistoryList.tsx | ⏳ Pending | Transaction history |

---

## 🚫 Blockers

| Blocker | Resolution |
|---------|------------|
| Contract addresses (testnet) | Deploy V3 contracts first |
| Turnstile keys | PaulySun to create account |
| wagmi provider setup | Need to test with Base |

---

## ✅ Completed

| Task | Completed |
|------|-----------|
| Design tokens | 2026-03-02 |
| Button component | 2026-02-26 |
| Card component | 2026-02-26 |
| Badge component | 2026-02-26 |
| Input component | 2026-02-26 |
| Progress component | 2026-02-26 |
| Countdown component | 2026-03-02 |
| StreakBadge component | 2026-03-02 |
| HoldingTier component | 2026-03-02 |
| Turnstile component | 2026-03-02 |
| FeeDisplay component | 2026-02-26 |
| EligibilityCheck component | 2026-02-26 |
| ClaimCard component | 2026-02-26 |
| Base chain config | 2026-03-02 |
| Supabase integration | 2026-03-02 |
| V3 API routes | 2026-03-02 |
| Frontend audit | 2026-03-02 |
| Overhaul plan doc | 2026-03-02 |
| Header component | 2026-03-02 |
| Footer component | 2026-03-02 |
| Navigation component | 2026-03-02 |
| Layout component | 2026-03-02 |
| Modal component | 2026-03-02 |
| Toast component | 2026-03-02 |
| Skeleton component | 2026-03-02 |
| EmptyState component | 2026-03-02 |
| ErrorBoundary component | 2026-03-02 |
| Web3Provider (wagmi) | 2026-03-02 |
| Home page rewrite | 2026-03-02 |
| Claim page rewrite | 2026-03-02 |
| Stake page rewrite | 2026-03-02 |
| Lottery page rewrite | 2026-03-02 |
| Profile page create | 2026-03-02 |
| Global CSS design system | 2026-03-02 |
| WalletModal component | 2026-03-02 |
| NetworkSwitcher component | 2026-03-02 |
| Premium button animations | 2026-03-02 |
| Card hover/glow effects | 2026-03-02 |
| Badge shimmer animation | 2026-03-02 |
| StatusBadge component | 2026-03-02 |
| CounterBadge component | 2026-03-02 |
| 15+ CSS animations | 2026-03-02 |
| Glass morphism utilities | 2026-03-02 |
| Glow effect utilities | 2026-03-02 |

---

*Last Updated: 2026-03-02*
