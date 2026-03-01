# Rare Staking V2

> Time-weighted LP Token Staking with RARE dividends and time-locked multipliers.

## 📝 Features & Enhancements

- **Modernized Rewrite:** Full upgrade from Solidity 0.6.x to 0.8.20, resolving the original compiler-level vulnerabilities.
- **LP Token Staking:** Allows users to stake their **RARE/ETH LP tokens** from Uniswap/Aerodrome to earn a share of the daily RARE dividends.
- **Time-Locked Multipliers (3 Terms):**
  - **7 Days:** 1x Multiplier (Base reward).
  - **28 Days:** 2x Multiplier (Double rewards).
  - **84 Days:** 3x Multiplier (Triple rewards).
- **Weekly Claim Cycle:** Users can claim their RARE dividends every **7 days**, encouraging long-term holding and consistent interaction.
- **Security Protections:**
  - **ReentrancyGuard:** Integrated into `stake`, `claimReward`, and `unstake` functions.
  - **State-Before-Transfer:** Fixed critical issues where external transfers happened before state updates.
- **Treasury System (Decentralization):**
  - **Configurable Treasury:** Removed hardcoded manager addresses. All entry fees now flow into a configurable **Treasury** address for ecosystem growth.
  - **Ownable:** Standard access control for updating fees or treasury addresses.
- **Pausable:** Admin control to halt staking or claims if a bug is discovered.

## 🛡️ Audit Verification
The contract resolves all critical issues (reentrancy and manager-fee centralization) identified in the `rare-staking-full-audit.md` report.
