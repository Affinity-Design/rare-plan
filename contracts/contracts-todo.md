# Contracts TODO

> Smart contract audits, fixes, and deployment

---

## 🔥 Critical

| # | Task | Assignee | Status | Notes |
|---|------|----------|--------|-------|
| 1 | Audit staking contract | GLM5 | ⏳ Pending | Waiting for source code |
| 2 | Fix lottery contract | GLM5 | ⏳ Pending | Rewrite in Solidity 0.8.x |
| 3 | Fix fountain contract | GLM5 | ⏳ Pending | Add stake-to-claim |
| 4 | Fix token contract | GLM5 | ⏳ Pending | Security fixes |
| 5 | Deploy to Base testnet | PaulySun | ⏳ Pending | After fixes |

---

## 📋 Contract Status

| Contract | Audit | Fixes | Base Deploy | Status |
|----------|-------|-------|-------------|--------|
| rare-erc20.sol | ✅ Done | ⏳ Pending | ⏳ Pending | 🟡 Issues found |
| rare-fountain-v6.sol | ✅ Done | ⏳ Pending | ⏳ Pending | 🟡 Issues found |
| lottery.sol | ✅ Done | ⏳ Pending | ⏳ Pending | 🔴 Critical issues |
| staking.sol | ⏳ Pending | ⏳ Pending | ⏳ Pending | ⏳ Need source |

---

## 🟡 In Progress

### Token Contract (rare-erc20.sol)
| # | Issue | Severity | Status |
|---|-------|----------|--------|
| 1 | Reentrancy vulnerability | 🔴 Critical | ⏳ Pending |
| 2 | Metadata manipulation | 🟡 Medium | ⏳ Pending |
| 3 | Old Solidity (0.6.x) | 🟡 Medium | ⏳ Pending |
| 4 | Missing events | 🟢 Low | ⏳ Pending |

### Fountain Contract (rare-fountain-v6.sol)
| # | Issue | Severity | Status |
|---|-------|----------|--------|
| 1 | Reentrancy in claimBounty() | 🔴 Critical | ⏳ Pending |
| 2 | Reentrancy in claim() | 🔴 Critical | ⏳ Pending |
| 3 | No stake-to-claim | 🔴 Critical | ⏳ Pending |
| 4 | No rate limiting | 🟡 Medium | ⏳ Pending |
| 5 | Old Solidity (0.6.x) | 🟡 Medium | ⏳ Pending |

### Lottery Contract (lottery.sol)
| # | Issue | Severity | Status |
|---|-------|----------|--------|
| 1 | Ancient Solidity (0.4.17) | 🔴 Critical | ⏳ Pending |
| 2 | Predictable randomness | 🔴 Critical | ⏳ Pending |
| 3 | No minimum players | 🔴 Critical | ⏳ Pending |
| 4 | No bot protection | 🟡 High | ⏳ Pending |
| 5 | Needs complete rewrite | 🔴 Critical | ⏳ Pending |

---

## ⏳ Pending

### Fixes to Implement
| # | Fix | Contract | Assignee | Status |
|---|-----|----------|----------|--------|
| 1 | Upgrade to Solidity 0.8.x | All | GLM5 | ⏳ Pending |
| 2 | Add ReentrancyGuard | Fountain, Lottery | GLM5 | ⏳ Pending |
| 3 | Implement stake-to-claim | Fountain | GLM5 | ⏳ Pending |
| 4 | Add rate limiting | Fountain | GLM5 | ⏳ Pending |
| 5 | Use Chainlink VRF | Lottery | GLM5 | ⏳ Pending |
| 6 | Add minimum players | Lottery | GLM5 | ⏳ Pending |
| 7 | Add bot protection | All | GLM5 | ⏳ Pending |
| 8 | Lock metadata | Token | GLM5 | ⏳ Pending |

### Deployment
| # | Task | Assignee | Status |
|---|------|----------|--------|
| 1 | Set up Base testnet | Felix | ⏳ Pending |
| 2 | Deploy to testnet | GLM5 | ⏳ Pending |
| 3 | Test all functions | Felix | ⏳ Pending |
| 4 | Get third-party audit | PaulySun | ⏳ Pending |
| 5 | Deploy to mainnet | PaulySun | ⏳ Pending |
| 6 | Verify on Etherscan | Felix | ⏳ Pending |

---

## 🚫 Blockers

| Blocker | Resolution |
|---------|------------|
| Staking contract source missing | PaulySun to send file |
| GLM5 rate limit | Work around or wait |

---

## ✅ Completed

| Task | Completed |
|------|-----------|
| Token contract audit | 2026-02-24 |
| Fountain contract audit | 2026-02-24 |
| Lottery contract audit | 2026-02-24 |
| Bot-proofing strategy | 2026-02-24 |

---

*Last Updated: 2026-02-24*
