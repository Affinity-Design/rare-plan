# Rare Claims Frontend Overhaul Plan

> Complete audit and redesign plan for rarify-claim dApp following Rare Coin Design System v1.0

---

## 📊 Current State Audit

### Existing Components (`src/components/`)

| Component | File | Status | Issues |
|-----------|------|--------|--------|
| **Core UI** |||
| Button | `ui/Button.tsx` | 🟡 Partial | Missing loading spinner, icon positioning |
| Card | `ui/Card.tsx` | ✅ Good | Follows design system |
| Badge | `ui/Badge.tsx` | 🟡 Partial | Missing gradient variants, inconsistent sizing |
| Input | `ui/Input.tsx` | ✅ Good | Has address/amount variants |
| Progress | `ui/Progress.tsx` | ✅ Good | Has circular + streak variants |
| **New Components (2026-03-02)** |||
| Countdown | `ui/Countdown.tsx` | ✅ Good | Has ring variant |
| StreakBadge | `ui/StreakBadge.tsx` | ✅ Good | Follows tier system |
| HoldingTier | `ui/HoldingTier.tsx` | ✅ Good | Follows tier system |
| Turnstile | `ui/Turnstile.tsx` | ✅ Good | Widget + status |
| FeeDisplay | `ui/FeeDisplay.tsx` | ✅ Good | Chainlink integration |
| EligibilityCheck | `ui/EligibilityCheck.tsx` | ✅ Good | 3-tier whitelist |
| **Feature Components** |||
| ClaimCard | `ClaimCard.tsx` | 🟡 Partial | Needs V3 contract integration |
| WalletConnect | `WalletConnect.tsx` | 🟡 Partial | Basic MetaMask only, needs wagmi |
| Logo | `Logo.tsx` | ⚠️ Audit | Check against brand system |
| Toast | `Toast.tsx` | ⚠️ Audit | Needs redesign |

### Existing Pages (`pages/`)

| Page | File | Status | Issues |
|------|------|--------|--------|
| Home | `index.js` | 🔴 Legacy | Uses old web3-react, needs rewrite |
| Register | `register.js` | 🔴 Legacy | Uses FaunaDB, old contracts, needs rewrite |
| Stake | `stake.js` | 🔴 Legacy | Gnosis chain only |
| Lotto | `lotto.js` | 🔴 Legacy | Gnosis chain only |
| Swap | `swap.js` | 🔴 Legacy | Gnosis chain only |
| Test | `test.js` | 🟡 Testing | Keep for dev |

### Design Tokens (`src/styles/tokens.ts`)

| Category | Status | Notes |
|----------|--------|-------|
| Colors | ✅ Complete | Matches design system |
| Gradients | ✅ Complete | Iridescent defined |
| Typography | ✅ Complete | Font families defined |
| Spacing | ✅ Complete | 4px base unit |
| Border Radius | ✅ Complete | All variants |
| Shadows | ✅ Complete | Includes glow effects |
| Animation | ✅ Complete | Timing + easing |
| Breakpoints | ✅ Complete | Responsive |

### CSS/Styling

| File | Status | Issues |
|------|--------|--------|
| `globals.css` | ⚠️ Audit | Check for Tailwind config alignment |
| `tokens.ts` | ✅ Good | Matches design system |
| Tailwind Config | ⚠️ Missing | Need to verify custom config |

---

## 🚨 Critical Issues

### 1. Legacy Web3 Integration
- **Problem:** Pages use old `@web3-react/core` with Gnosis chain hardcoded
- **Impact:** Cannot connect to Base, wrong contract addresses
- **Fix:** Migrate to wagmi + viem (already configured in `src/config`)

### 2. FaunaDB Dependencies
- **Problem:** Pages reference FaunaDB which is sunset
- **Impact:** API calls fail, no data persistence
- **Fix:** Replace with Supabase hooks (already created in `src/hooks/useSupabase.ts`)

