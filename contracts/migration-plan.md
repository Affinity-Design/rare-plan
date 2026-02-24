# Rare Coin Migration Plan

## Overview

Migrating from old Rare Coin contracts (PulseChain) to new contracts (Base Chain) while preserving existing user balances.

---

## 📊 Tokenomics Update

### Supply Comparison

| Version | Supply | Chain |
|---------|--------|-------|
| **Old (v1)** | 36,500 RARE | PulseChain/Gnosis |
| **New (v2)** | 3,650,000 RARE | Base Chain |
| **Ratio** | 1:100 | - |

### Why 3,650,000?

- 100x the original supply
- Allows 1:100 conversion ratio for old holders
- Still relatively rare (vs billions in other projects)
- Maintains scarcity while accommodating growth

---

## 🔄 Migration Strategy

### Phase 1: Snapshot

**When:** To be announced publicly (give accumulation time)
**What:** Snapshot all RARE balances on old chain
**How:**
```solidity
// Snapshot at specific block
mapping(address => uint256) public oldBalances;

function snapshot() external onlyOwner {
    // For each address in old contract
    // Record balance at snapshot block
}
```

### Phase 2: Airdrop Calculation

**Conversion Ratio:** 1 old RARE = 100 new RARE

| Old Balance | New Balance |
|-------------|-------------|
| 1 RARE | 100 RARE |
| 10 RARE | 1,000 RARE |
| 100 RARE | 10,000 RARE |
| 365 RARE | 36,500 RARE |

**Why 100x?**
- Original supply: 36,500
- New supply: 3,650,000
- 3,650,000 / 36,500 = 100x ratio
- Preserves percentage ownership

### Phase 3: Airdrop Execution

**Method 1: Merkle Drop (Recommended)**
```solidity
function claimAirdrop(
    uint256 amount,
    bytes32[] calldata proof
) external {
    require(verifyProof(proof, msg.sender, amount), "Invalid proof");
    require(!claimed[msg.sender], "Already claimed");
    
    claimed[msg.sender] = true;
    _mint(msg.sender, amount);
}
```

**Benefits:**
- Gas efficient
- Users claim when they want
- No need to send to thousands of addresses

**Method 2: Direct Airdrop**
- Send tokens directly to all holders
- More expensive
- Immediate distribution

### Phase 4: Old Contract Wind-Down

**Options:**
1. **Stop distributing** - Pause old contract
2. **Continue distributing** - Let it run until empty
3. **Burn remaining** - Reduce old supply

**Recommendation:** Continue old distribution until migration cutoff, then pause.

---

## 📅 Timeline

| Phase | Duration | Action |
|-------|----------|--------|
| **1** | 2 weeks | Public announcement |
| **2** | 1 week | Accumulation window |
| **3** | 1 day | Snapshot taken |
| **4** | 1 week | Deploy new contracts |
| **5** | 1 week | Airdrop claims open |
| **6** | Ongoing | New distribution begins |

---

## 📢 Public Announcement

### What to Communicate

**The Message:**
> "Rare Coin is migrating to Base Chain with 100x more tokens. All existing holders will receive an airdrop equal to 100x their current balance. Snapshot date: [DATE]. Claim your tokens at rare.claims after migration."

**Key Points:**
1. 1 old RARE = 100 new RARE
2. Snapshot at specific block
3. Claim on new chain (Base)
4. Old contract continues until [DATE]
5. After cutoff, no more old claims

### Channels

- Twitter (@RarifyApps)
- Telegram (t.me/rarify_community)
- Blog post on rare.fyi
- Direct message to known holders

---

## 🔍 Finding Old Holders

### On-Chain Analysis

**Data Needed:**
1. All addresses that ever claimed RARE
2. Current balance of each address
3. Total claimed vs total remaining

**How to Get:**
```bash
# Query old contract events
# Get all Transfer events from old contract
# Filter out zero addresses
# Sum balances per address
```

**Tools:**
- The Graph (if indexed)
- Dune Analytics
- Covalent API
- Direct blockchain scan

### Estimated Holders

Based on 3 years of distribution:
- Daily claims: ~3 years × 365 days = ~1,095 distributions
- Assuming average 10-50 claimers per day
- Estimated: 10,000 - 50,000 unique holders
- Many may be bots (original problem)

---

## 💰 Supply Allocation

### New Supply: 3,650,000 RARE

| Allocation | Amount | Percentage |
|------------|--------|------------|
| **Airdrop** | ~3,650,000* | 100%* |
| Team | 0 | 0% |
| Treasury | 0 | 0% |
| Liquidity | 0 | 0% |

*Depends on how much has been distributed on old chain

### If Old Chain Has Distributed 50%

| Allocation | Amount | Percentage |
|------------|--------|------------|
| **Airdrop** | 1,825,000 | 50% |
| **New Distribution** | 1,825,000 | 50% |

---

## 🔧 Contract Migration

### Old Contracts (PulseChain)
```
RARE-ERC20:     0x... (Solidity 0.6.x)
Rare Fountain:  0x... (Solidity 0.6.x)
Rare Lotto:     0x... (Solidity 0.6.x)
Rare Staking:   0x... (Solidity 0.5.x)
```

### New Contracts (Base Chain)
```
RARE-ERC20-v2:     (Solidity 0.8.20)
Rare Fountain-v2:  (Solidity 0.8.20)
Rare Lotto-v2:     (Solidity 0.8.20)
Rare Staking-v2:   (Solidity 0.8.20)
Airdrop Contract:  (Solidity 0.8.20)
```

---

## 📋 Migration Checklist

### Before Snapshot
- [ ] Announce migration publicly
- [ ] Set snapshot date
- [ ] Set cutoff date for old claims
- [ ] Deploy new contracts to Base testnet
- [ ] Test airdrop claiming
- [ ] Audit new contracts

### Snapshot Day
- [ ] Record block number
- [ ] Export all balances
- [ ] Generate Merkle tree
- [ ] Verify totals match

### After Snapshot
- [ ] Deploy contracts to Base mainnet
- [ ] Upload Merkle root
- [ ] Open claims
- [ ] Monitor claims
- [ ] Support users

### Post-Migration
- [ ] Pause old contract (optional)
- [ ] Begin new distribution
- [ ] Update website/docs
- [ ] Community support

---

## ⚠️ Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Users miss snapshot | Long announcement window |
| Bots claim airdrop | Accept - they had tokens |
| High gas for claims | Merkle drop (claim when cheap) |
| Users lose keys | Cannot recover - same as any crypto |
| Old contract exploited | Pause if needed |

---

## 📊 Success Metrics

| Metric | Target |
|--------|--------|
| Claims within 30 days | 80% of holders |
| Total value migrated | 90% of old supply |
| Community sentiment | Positive |
| New user growth | 10,000+ new wallets |

---

## NEXT STEPS

1. **Decide cutoff date** for old claims
2. **Announce publicly** (2 weeks notice)
3. **Build snapshot tool**
4. **Deploy new contracts**
5. **Generate Merkle tree**
6. **Open claims**

---

*Migration Plan v1.0*
*Created: 2026-02-24*
*Author: Felix*
