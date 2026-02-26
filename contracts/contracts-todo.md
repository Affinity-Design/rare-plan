# Contracts TODO

> Smart contract audits, fixes, and deployment

---

## 🔥 Critical

| # | Task | Assignee | Status | Notes |
|---|------|----------|--------|-------|
| 1 | Audit staking contract | Felix | ⏳ Pending | Waiting for source code |
| 2 | Deploy to Base testnet | PaulySun | ⏳ Pending | After final review |

---

## 📋 Contract Status

| Contract | Audit | Fixes | Base Deploy | Status |
|----------|-------|-------|-------------|--------|
| RareTokenV2.sol | ✅ Done | ✅ Done | ⏳ Pending | 🟢 Upgraded (0.8.20) |
| RareFountainV2.sol | ✅ Done | ✅ Done | ⏳ Pending | 🟢 Upgraded (0.8.20) |
| RareLotteryV2.sol | ✅ Done | ✅ Done | ⏳ Pending | 🟢 Upgraded (0.8.20) |
| staking.sol | ⏳ Pending | ⏳ Pending | ⏳ Pending | ⏳ Need source |

---

## 🟢 Completed (V2 Upgrades)

### Token Contract (RareTokenV2.sol)
- **Status:** Upgraded to 0.8.20. Fixed critical reentrancy, locked metadata, and added Merkle Airdrop for migration.

### Fountain Contract (RareFountainV2.sol)
- **Status:** Upgraded to 0.8.20. Integrated Stake-to-Claim and 24h rate limiting for bot protection. Fixed `claimBounty` reentrancy.

### Lottery Contract (RareLotteryV2.sol)
- **Status:** Full rewrite from 0.4.17 to 0.8.20. Added Native/Token entry modes, entry limits per address, and placeholder for Base Chain randomness.

---

## ⏳ Pending Deployment

| # | Task | Assignee | Status |
|---|------|----------|--------|
| 1 | Set up Base testnet (Sepolia) | Felix | ⏳ Pending |
| 2 | Deploy to testnet | Felix | ⏳ Pending |
| 3 | Test all flows (Claim -> Stake -> Lotto) | Felix | ⏳ Pending |
| 4 | Get third-party audit | PaulySun | ⏳ Pending |
| 5 | Deploy to mainnet | PaulySun | ⏳ Pending |

---

## 🚫 Blockers

| Blocker | Resolution |
|---------|------------|
| Staking contract source missing | PaulySun to send file |

---

*Last Updated: 2026-02-26*
