# Rare Token V2 (RARE)

> Modern ERC20 Token for the Rare Coin Ecosystem on Base Chain.

## 📝 Features & Enhancements

- **Solidity 0.8.20:** Upgraded from the legacy 0.6.x version to incorporate built-in overflow/underflow protection and modern security standards.
- **Fixed Supply:** Total supply is hardcapped at **3,650,000 RARE**, ensuring scarcity.
- **Migration Engine:** Integrated **Merkle Proof Airdrop** mechanism allowing legacy holders from PulseChain to claim their 100:1 migrated tokens securely on Base.
- **Security Fixes:**
  - **Reentrancy Protection:** Fixed critical vulnerabilities identified in the previous version.
  - **Locked Metadata:** Metadata (Name/Symbol) is fixed at deployment to prevent manipulation.
  - **Ownable:** Protected by OpenZeppelin's access control for administrative functions (like setting the Merkle Root).
- **Events:** Added `AirdropClaimed` and `MerkleRootUpdated` for better off-chain tracking and UI integration.

## 🛡️ Audit Verification
The contract resolves all issues identified in the `rare-erc20-audit-new.md` report.
