# Rare Staking Contract - Complete Code Reference

## All Functions Documented

---

## 📊 View Functions (User)

| Function | Returns | Description |
|----------|---------|-------------|
| `getTermLeft(uint _amt)` | uint (blocks) | Blocks until term expires |
| `getWeekLeft(uint _amt)` | uint (blocks) | Blocks until weekly claim available |
| `getCurrentTermBonusBP(uint _amt)` | uint (bp) | Current term bonus in basis points |
| `getCurrentWeeklyBonusBP(uint _amt)` | uint (bp) | Current weekly bonus in basis points |
| `getNextClaimReward(uint _amt)` | uint (wei) | Estimated RARE payout on next claim |
| `isAmtUnlocked(uint _amt)` | bool | Is term expired? |
| `canClaim(uint _amt)` | bool | Can claim this week? |

---

## 📊 View Functions (User Stats)

| Function | Returns | Description |
|----------|---------|-------------|
| `getTotalLPtokens()` | uint | Total LP tokens staked |
| `getTotalClaimedAmt()` | uint | Total RARE claimed to date |
| `getActiveStakedNum()` | uint | Active stake count |
| `getHistoryStakedNum()` | uint | Historical stake count |
| `getTotalTimesClaimed()` | uint | Total claims made |

---

## 📊 View Functions (Global)

| Function | Returns | Description |
|----------|---------|-------------|
| `getFee()` | uint | Fee (with NFT discount) |
| `getRareBalance()` | uint | Contract RARE balance |
| `getXdaiBalance()` | uint | Contract ETH balance |

---

## 🔧 Internal Calculation Functions

### calcTotalBonusVal()
```solidity
function calcTotalBonusVal(uint _amt) internal view returns(uint) {
    return calcTermVal(_amt).add(calcWeeklyBonusVal(_amt));
}
```
**Purpose:** Total bonus = Term bonus + Weekly bonus

### calcTermVal()
```solidity
function calcTermVal(uint _amt) internal view returns(uint) {
    uint lpTermBonus = calcTermBonusLP(_amt);
    uint bp = calcPercentage(lpTermBonus, calcLiqBonus);
    return calcDividend(rare.balanceOf(address(this)), bp);
}
```
**Purpose:** Calculate term bonus RARE amount

### calcWeeklyBonusVal()
```solidity
function calcWeeklyBonusVal(uint _amt) internal view returns(uint) {
    uint lpWeeklyBonus = calcWeeklyBonusLP(_amt);
    uint mstrTempLiqBal = calcLiqBonus.add(lpWeeklyBonus);
    uint termLP = calcTermBonusLP(_amt);
    uint bp = calcPercentage(termLP.add(lpWeeklyBonus), mstrTempLiqBal);
    uint fullPayoutAmt = calcDividend(rare.balanceOf(address(this)), bp);
    return fullPayoutAmt.sub(calcTermVal(_amt));
}
```
**Purpose:** Calculate weekly bonus RARE amount

### calcTermBonusLP()
```solidity
function calcTermBonusLP(uint _amt) internal view returns(uint) {
    return _amt.mul(staker[msg.sender].tokenLock[_amt].amtInst)
                .mul(staker[msg.sender].tokenLock[_amt].bonus);
}
```
**Formula:** `amount × instances × bonus`

### calcWeeklyBonusLP()
```solidity
function calcWeeklyBonusLP(uint _amt) internal view returns(uint) {
    uint weeklyBP = calcWeeklyBonusBP(_amt);
    return calcDividend(_amt, weeklyBP);
}
```
**Purpose:** Weekly LP bonus based on weeks passed

