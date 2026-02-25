# Rare Staking Contract - Additional Code Analysis

## Code Received: renewStake + Calculation Functions

---

## 📋 Function Overview

### 1. renewStake()
**Purpose:** Relock current position for a new bonus length

```solidity
function renewStake(uint _amt, uint _pickterm) chkAmt(_amt) termBlk(_amt) public payable {
    // 1. Validate
    require(getActiveStakedNum() >= 1, "Must Have Something Stake");
    require(_pickterm == 1 || _pickterm == 2 || _pickterm == 3, "Invalid term");
    require(msg.value >= getFee(), "You must cover the xDai transaction fee");
    
    // 2. Pay fee
    manager.transfer(getFee().div(2));
    
    // 3. Set new term
    staker[msg.sender].tokenLock[_amt].lastClaimBlock = uint32(block.number);
    
    // 4. Pick term (1, 2, or 3 months)
    if(_pickterm == 1) {
        staker[msg.sender].tokenLock[_amt].termLocked = uint32(block.number.add(A));
        staker[msg.sender].tokenLock[_amt].bonus = termBonusA;
    } else if(_pickterm == 2) {
        staker[msg.sender].tokenLock[_amt].termLocked = uint32(block.number.add(B));
        staker[msg.sender].tokenLock[_amt].bonus = termBonusB;
    } else if(_pickterm == 3) {
        staker[msg.sender].tokenLock[_amt].termLocked = uint32(block.number.add(C));
        staker[msg.sender].tokenLock[_amt].bonus = termBonusC;
    }
    
    // 5. Calculate bonuses
    // ...
}
```

### 2. Calculation Functions

| Function | Purpose | Formula |
|----------|---------|---------|
| `calcDividend` | Calculate payout from pool | `_poolBal * _basisPoints / 100 ether` |
| `calcPercentage` | Calculate percentage in basis points | `(_stakedBal * 100 ether) / _totalBal` |
| `calcEstFutureReturns` | Estimate returns over weeks | Complex calculation |
| `getTermBonus` | Get term multiplier | Returns 1, 2, or 3 |

---

## 🔍 Key Features

### Term System (Lock Periods)
```
Term 1 (A): Short lock, lower bonus
Term 2 (B): Medium lock, medium bonus  
Term 3 (C): Long lock, higher bonus
```

### Basis Points System
```
100% = 100 ether
10% = 10 ether
1% = 1 ether
```

### Fee Structure
- User pays `getFee()` to renew
- Manager gets `getFee().div(2)` (half the fee)
- Other half goes to pool?

---

## 🔴 Issues Found

### 1. Old Solidity Patterns
```solidity
.mul()  // SafeMath - not needed in 0.8.x
.div()  // SafeMath - not needed in 0.8.x
.add()  // SafeMath - not needed in 0.8.x
```

### 2. No ReentrancyGuard
```solidity
manager.transfer(getFee().div(2));  // External call
// State updated after - vulnerable
```

### 3. Manager Fee Transfer
```solidity
manager.transfer(getFee().div(2));
```
**Issue:** Manager gets half of every renewal fee. Could be exploited.

### 4. Complex Bonus Calculations
```solidity
function calcEstFutureReturns(uint _amt, uint _pickterm, uint _weekNum) public view returns(uint) {
    // Very complex calculation
    // Could have edge cases / overflow issues
}
```

### 5. Integer Size Mixing
```solidity
uint32(block.number.add(A))  // Casting to uint32
uint _amt                    // uint256
```
**Issue:** Mixing sizes can cause issues

---

## ✅ Good Features

1. **Term system** - Lock periods for bonuses
2. **Basis points** - Precise percentage calculations
3. **Estimation function** - Users can see expected returns
4. **Validation** - Multiple require statements
5. **Events** - Emits NewStaker event

---

## 🔧 How to Modernize

### For Solidity 0.8.x:

```solidity
// OLD (0.5.x/0.6.x)
_poolBal.mul(_basisPoints).div(100 ether)

// NEW (0.8.x)
(_poolBal * _basisPoints) / 100 ether
```

### Add ReentrancyGuard:

```solidity
function renewStake(uint _amt, uint _pickterm) 
    chkAmt(_amt) 
    termBlk(_amt) 
    nonReentrant  // Add this
    public 
    payable 
{
    // ...
}
```

### Update Fee to RarePool:

```solidity
// OLD
manager.transfer(getFee().div(2));

// NEW
uint256 fee = getFeeInEth();
(bool success, ) = rarePool.call{value: fee}("");
require(success, "Fee transfer failed");
```

---

## 📊 Term System Analysis

Based on the code, there are 3 lock terms:

| Term | Lock Period | Bonus |
|------|-------------|-------|
| 1 (A) | Short | termBonusA |
| 2 (B) | Medium | termBonusB |
| 3 (C) | Long | termBonusC |

**Typical structure:**
- Term 1: 1 month lock, 5% bonus
- Term 2: 3 month lock, 10% bonus
- Term 3: 6 month lock, 20% bonus

---

## 🎯 For New Contract

Keep these features:
1. ✅ Term system (3 lock periods)
2. ✅ Basis points for calculations
3. ✅ Estimation function
4. ✅ Renewal mechanism

Add these improvements:
1. ✅ Solidity 0.8.x (no SafeMath)
2. ✅ ReentrancyGuard
3. ✅ RarePool integration for fees
4. ✅ Better variable naming
5. ✅ Events for all actions

---

*Analysis v1.0*
*Created: 2026-02-24*
