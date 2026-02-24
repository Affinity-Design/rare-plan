# Rare Fountain Contract Audit

## Contract Overview

**File:** Rare Fountain
**Solidity:** >=0.6.0 <0.8.0
**Purpose:** Distribution contract with dual-pool claiming system
**Dependencies:** SafeMath, Terc20 (custom ERC20)

---

## 🔴 CRITICAL ISSUES

### 1. Reentrancy Vulnerability in claimBounty()
```solidity
function claimBounty() public blk returns (bool) {
    // ... calculations ...
    
    // VULNERABLE: External transfers before state updates
    rare.transfer(stakeContract, 1 ether);
    rare.transfer(lotteryContract, poolRemainder);
    rare.transfer(payable(msg.sender), claimerAmt2.mul(bountyRewardMultiplier));
    
    // State updated AFTER transfers - reentrancy possible!
    regInc = 0;
    claimerAmt = 0;
    regPeriod = false;
}
```

**Attack Vector:**
1. Attacker calls claimBounty()
2. During rare.transfer(), attacker's fallback function re-enters
3. Can drain contract before state is updated

**Fix:** Use ReentrancyGuard + update state before transfers

### 2. Reentrancy in claim()
```solidity
function claim() public alw returns (bool) {
    // State check
    require(checkReg[msg.sender] == true, "...");
    
    // State update AFTER transfer
    checkReg[msg.sender] = false;
    regInc = regInc.sub(1);
    rare.transfer(payable(msg.sender), claimerAmt);  // External call BEFORE state update
}
```

**Fix:** Update state BEFORE transfer

### 3. No Stake-to-Claim (User Requirement)
**Issue:** User specified stake-to-claim is required for bot-proofing. This contract has no staking requirement.

**Fix:** Add stake requirement to register()

### 4. No Rate Limiting (User Requirement)
**Issue:** No cooldown between registrations per address.

**Fix:** Add 24h rate limit

### 5. Solidity Version (0.6.x)
**Issue:** No built-in overflow protection

**Fix:** Upgrade to 0.8.x

### 6. Pool Balance Hardcoded
```solidity
poolBalance = 1 ether;  // Hardcoded
```
**Issue:** With new supply of 1M tokens, this needs recalculation

---

## 🟡 MEDIUM ISSUES

### 7. Manager Has Too Much Power
```solidity
function setFee(uint64 _fee) public restricted {
    require(_fee < 0.1 ether, "Cant set the fee higher then 0.1 xDai");
    fee = _fee;
}
```
**Issue:** Manager can change fee, bounty rewards, block timing

**Recommendation:** Add timelock or multi-sig

### 8. No Pause Function
**Issue:** Cannot stop contract if bug found

**Fix:** Add Pausable from OpenZeppelin

### 9. Admin Withdraw Allows Drain
```solidity
function adminWithdraw() public restricted {
    require(address(this).balance >= 111 ether, "...");
    manager.transfer(100 ether);
}
```
**Issue:** Manager can drain 100 ETH at a time

### 10. Gas Refund Logic
```solidity
gasUsed = gasUsed.add(53000); // Magic number
```
**Issue:** Hardcoded gas calculation may be incorrect

### 11. Integer Size Inconsistencies
```solidity
uint8 public bountyRewardMultiplier;
uint64 private fee;
uint64 public poolBalance;
uint16 public blocksPerDay;
```
**Issue:** Mixing uint sizes can cause issues

---

## 🟢 POSITIVE FINDINGS

1. ✅ Uses SafeMath for arithmetic
2. ✅ Dual pool system is clever for fairness
3. ✅ Events are emitted
4. ✅ Bounty hunter incentivized to trigger distribution
5. ✅ Gas refund for bounty hunter
6. ✅ Cycle tracking prevents double claims

---

## 📋 DUAL POOL SYSTEM ANALYSIS

The contract implements an alternating pool system:

```
Day 1: Period 1 - Users register
Day 2: Period 2 - Users register, Period 1 claims open
Day 3: Period 1 - Users register, Period 2 claims open
... and so on
```

**How it works:**
1. Users register in current period
2. Next day, they claim from previous period
3. Unclaimed tokens go to lottery
4. 1 token to stakers, 1 token to claimers + lottery

**Benefits:**
- Prevents same-day registration/claim exploits
- Allows time for bot detection
- Fair distribution over time

---

## 🔧 REQUIRED FIXES

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Fountain is ReentrancyGuard, Pausable, Ownable {
    // ... storage ...
    
    // Stake-to-Claim requirement
    uint256 public stakeRequirement = 100 * 10**18; // 100 RARE
    mapping(address => uint256) public stakedAmount;
    
    // Rate limiting
    mapping(address => uint256) public lastRegistrationTime;
    uint256 public registrationCooldown = 1 days;
    
    function register() public payable nonReentrant whenNotPaused returns (bool) {
        // Rate limiting
        require(
            block.timestamp >= lastRegistrationTime[msg.sender] + registrationCooldown,
            "Must wait 24h between registrations"
        );
        
        // Stake-to-Claim
        require(
            msg.value >= stakeRequirement || rare.balanceOf(msg.sender) >= stakeRequirement,
            "Stake required to register"
        );
        
        if (msg.value > 0) {
            stakedAmount[msg.sender] = msg.value;
        }
        
        lastRegistrationTime[msg.sender] = block.timestamp;
        
        // ... rest of registration logic ...
    }
    
    function claim() public nonReentrant whenNotPaused returns (bool) {
        // Update state BEFORE transfer
        checkReg[msg.sender] = false;
        regInc = regInc.sub(1);
        
        // Then transfer
        rare.transfer(payable(msg.sender), claimerAmt);
        
        // Return stake after claim period
        // ...
    }
    
    function claimBounty() public nonReentrant whenNotPaused returns (bool) {
        // Update ALL state FIRST
        cycleCount = uint16(cycleCount.add(1));
        regInc = 0;
        claimerAmt = 0;
        regPeriod = !regPeriod;
        
        // Then do transfers
        rare.transfer(stakeContract, 1 ether);
        rare.transfer(lotteryContract, poolRemainder);
        rare.transfer(payable(msg.sender), bountyAmount);
    }
}
```

---

## SUMMARY

| Issue | Severity | Fix Required |
|-------|----------|--------------|
| Reentrancy in claimBounty() | 🔴 Critical | Yes |
| Reentrancy in claim() | 🔴 Critical | Yes |
| No stake-to-claim | 🔴 Critical | Yes |
| No rate limiting | 🔴 Critical | Yes |
| Solidity 0.6.x | 🔴 Critical | Yes |
| Pool balance hardcoded | 🔴 Critical | Yes |
| Manager power | 🟡 Medium | Recommended |
| No pause | 🟡 Medium | Yes |
| Gas calculation | 🟡 Medium | Yes |

---

*Audit completed: 2026-02-24*