### calcWeeklyBonusBP()
```solidity
function calcWeeklyBonusBP(uint _amt) internal view returns(uint) {
    uint weeklyCompBP;
    uint payments = (block.number - lastClaimBlock) / A;  // Weeks passed
    
    if(payments >= 1) {
        for (uint i = 0; i <= payments-1; i++) {
            weeklyCompBP = weeklyCompBP + 1 ether;  // +1% per week
        }
        
        // NFT bonuses
        if (nft2.balanceOf(msg.sender, nft2id) >= 1) weeklyCompBP += nft2_value;
        if (nft3.balanceOf(msg.sender, nft3id) >= 1) weeklyCompBP += nft3_value;
        if (nft4.balanceOf(msg.sender, nft4id) >= 1) weeklyCompBP += nft4_value;
        if (nft5.balanceOf(msg.sender, nft5id) >= 1) weeklyCompBP += nft5_value;
        
        return weeklyCompBP;
    }
    return 0;
}
```
**Purpose:** Calculate weekly bonus basis points (+1% per week, +NFT bonuses)

---

## 🎛️ Manager Functions

| Function | What it does |
|----------|--------------|
| `setNFTAddrs(...)` | Set NFT contract addresses and IDs |
| `setFee(uint64 _fee)` | Set fee (max 10 ETH) |
| `setWeekLength(uint32 _blockNum)` | Set week length in blocks |
| `setManager(address _newManager)` | Transfer ownership |

---

## 🔒 Modifiers

| Modifier | Condition |
|----------|-----------|
| `termBlk(uint _amt)` | Term must be expired |
| `blk(uint _amt)` | Week must be up |
| `chkAmt(uint _amt)` | Amount must be staked |
| `restricted()` | Manager only |

---

## 🎨 NFT Bonus System

### NFT Values
```solidity
uint8 private nft1_value = 2;        // 2x fee discount
uint private nft2_value = 10 ether;  // +10% weekly bonus
uint private nft3_value = 25 ether;  // +25% weekly bonus
uint private nft4_value = 50 ether;  // +50% weekly bonus
uint private nft5_value = 100 ether; // +100% weekly bonus
```

### NFT Effects
| NFT | Effect |
|-----|--------|
| **NFT 1** | Fee divided by 2 (50% discount) |
| **NFT 2** | +10 ether to weekly bonus BP |
| **NFT 3** | +25 ether to weekly bonus BP |
| **NFT 4** | +50 ether to weekly bonus BP |
| **NFT 5** | +100 ether to weekly bonus BP |

---

## 📐 Complete Formula Summary

### Term Bonus
```
termBonusLP = amount × instances × termMultiplier
termBP = (termBonusLP / calcLiqBonus) × 100 ether
termPayout = (rareBalance × termBP) / 100 ether
```

### Weekly Bonus
```
weeksPassed = (block.number - lastClaimBlock) / A
weeklyBP = weeksPassed × 1 ether  (+ NFT bonuses)
weeklyBonusLP = (amount × weeklyBP) / 100 ether
weeklyBP = ((termLP + weeklyLP) / totalLP) × 100 ether
weeklyPayout = (rareBalance × weeklyBP) / 100 ether - termPayout
```

### Total Payout
```
totalPayout = termPayout + weeklyPayout
```

---

## 📊 Complete Contract Summary

### Core Functions
1. `stakeLPtokens(term)` - Stake LP tokens
2. `removeLPtokens(amt)` - Unstake LP tokens
3. `renewStake(amt, term)` - Extend lock period
4. `claimRare(amt)` - Claim RARE rewards

### View Functions
- 7 user view functions
- 5 user stat functions
- 3 global stat functions

### Calculation Functions
- 6 internal calculation functions
- Complex bonus formula with NFT multipliers

### Modifiers
- 4 modifiers for validation

### Manager Functions
- 4 admin functions

---

## ✅ For New Contract

### Keep These Features:
1. ✅ Term system (7/28/84 days)
2. ✅ Bonus multipliers (1x/2x/3x)
3. ✅ Weekly compound bonus
4. ✅ NFT boost system
5. ✅ View functions for stats
6. ✅ Modifiers for validation

### Modernize:
1. ✅ Solidity 0.8.20
2. ✅ No SafeMath
3. ✅ ReentrancyGuard
4. ✅ RarePool for fees
5. ✅ Better events
6. ✅ Cleaner code

---

*Complete Reference v1.0*
*Created: 2026-02-24*
