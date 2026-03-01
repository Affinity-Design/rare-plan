# Rare Coin V3 Migration Plan

## Gnosis Chain → Base Chain

Migrating from Gnosis Chain (V2) to Base Chain (V3) while preserving all holder balances and NFT perks.

---

## 📊 Snapshot Sources

### 1. RARE Token Holders
- **Contract:** `0xCF740AC463098E442B31A5E88F4b359B30255616` (Gnosis)
- **Data:** `balanceOf(address)` for all holders

### 2. LP Providers (RARE/xDAI)
- **Contract:** `0x5805bb63e73Ec272c74e210D280C05B41D719827` (Honeyswap LP)
- **Data:** `balanceOf(address)` + calculate underlying RARE

### 3. Stakers
- **Contract:** `0x79bfE41cDbF6b7E949B93B46a2cBEFB497d71c20` (Gnosis)
- **Data:** `staker[address].totalLP` + calculate underlying RARE

### 4. NFT Holders ⭐ NEW
- **Contract:** `0x23D2F04F00cfA734973B0f99fcB5F735Ab40A661` (Gnosis)
- **Standard:** ERC-1155
- **Data:** `balanceOf(address, tokenId)` for IDs 1-5

---

## 🎨 NFT → RARE Mapping

**NFT holders get airdropped RARE to qualify for equivalent V3 holding tier!**

| NFT ID | Old Effect | RARE Airdrop | V3 Tier | New Bonus |
|--------|------------|--------------|---------|-----------|
| **1** | 50% fee discount | **1 RARE** | Tier 1 | +1% |
| **2** | +10% bonus | **10 RARE** | Tier 2 | +5% |
| **3** | +25% bonus | **100 RARE** | Tier 3 | +15% |
| **4** | +50% bonus | **1,000 RARE** | Tier 4 | +35% |
| **5** | +100% bonus | **10,000 RARE** | Tier 5 | +100% |

### Example

```
User holds:
- 50 RARE tokens
- NFT #4 (1 copy)

Airdrop calculation:
- Token balance: 50 RARE
- NFT #4 bonus: 1,000 RARE
- Total airdrop: 1,050 RARE

V3 Status:
- Holds 1,050 RARE → Tier 4 (+35% bonus)
```

---

## 📐 Conversion Ratio

| Source | Conversion |
|--------|------------|
| **RARE Tokens** | 1:1 (unchanged) |
| **LP Tokens** | Calculate underlying RARE |
| **Staked LP** | Calculate underlying RARE |
| **NFTs** | See table above |

**Note:** Unlike previous plan, we're NOT doing 100x inflation. Supply stays at 3,650,000.

---

## 🔄 Migration Strategy

### Phase 1: Snapshot (All Sources)

```javascript
// Snapshot script pseudocode
const sources = {
  rareToken: "0xCF740AC463098E442B31A5E88F4b359B30255616",
  lpToken: "0x5805bb63e73Ec272c74e210D280C05B41D719827",
  staking: "0x79bfE41cDbF6b7E949B93B46a2cBEFB497d71c20",
  nftContract: "0x23D2F04F00cfA734973B0f99fcB5F735Ab40A661"
};

// For each address:
// 1. Get RARE balance
// 2. Get LP balance → calculate underlying RARE
// 3. Get staked amount → calculate underlying RARE
// 4. Get NFT balances (IDs 1-5) → map to RARE amounts
// 5. Sum all sources → final airdrop amount
```

### Phase 2: Merkle Tree Generation

```javascript
// Generate merkle tree
const balances = {
  "0xUser1": 1050,  // 50 RARE + NFT #4 (1000)
  "0xUser2": 100,   // 100 RARE + NFT #3 (100)
  "0xUser3": 10000, // NFT #5 only
  // ...
};

const tree = new MerkleTree(balances);
const root = tree.getRoot();
```

### Phase 3: Claim on Base

Users visit `rare.claims` and claim their combined airdrop.

---

## 📋 NFT Snapshot Details

### ERC-1155 Balance Query