### 3. Old Component Imports
- **Problem:** Pages import from `antd` (Ant Design) and old component paths
- **Impact:** Inconsistent styling, large bundle size
- **Fix:** Replace with new UI components

### 4. Missing Layout Components
- **Problem:** No Header, Footer, Navigation components
- **Impact:** No consistent page structure
- **Fix:** Create layout components

---

## 📋 Overhaul Plan

### Phase 1: Core Infrastructure (Week 1)

#### 1.1 Web3 Migration
| # | Task | Priority | Status |
|---|------|----------|--------|
| 1 | Install wagmi + viem | HIGH | ✅ Done |
| 2 | Create wagmi config for Base | HIGH | ✅ Done |
| 3 | Create Web3Provider wrapper | HIGH | ⏳ Pending |
| 4 | Migrate WalletConnect to wagmi hooks | HIGH | ⏳ Pending |
| 5 | Add network switcher UI | MEDIUM | ⏳ Pending |
| 6 | Add wallet modal (RainbowKit or custom) | MEDIUM | ⏳ Pending |

#### 1.2 Layout Components
| # | Task | Priority | Status |
|---|------|----------|--------|
| 1 | Create Header component | HIGH | ⏳ Pending |
| 2 | Create Footer component | MEDIUM | ⏳ Pending |
| 3 | Create Navigation component | HIGH | ⏳ Pending |
| 4 | Create Layout wrapper | HIGH | ⏳ Pending |
| 5 | Create MobileNav component | MEDIUM | ⏳ Pending |

#### 1.3 Supabase Integration
| # | Task | Priority | Status |
|---|------|----------|--------|
| 1 | Replace FaunaDB calls with Supabase | HIGH | ⏳ Pending |
| 2 | Connect pages to React hooks | HIGH | ⏳ Pending |
| 3 | Add real-time subscriptions | MEDIUM | ⏳ Pending |

---

### Phase 2: Page Rewrites (Week 2)

#### 2.1 Home Page (`pages/index.tsx`)
```
Target: Modern landing with stats + CTA

Components:
- Hero section with animated logo
- Global stats cards (users, claims, staked)
- How it works section
- CTA to claim page

Data sources:
- GET /api/v3/stats/global
- GET /api/v3/fountain/status
- GET /api/v3/supply
```

#### 2.2 Claim Page (`pages/claim.tsx`)
```
Target: Main claiming interface

Components:
- WalletConnect (if not connected)
- EligibilityCheck
- StreakBadge + StreakProgress
- HoldingTier + HoldingProgress
- FeeDisplay (Chainlink price)
- Turnstile widget
- ClaimCard with action button
- Claim history list

Data sources:
- useUser(walletAddress)
- useClaimHistory(userId)
- GET /api/v3/user/[address]/eligibility
- GET /api/v3/user/[address]/streak
- GET /api/v3/user/[address]/tier
- GET /api/v3/fee/claim
- POST /api/v3/claims/log
```

#### 2.3 Stake Page (`pages/stake.tsx`)
```
Target: Staking interface with term selection

Components:
- WalletConnect
- StakeBalance card
- TermSelector (7d/28d/84d)
- FeeDisplay
- StakingRewards calculator
- Active stakes list
- Staking history

Data sources:
- useStakes(userId)
- GET /api/v3/staking/tvl
- POST /api/v3/stakes/log
```

#### 2.4 Lottery Page (`pages/lottery.tsx`)
```
Target: Lottery entry and history

Components:
- WalletConnect
- CurrentLottery card
- PrizePool display
- EntryCounter (max 5)
- Countdown to draw
- Previous winners list
- User entries history

Data sources:
- GET /api/v3/lottery/status
- useLotteryEntries(userId)
- useLotterySubscription(lotteryId)
- POST /api/v3/lottery/enter
```

#### 2.5 Profile Page (`pages/profile.tsx`) - NEW
```
Target: User dashboard

Components:
- WalletConnect
- UserStats card
- Claim history
- Stakes list
- Lottery entries
- Transaction history

Data sources:
- useUser(walletAddress)
- useClaimHistory(userId)
- useStakes(userId)
- useLotteryEntries(userId)
```

