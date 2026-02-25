# Rare Staking Contract - Full Audit

## Contract Overview

**Name:** Rare_Staking
**Solidity:** >=0.6.0 <0.8.0
**Purpose:** Stake LP tokens to earn RARE dividends
**Addresses:**
- RARE Token: `0x57e93BB58268dE818B42E3795c97BAD58aFCD3Fe`
- RARE LP Token: `0x5805bb63e73Ec272c74e210D280C05B41D719827`

---

## 📋 Contract Structure

### Interfaces
- **IERC1155** - NFT standard
- **IERC20** - Token standard

### Contracts
- **Rare_Staking** - Main staking contract

### External Contracts
- `rare` - RARE token
- `rareLP` - RARE/xDai LP tokens
- `nft1` - `nft5` - NFT boosters

---

## 🔴 CRITICAL ISSUES

### 1. Reentrancy Vulnerability in claimRare()
```solidity
function claimRare(uint _amt) chkAmt(_amt) blk(_amt) termBlk(_amt) public {
    // Calculate rewards
    uint reward = calcTotalBonusVal(_amt);
    
    // State updates AFTER calculations but BEFORE transfers
    staker[msg.sender].tokenLock[_amt].nextClaimLocked = uint32(block.number + A);
    
    // External calls - vulnerable!
    payable(msg.sender).transfer(xdai_payout);  // ETH transfer
    rare.transfer(msg.sender, reward);           // Token transfer
    
    // State not fully updated - reentrancy possible!
}
```

**Attack Vector:**
1. Attacker calls claimRare()
2. During `payable(msg.sender).transfer()`, attacker's fallback re-enters
3. Can claim multiple times before state updates

### 2. Reentrancy in removeLPtokens()
```solidity
function removeLPtokens(uint _amt) chkAmt(_amt) termBlk(_amt) public {
    // Claims if possible
    if(staker[msg.sender].tokenLock[_amt].nextClaimLocked <= block.number){
        claimRare(_amt);  // Reentrancy via claimRare!
    }
    
    // State updates
    staker[msg.sender].tokenLock[_amt].amtLocked = 0;
    
    // External transfer
    rareLP.transfer(msg.sender, _amt.mul(amtInst));
}
```

### 3. Reentrancy in stakeLPtokens()
```solidity
function stakeLPtokens(uint _pickterm) public payable {
    // ...
    
    // External transfer at end
    rareLP.transferFrom(msg.sender, address(this), allowedAmt);
    
    // Event after transfer
    emit NewStaker(...);
}
```

### 4. Manager Fee Transfer (Centralization)
```solidity
manager.transfer(getFee().div(2));
```
**Issue:** Manager gets 50% of all fees. Can drain user funds.

### 5. No ReentrancyGuard
**Issue:** No protection against reentrancy attacks.

### 6. Solidity 0.6.x (No Overflow Protection)
```solidity
pragma solidity >=0.6.0 <0.8.0;
```
**Issue:** No built-in overflow checks. Must rely on SafeMath.

---

## 🟡 MEDIUM ISSUES

### 7. NFT Integration Unused
```solidity
IERC1155 private nft1;
IERC1155 private nft2;
// ... etc
```
**Issue:** NFT contracts declared but not used in staking logic.

### 8. Complex Bonus Calculations
```solidity
function calcTotalBonusVal(uint _amt) public view returns(uint) {
    // Complex calculation with multiple steps
    // Edge cases possible
}
```

### 9. Integer Size Mixing
```solidity
uint8 private termBonusA = 1;
uint32 private A = 120400;
uint public mstrLiqBal;
```
**Issue:** Mixing uint sizes can cause issues.

### 10. Fee Calculation
```solidity
uint64 private fee;
function getFee() public view returns (uint64) {
    return fee;
}
```
**Issue:** Fixed fee, doesn't adjust for ETH price.

### 11. No Pause Function
**Issue:** Cannot stop staking if bug found.

### 12. No Events for All Actions
**Issue:** Some state changes don't emit events.

---

## 📊 Term System Analysis

### Lock Periods
```solidity
uint32 private A = 120400;    // 7 days in blocks
uint32 private B = A*4;       // 28 days in blocks
uint32 private C = A*12;      // 84 days in blocks
```

### Bonuses
```solidity
uint8 private termBonusA = 1;  // 1x multiplier
uint8 private termBonusB = 2;  // 2x multiplier
uint8 private termBonusC = 3;  // 3x multiplier
```

