# Rare Claims Frontend TODO

> Actionable task list for frontend overhaul

---

## 🔥 Critical (Do First)

### Layout Components
| # | Task | Status | Notes |
|---|------|--------|-------|
| 1 | Create Header.tsx | ⏳ Pending | Logo + Nav + Wallet |
| 2 | Create Footer.tsx | ⏳ Pending | Links + Social |
| 3 | Create Navigation.tsx | ⏳ Pending | Claim/Stake/Lottery links |
| 4 | Create Layout.tsx | ⏳ Pending | Wrap all pages |
| 5 | Create MobileNav.tsx | ⏳ Pending | Hamburger menu |

### Missing UI Components
| # | Task | Status | Notes |
|---|------|--------|-------|
| 1 | Create Modal.tsx | ⏳ Pending | Reusable dialog |
| 2 | Create Toast.tsx | ⏳ Pending | Notifications |
| 3 | Create Skeleton.tsx | ⏳ Pending | Loading states |
| 4 | Create EmptyState.tsx | ⏳ Pending | No data display |
| 5 | Create ErrorBoundary.tsx | ⏳ Pending | Error handling |

### Web3 Integration
| # | Task | Status | Notes |
|---|------|--------|-------|
| 1 | Create Web3Provider.tsx | ⏳ Pending | wagmi config wrapper |
| 2 | Update WalletConnect.tsx | ⏳ Pending | Use wagmi hooks |
| 3 | Create WalletModal.tsx | ⏳ Pending | Connection UI |
| 4 | Create NetworkSwitcher.tsx | ⏳ Pending | Base testnet/mainnet |

---

## 🟡 In Progress

### Page Rewrites
| # | Task | Status | Notes |
|---|------|--------|-------|
| 1 | Rewrite index.tsx (Home) | ⏳ Pending | Hero + Stats + CTA |
| 2 | Rewrite register.js → claim.tsx | ⏳ Pending | Main claim flow |
| 3 | Rewrite stake.js | ⏳ Pending | Staking interface |
| 4 | Rewrite lotto.js → lottery.tsx | ⏳ Pending | Lottery interface |
| 5 | Create profile.tsx | ⏳ Pending | User dashboard |

### Component Polish
| # | Task | Status | Notes |
|---|------|--------|-------|
| 1 | Button - Add loading spinner | ⏳ Pending |
| 2 | Button - Add glow effect | ⏳ Pending |
| 3 | Badge - Add shimmer animation | ⏳ Pending |
| 4 | Card - Add hover animations | ⏳ Pending |
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
| 1 | Add gradientFlow keyframes | ⏳ Pending |
| 2 | Add floatY animation | ⏳ Pending |
| 3 | Add glowPulse animation | ⏳ Pending |
| 4 | Add coinGlow animation | ⏳ Pending |
| 5 | Add shimmer animation | ⏳ Pending |

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

---

*Last Updated: 2026-03-02*