---

### Phase 3: Component Polish (Week 3)

#### 3.1 Missing Components
| Component | Description | Priority |
|-----------|-------------|----------|
| `Modal` | Reusable modal dialog | HIGH |
| `Toast` | Notification system | HIGH |
| `Skeleton` | Loading placeholder | HIGH |
| `EmptyState` | Empty data display | MEDIUM |
| `ErrorBoundary` | Error handling UI | MEDIUM |
| `Tooltip` | Hover information | MEDIUM |
| `Dropdown` | Selection dropdown | MEDIUM |
| `Tabs` | Content tabs | LOW |
| `Accordion` | Collapsible content | LOW |

#### 3.2 Component Improvements
| Component | Improvements |
|-----------|--------------|
| `Button` | Add loading spinner, improve icon handling, add glow effect |
| `Badge` | Add shimmer animation, improve gradient variants |
| `Card` | Add hover animations, improve glass effect |
| `Input` | Add validation states, improve focus ring |
| `Progress` | Add animated fill, improve streak variant |

#### 3.3 Animation Enhancements
| Animation | Component | Type |
|-----------|-----------|------|
| `gradientFlow` | Buttons, badges | Background |
| `floatY` | Hero elements | Transform |
| `glowPulse` | Status indicators | Box shadow |
| `coinGlow` | Logo, tokens | Box shadow |
| `shimmer` | Loading skeletons | Background |
| `pulseDot` | Live indicators | Transform + opacity |
| `slideIn` | Modals, toasts | Transform |
| `fadeIn` | Page transitions | Opacity |

---

### Phase 4: Integration & Testing (Week 4)

#### 4.1 Contract Integration
| # | Task | Status |
|---|------|--------|
| 1 | Import V3 contract ABIs | ⏳ Pending (need addresses) |
| 2 | Create contract read hooks | ⏳ Pending |
| 3 | Create contract write hooks | ⏳ Pending |
| 4 | Add transaction status tracking | ⏳ Pending |
| 5 | Add transaction toast notifications | ⏳ Pending |

#### 4.2 Error Handling
| # | Task | Status |
|---|------|--------|
| 1 | Create ErrorBoundary component | ⏳ Pending |
| 2 | Add global error handler | ⏳ Pending |
| 3 | Create error toast system | ⏳ Pending |
| 4 | Add retry mechanisms | ⏳ Pending |

#### 4.3 Testing Checklist
| Page | Test Cases |
|------|------------|
| Home | Stats load, CTAs work, responsive |
| Claim | Wallet connect, eligibility check, claim flow |
| Stake | Term selection, stake flow, unstake flow |
| Lottery | Entry limits, countdown, winner display |
| Profile | Data loads, history displays, responsive |

---

## 📁 Target File Structure

