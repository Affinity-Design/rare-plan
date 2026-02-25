# Project Map - Rare Coin Ecosystem

## Overview

Rare Coin is a fair-distribution cryptocurrency project on Base Chain with multiple connected repositories and systems.

---

## 🗺️ Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     RARE COIN ECOSYSTEM                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌──────────────┐     ┌──────────────┐     ┌──────────────┐   │
│   │   rare.fyi   │     │ rare.claims  │     │   Contracts  │   │
│   │  (Marketing) │────▶│    (dApp)    │────▶│  (Base Chain)│   │
│   └──────────────┘     └──────────────┘     └──────────────┘   │
│          │                    │                    │            │
│          │                    │                    │            │
│          ▼                    ▼                    ▼            │
│   ┌──────────────┐     ┌──────────────┐     ┌──────────────┐   │
│   │   Twitter    │     │   Supabase   │     │  rare-coin   │   │
│   │  Telegram    │     │  (Database)  │     │  (ERC20)     │   │
│   └──────────────┘     └──────────────┘     └──────────────┘   │
│                                                  │              │
│                                                  ▼              │
│                                          ┌──────────────┐       │
│                                          │ rare-fountain│       │
│                                          │ (Distribution)│      │
│                                          └──────────────┘       │
│                                                  │              │
│                                                  ▼              │
│                                          ┌──────────────┐       │
│                                          │   Staking    │       │
│                                          │   Lottery    │       │
│                                          └──────────────┘       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📦 Repository Details

### 1. rare-fyi (Marketing Website)
- **URL:** https://github.com/Affinity-Design/rare-fyi
- **Live:** https://rare-fyi.vercel.app
- **Domain:** rare.fyi
- **Purpose:** SEO, blog, marketing, community info
- **Tech:** Next.js 14, Tailwind CSS, Framer Motion
- **Status:** 🟡 In Development

### 2. rare-coin (dApp)
- **URL:** https://github.com/Affinity-Design/rare-coin
- **Domain:** rare.claims
- **Purpose:** Claiming, staking, lottery, swap
- **Tech:** Next.js 14, wagmi, viem, Supabase
- **Status:** 🟡 In Development

### 3. rare-coin-projects (Contracts)
- **URL:** https://github.com/Affinity-Design/rare-coin
- **Contracts:**
  - `rare-erc20.sol` - Token contract
  - `rare-fountain-v6.sol` - Distribution contract
  - `lottery.sol` - Lottery contract (needs audit)
  - `staking.sol` - Staking contract (needs audit)
- **Chain:** Migrating from PulseChain → Base Chain
- **Status:** 🔴 Needs Security Audit

### 4. rare-plan (This Repo)
- **URL:** https://github.com/Affinity-Design/rare-plan
- **Purpose:** Central planning hub
- **Contents:** Marketing plans, technical docs, roadmaps
- **Status:** 🟢 Active

---

## 🔄 Data Flow

```
User Flow:
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ Twitter │───▶│rare.fyi │───▶│rare.    │───▶│ Base    │
│Telegram │    │(Info)   │    │claims   │    │ Chain   │
└─────────┘    └─────────┘    └─────────┘    └─────────┘
                                   │
                                   ▼
                              ┌─────────┐
                              │Supabase │
                              │(Data)   │
                              └─────────┘
```

---

## 🔐 Security Layers

```
┌─────────────────────────────────────────┐
│           USER REGISTRATION              │
├─────────────────────────────────────────┤
│  1. Cloudflare Turnstile (CAPTCHA)      │
│  2. Stake-to-Claim (Economic Barrier)   │
│  3. 24h Rate Limiting                    │
│  4. Wallet Signature Verification       │
└─────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│           CLAIM EXECUTION                │
├─────────────────────────────────────────┤
│  1. Reentrancy Guard                     │
│  2. Dual Pool System                     │
│  3. On-chain Verification                │
│  4. Stake Return Logic                   │
└─────────────────────────────────────────┘
```

---

## 📊 Tokenomics

| Parameter | Value |
|-----------|-------|
| **Total Supply** | 3,650,000 RARE |
| **Chain** | Base Chain |
| **Distribution** | 200 tokens/day (dual pool) |
| **Distribution Period** | end 2071 |
| **Bot Protection** | Stake-to-Claim |

---

## 🗓️ Timeline

| Date | Milestone |
|------|-----------|
| 2026-02-24 | Project restart, planning begins |
| 2026-02-25 | Website redesign complete |
| 2026-03-01 | Contract audits complete |
| 2026-03-15 | dApp development complete |
| 2026-04-01 | Testnet deployment |
| 2026-04-15 | Mainnet launch |
| 2026-07-15 | 90-day marketing complete |

---

## 📝 Notes

- All repos use the same GitHub token for access
- Vercel handles deployment for frontend repos
- Supabase handles all backend data
- Base Chain for all smart contracts

---

*Last Updated: 2026-02-25*