```javascript
// For each NFT ID (1-5)
for (let nftId = 1; nftId <= 5; nftId++) {
  const balance = await nftContract.balanceOf(userAddress, nftId);
  
  // If user has this NFT, add corresponding RARE
  if (balance > 0) {
    const rareAmount = NFT_TO_RARE[nftId] * balance;
    totalAirdrop += rareAmount;
  }
}

const NFT_TO_RARE = {
  1: 1,       // NFT #1 → 1 RARE
  2: 10,      // NFT #2 → 10 RARE
  3: 100,     // NFT #3 → 100 RARE
  4: 1000,    // NFT #4 → 1000 RARE
  5: 10000    // NFT #5 → 10000 RARE
};
```

### Multiple NFTs

**If user holds multiple NFTs of different tiers:**
```
User has: NFT #2 (2 copies) + NFT #4 (1 copy)

Calculation:
- NFT #2: 2 × 10 = 20 RARE
- NFT #4: 1 × 1000 = 1000 RARE
- Total NFT bonus: 1,020 RARE
```

**If user holds multiple NFTs of same tier:**
```
User has: NFT #3 (3 copies)

Calculation:
- NFT #3: 3 × 100 = 300 RARE
- Total NFT bonus: 300 RARE
```

---

## 🛡️ Why This Approach?

### Preserves NFT Value
- NFT holders aren't left behind
- They automatically qualify for V3 holding perks
- No need to buy new NFTs

### Simple Migration
- One claim = all balances combined
- No separate NFT migration
- Everything in RARE tokens

### Fair Mapping
| Old (NFT) | New (RARE Hold) |
|-----------|-----------------|
| Buy NFT #5 | Same as holding 10k RARE |
| +100% bonus | +100% bonus |

---

## 📊 Supply Impact

### Estimated NFT Airdrop

| NFT | Est. Holders | RARE Each | Total RARE |
|-----|--------------|-----------|------------|
| #1 | 500 | 1 | 500 |
| #2 | 300 | 10 | 3,000 |
| #3 | 100 | 100 | 10,000 |
| #4 | 50 | 1,000 | 50,000 |
| #5 | 20 | 10,000 | 200,000 |
| **Total** | ~970 | - | **~263,500** |

**Impact on 3.65M supply:** ~7.2% reserved for NFT holders

---

## 📅 Timeline

| Phase | Duration | Action |
|-------|----------|--------|
| **1** | 2 weeks | Announce migration |
| **2** | 1 week | Final accumulation |
| **3** | 1 day | **Snapshot all sources** |
| **4** | 1 week | Generate merkle tree |
| **5** | 1 week | Deploy V3 on Base |
| **6** | Ongoing | Claims open |

---

## ⚠️ Important Notes

### For NFT Holders
- **NFTs remain on Gnosis** - they don't migrate
- **You get RARE on Base** - equivalent to your NFT tier
- **Keep your NFTs** - they may have collectible value
- **V3 perks are token-based** - no new NFT system

### For All Users
- **One claim per address**
- **Must use same address** on Base
- **No deadline** to claim (but streaks start when you do)

---

## 🔧 Contract Addresses (Gnosis)

| Contract | Address |
|----------|---------|
| RARE Token | `0xCF740AC463098E442B31A5E88F4b359B30255616` |
| RARE/xDAI LP | `0x5805bb63e73Ec272c74e210D280C05B41D719827` |
| Staking | `0x79bfE41cDbF6b7E949B93B46a2cBEFB497d71c20` |
| Fountain | `0xCDe24F566AEa0DeD222aa1B86B044948a1C5501c` |
| **NFT Contract** | `0x23D2F04F00cfA734973B0f99fcB5F735Ab40A661` |

---

## ✅ Migration Checklist

### Pre-Snapshot
- [ ] Announce migration date
- [ ] Document NFT → RARE mapping
- [ ] Test snapshot script
- [ ] Verify NFT contract ABI

### Snapshot Day
- [ ] Record block number
- [ ] Snapshot RARE holders
- [ ] Snapshot LP providers
- [ ] Snapshot stakers
- [ ] **Snapshot NFT holders (IDs 1-5)**
- [ ] Calculate combined balances
- [ ] Generate merkle tree

### Post-Snapshot
- [ ] Deploy V3 contracts
- [ ] Upload merkle root
- [ ] Open claims
- [ ] Support community

---

*Migration Plan v2.0*
*Updated: 2026-03-01*
*Author: Felix - Director of Rare Enterprises*