| Term | Lock Period | Bonus |
|------|-------------|-------|
| 1 (A) | 7 days | 1x |
| 2 (B) | 28 days | 2x |
| 3 (C) | 84 days | 3x |

---

## 📐 Staking Flow

### Stake LP Tokens
```
1. User approves LP tokens
2. User calls stakeLPtokens(term)
3. User pays fee (1 xDai)
4. Manager gets 0.5 xDai
5. LP tokens transferred to contract
6. Term locked based on selection
7. Bonus calculated
8. Event emitted
```

### Claim Rewards
```
1. User calls claimRare(amt)
2. Check if claimable (nextClaimLocked <= block.number)
3. Calculate rewards
4. Lock for another 7 days
5. Transfer xDai payout
6. Transfer RARE rewards
7. Event emitted
```

### Unstake
```
1. User calls removeLPtokens(amt)
2. Check if term expired
3. Auto-claim if possible
4. Update state
5. Transfer LP tokens back
6. Event emitted
```

---

## 🧮 Calculation Functions

### calcDividend()
```solidity
function calcDividend(uint _poolBal, uint _basisPoints) public pure returns(uint) {
    return _poolBal.mul(_basisPoints).div(100 ether);
}
```
**Purpose:** Calculate payout based on basis points

### calcPercentage()
```solidity
function calcPercentage(uint _stakedBal, uint _totalBal) public pure returns (uint) {
    return _stakedBal.mul(100 ether).div(_totalBal);
}
```
**Purpose:** Calculate stake percentage

### calcTotalBonusVal()
**Purpose:** Calculate total bonus value including term and weekly bonuses

---

## 🔧 Required Fixes

### 1. Add ReentrancyGuard
```solidity
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Rare_Staking is ReentrancyGuard {
    function claimRare(uint _amt) public nonReentrant {
        // ...
    }
}
```

### 2. Update State Before Transfers
```solidity
function claimRare(uint _amt) public nonReentrant {
    // Calculate rewards
    uint reward = calcTotalBonusVal(_amt);
    
    // Update state FIRST
    staker[msg.sender].tokenLock[_amt].nextClaimLocked = uint32(block.number + A);
    totalRareClaimed = totalRareClaimed.add(reward);
    
    // Then transfer
    rare.transfer(msg.sender, reward);
}
```

### 3. Replace Manager Fee with RarePool
```solidity
// OLD
manager.transfer(getFee().div(2));

// NEW
(bool success, ) = rarePool.call{value: fee}("");
require(success, "Fee transfer failed");
```

### 4. Upgrade to Solidity 0.8.x
```solidity
// OLD
pragma solidity >=0.6.0 <0.8.0;

// NEW
pragma solidity ^0.8.20;
```

### 5. Remove SafeMath
```solidity
// OLD
_poolBal.mul(_basisPoints).div(100 ether)

// NEW
(_poolBal * _basisPoints) / 100 ether
```

---

## ✅ Good Features

1. ✅ Term system (7/28/84 days)
2. ✅ Bonus multipliers (1x/2x/3x)
3. ✅ LP token staking
4. ✅ Weekly claim cycle
5. ✅ Events for major actions
6. ✅ NFT integration (prepared)
7. ✅ Basis points for calculations

---

## 📋 Summary Table

| Issue | Severity | Fix Required |
|-------|----------|--------------|
| Reentrancy in claimRare | 🔴 Critical | Yes |
| Reentrancy in removeLPtokens | 🔴 Critical | Yes |
| Reentrancy in stakeLPtokens | 🔴 Critical | Yes |
| Manager fee centralization | 🔴 Critical | Yes |
| No ReentrancyGuard | 🔴 Critical | Yes |
| Solidity 0.6.x | 🔴 Critical | Yes |
| NFT integration unused | 🟡 Medium | Optional |
| Complex calculations | 🟡 Medium | Review |
| No pause | 🟡 Medium | Yes |
| Fixed fee | 🟡 Medium | Yes |

---

## 🎯 For New Contract

### Keep:
1. ✅ Term system (3 lock periods)
2. ✅ Bonus multipliers
3. ✅ LP token staking
4. ✅ Weekly claim cycle
5. ✅ Events

### Add:
1. ✅ Solidity 0.8.20
2. ✅ ReentrancyGuard
3. ✅ RarePool integration
4. ✅ FeeRegistry integration
5. ✅ Pause functionality
6. ✅ Better events

### Remove:
1. ❌ SafeMath
2. ❌ Manager fee
3. ❌ NFT (unless used)

---

*Full Audit v1.0*
*Created: 2026-02-24*
*Auditor: Felix*