```
/src
├── components/
│   ├── ui/                      # Base UI components
│   │   ├── Button.tsx           ✅ Exists - needs polish
│   │   ├── Card.tsx             ✅ Exists - good
│   │   ├── Badge.tsx            ✅ Exists - needs polish
│   │   ├── Input.tsx            ✅ Exists - good
│   │   ├── Progress.tsx         ✅ Exists - good
│   │   ├── Countdown.tsx        ✅ Exists - good
│   │   ├── StreakBadge.tsx      ✅ Exists - good
│   │   ├── HoldingTier.tsx      ✅ Exists - good
│   │   ├── Turnstile.tsx        ✅ Exists - good
│   │   ├── FeeDisplay.tsx       ✅ Exists - good
│   │   ├── EligibilityCheck.tsx ✅ Exists - good
│   │   ├── Modal.tsx            ⏳ Create
│   │   ├── Toast.tsx            ⏳ Create
│   │   ├── Skeleton.tsx         ⏳ Create
│   │   ├── EmptyState.tsx       ⏳ Create
│   │   ├── ErrorBoundary.tsx    ⏳ Create
│   │   ├── Tooltip.tsx          ⏳ Create
│   │   └── index.ts
│   ├── layout/                  # Layout components
│   │   ├── Header.tsx           ⏳ Create
│   │   ├── Footer.tsx           ⏳ Create
│   │   ├── Navigation.tsx       ⏳ Create
│   │   ├── MobileNav.tsx        ⏳ Create
│   │   └── Layout.tsx           ⏳ Create
│   ├── features/                # Feature components
│   │   ├── ClaimCard.tsx        ✅ Exists - needs V3 integration
│   │   ├── StakeCard.tsx        ⏳ Create
│   │   ├── LotteryCard.tsx      ⏳ Create
│   │   ├── WalletModal.tsx      ⏳ Create
│   │   └── NetworkSwitcher.tsx  ⏳ Create
│   ├── Logo.tsx                 ✅ Exists - audit
│   └── index.ts
├── pages/
│   ├── _app.tsx                 ⏳ Update with providers
│   ├── index.tsx                ⏳ Rewrite
│   ├── claim.tsx                ⏳ Rewrite (was register.js)
│   ├── stake.tsx                ⏳ Rewrite
│   ├── lottery.tsx              ⏳ Rewrite (was lotto.js)
│   ├── profile.tsx              ⏳ Create new
│   └── api/                     ✅ V3 APIs exist
├── hooks/
│   ├── useSupabase.ts           ✅ Exists
│   ├── useWallet.ts             ⏳ Create
│   ├── useContracts.ts          ⏳ Create
│   └── useTransaction.ts        ✅ Exists - may need update
├── lib/
│   ├── supabase/                ✅ Exists
│   ├── base-client.ts           ✅ Exists
│   ├── chainlink.ts             ✅ Exists
│   ├── error-tracking.ts        ✅ Exists
│   └── i18n.ts                  ✅ Exists
├── styles/
│   ├── globals.css              ⚠️ Audit
│   └── tokens.ts                ✅ Good
└── config/
    └── index.ts                 ✅ Good
```

---

## 🎨 Design System Compliance

### Colors - ✅ Compliant
All components use design tokens from `tokens.ts`

### Typography - ⚠️ Needs Audit
- Verify font loading in `_app.tsx`
- Check consistent usage of font weights
- Ensure responsive font sizes

### Spacing - ✅ Compliant
Using Tailwind spacing which aligns with 4px base unit

### Components - 🟡 Partial
- Core components follow design system
- Legacy pages use Ant Design (needs removal)
- Missing layout components

### Animations - ⚠️ Needs Enhancement
- Basic transitions exist
- Need to add keyframe animations from design system
- Add motion library (Framer Motion recommended)

---

## 🚀 Priority Order

### Immediate (This Session)
1. Create Layout components (Header, Footer, Navigation)
2. Create Modal component
3. Create Toast component
4. Create Skeleton component

### High Priority (Next Session)
1. Rewrite Home page
2. Rewrite Claim page
3. Migrate WalletConnect to wagmi

### Medium Priority
1. Rewrite Stake page
2. Rewrite Lottery page
3. Create Profile page

### Low Priority
1. Polish animations
2. Add tooltips
3. Add tabs/accordion

---

## 📊 Progress Tracking

### Component Audit
- [x] Audit existing UI components
- [x] Identify missing components
- [x] Check design token alignment
- [ ] Audit page dependencies
- [ ] Identify Ant Design usages

### Infrastructure
- [x] Supabase client
- [x] Supabase hooks
- [x] Base chain client
- [x] API routes
- [ ] Web3Provider wrapper
- [ ] Layout components

### Pages
- [ ] Home rewrite
- [ ] Claim rewrite
- [ ] Stake rewrite
- [ ] Lottery rewrite
- [ ] Profile create

---

*Frontend Overhaul Plan v1.0*
*Created: 2026-03-02*
*Author: Felix - Director*
