# Rare Fountain V3

> The Distribution Hub for Rare Coin with advanced Proof of Humanity and Bot Protection.

## 📝 Features & 3-Tier Proof of Humanity

The Fountain has been rewritten from **Solidity 0.6.x to 0.8.20** with a focus on security and fair distribution. It introduces a **3-Tier Whitelist** to ensure distribution only reaches real humans.

### 🛡️ Whitelist Methods (3 Paths to Eligibility)
To register for a distribution pool, a user must satisfy **at least one** of these conditions:

1.  **Tier 1: Manual Admin Authorization**
    - The manager can manually whitelist specific addresses (useful for community partners, manually verified users, or developers).
    - Function: `setManualWhitelist(address _user, bool _status)`

2.  **Tier 2: RARE Token Holding (Dynamic Threshold)**
    - Users can automatically gain access by holding a minimum threshold of RARE tokens.
    - **Dynamic Pricing:** The manager can update this threshold at any time based on the price of RARE (e.g., initially 1,000 RARE, then dropping to 100 or 10 as value increases).
    - Function: `setRareThreshold(uint256 _amount)`

3.  **Tier 3: Base Username (Basenames)**
    - Automatic eligibility for users who own a verified **Basename** (Base ENS subname).
    - This provides a decentralized proof-of-humanity layer integrated directly with the Base ecosystem.
    - Contract check: `basenameRegistry.balanceOf(_user) > 0`

### 🔄 Dual-Pool Distribution System
- **Alternating Pools:** Registration and claiming happen in alternating 24-hour cycles (Pool A and Pool B).
- **Prevents Front-Running:** Users register in the *current* cycle and claim in the *next* cycle, ensuring they cannot instantly drain the pool.
- **Fair Division:** The `poolBalance` is split equally among all registered users for that cycle.

### 🔒 Security Enhancements
- **24h Rate Limiting:** Each address is limited to one registration every 24 hours.
- **Reentrancy Protection:** All `claim` and `register` functions are guarded by OpenZeppelin's `nonReentrant` modifier.
- **Pausable:** The manager can halt registrations and claims in case of emergency.

## 🛡️ Audit Verification
The contract resolves all critical reentrancy and bot-proofing issues identified in `rare-fountain-audit-new.md`.
