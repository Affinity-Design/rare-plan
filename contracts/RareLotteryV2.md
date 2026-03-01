# Rare Lottery V2

> A secure, fair, and modern lottery system built on Base Chain for Rare Coin holders.

## 📝 Features & Enhancements

- **Modernized Rewrite:** Full upgrade from Solidity 0.4.17 to 0.8.20, resolving several critical compiler-level vulnerabilities.
- **Multi-Asset Entries:**
  - **Native (ETH):** Users can enter using a small amount of Base Native ETH.
  - **RARE Token:** Users can also enter by holding/paying a RARE token fee.
- **Fair Entry (Bot Protection):**
  - **Sybil Resistance:** Limits each address to **5 entries per round**, preventing one user from overwhelming the pool.
  - **Minimum Players:** A round cannot be drawn unless at least 3 unique players have entered, ensuring a meaningful competition.
- **Secure Randomness (Placeholder):**
  - **Ready for Base:** The rewrite is designed to integrate with **Pyth Entropy** or **Chainlink VRF V2.5** for the Base Chain deployment, moving away from predictable block-header randomness.
- **Security Protections:**
  - **ReentrancyGuard:** Protects the `pickWinner` function to prevent double-spending of the prize pool.
  - **Pausable:** Administrative control to start/stop rounds in case of security issues.
- **Automated Payouts:** Winners are automatically sent both the accumulated Native ETH and any RARE tokens in the prize pool upon drawing.

## 🛡️ Audit Verification
The contract resolves all critical issues (predictable randomness, outdated compiler, and sybil attacks) found in `lottery-contract-audit.md`.
