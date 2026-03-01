# Contracts TODO

> Smart contract audits, fixes, and deployment

---

## 🔥 Critical

| # | Task | Assignee | Status | Notes |
|---|------|----------|--------|-------|
| 1 | Deploy to Base testnet | Felix | ⏳ Pending | After final review |

---

## 📋 Contract Status

| Contract | Audit | Fixes | Base Deploy | Status |
|----------|-------|-------|-------------|--------|
| RareTokenV3.sol | ✅ Done | ✅ Done | ⏳ Pending | 🟢 Upgraded (0.8.20) |
| RareFountainV3.sol | ✅ Done | ✅ Done | ⏳ Pending | 🟢 Upgraded (0.8.20) |
| RareLotteryV3.sol | ✅ Done | ✅ Done | ⏳ Pending | 🟢 Upgraded (0.8.20) |
| RareStakingV3.sol | ✅ Done | ✅ Done | ⏳ Pending | 🟢 Upgraded (0.8.20) |

---

## 🟢 Completed (V3 Upgrades)

### Token Contract (RareTokenV3.sol)
- **Status:** Upgraded to 0.8.20. Fixed critical reentrancy, locked metadata, and added Merkle Airdrop for migration.

### Fountain Contract (RareFountainV3.sol)
- **Status:** Upgraded to 0.8.20. Integrated Stake-to-Claim and 24h rate limiting for bot protection. Fixed `claimBounty` reentrancy.

### Lottery Contract (RareLotteryV3.sol)
- **Status:** Full rewrite from 0.4.17 to 0.8.20. Added Native/Token entry modes, entry limits per address, and placeholder for Base Chain randomness.

### Staking Contract (RareStakingV3.sol)
- **Status:** Full rewrite to 0.8.20. Upgraded from 0.6.x to incorporate `ReentrancyGuard`, fixed state-update vulnerabilities, and replaced the manager-fee centralization with a treasury address. Maintained the original term-based bonus structure (7/28/84 days).

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
| None | All contracts ready for testnet prep |

---

*Last Updated: 2026-03-01*
