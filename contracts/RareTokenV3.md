# Rare Token V3 (RARE)

> The native token of the Rare Coin ecosystem on Base Chain

---

## 📊 Token Overview

| Property | Value |
|----------|-------|
| **Name** | Rare Coin |
| **Symbol** | RARE |
| **Decimals** | 18 |
| **Total Supply** | 3,650,000 RARE (Fixed) |
| **Network** | Base Chain |
| **Standard** | ERC-20 (OpenZeppelin) |

---

## 🎯 Purpose

RARE is the utility and governance token for the Rare Coin ecosystem:

- **Claims** - Daily distribution via Fountain
- **Staking** - LP staking rewards
- **Lottery** - Entry for jackpots
- **Perks** - Holding bonuses at every tier
- **Governance** - Future DAO voting

---

## 🔄 Migration from Gnosis (V2)

### How It Works

1. **Snapshot Taken** - All Gnosis holders, LP providers, and stakers recorded
2. **Merkle Tree Generated** - Combined balances compiled
3. **Claim on Base** - Users visit `rare.claims` and claim V3 tokens

### Claim Process

```solidity
function claimAirdrop(uint256 _amount, bytes32[] calldata _proof) external {
    require(!hasClaimed[msg.sender], "Already claimed");
    require(_verifyProof(_proof, msg.sender, _amount), "Invalid proof");
    
    hasClaimed[msg.sender] = true;
    _transfer(owner(), msg.sender, _amount);
}
```

---

## 🔒 Security Features

| Feature | Status |
|---------|--------|
| Solidity 0.8.20 | ✅ |
| OpenZeppelin ERC20 | ✅ |
| Reentrancy Protection | ✅ |
| Fixed Supply | ✅ |
| Locked Metadata | ✅ |
| Merkle Airdrop | ✅ |

---

## 📋 Contract Functions

### User Functions

| Function | Description |
|----------|-------------|
| `claimAirdrop(amount, proof)` | Claim migrated tokens |
| `unclaimedBalance()` | View remaining airdrop tokens |

### Admin Functions

| Function | Description |
|----------|-------------|
| `setMerkleRoot(root)` | Set airdrop merkle root |

---

## 🔗 Links

- **Contract:** `RareTokenV3.sol`
- **Deployment:** Pending (Base Mainnet)
- **Explorer:** TBD

---

*Version: V3 (Base Chain)*
