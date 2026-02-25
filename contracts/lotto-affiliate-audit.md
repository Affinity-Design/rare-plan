# Rare Lotto Affiliate Contract Audit

## Contract Overview

**File:** lotto-affiliate.sol
**Solidity:** >=0.6.0 <0.8.0
**Purpose:** Lottery with affiliate/referral system
**Key Feature:** Affiliates earn percentage of referred player's tickets

---

## 📋 Contract Structure

### Core Components
- **IERC20** - Token interface for RARE
- **Rnd** - Random number interface
- **RareLottoAffiliate** - Main lottery contract with referral system

### Storage Variables
```solidity
Rnd private random;           // Random number contract
Allerc20 private rare;        // RARE token
address payable private manager;
address[] private players;    // Array of players
uint64 private fee;           // Entry fee
uint64 private btnReward;     // Bounty hunter reward
uint64 public price;          // Ticket price
address public lastWinner;    // Last winner address
uint16 public drawCount;      // Number of draws

// NEW: Affiliate system
struct Info {
    uint16 lastEntry;         // Last lottery entered
    uint16 timesEntered;      // Total entries
    uint amt;                 // Amount spent
    uint allowance;           // Approved amount
    address affiliate;        // Referrer address
}

mapping(address => Info) public gambler;
mapping(address => uint) public affiliateEarnings;  // Affiliate earnings
uint public affiliatePercent = 10;  // 10% affiliate commission
```

---

## 🔴 CRITICAL ISSUES

### 1. Reentrancy in pickWinner()
```solidity
function pickWinner() public blk {
    random.useSeed();
    uint seed = getSeed();
    uint i = seed % players.length;
    
    // External calls before state reset - VULNERABLE!
    rare.transfer(payable(players[i]), winnerAmt);
    rare.transfer(payable(msg.sender), rareRefund);
    msg.sender.transfer(address(this).balance);
    
    // State reset AFTER transfers
    players = new address[](0);
    drawCount = uint16(drawCount.add(1));
}
```

### 2. Predictable Randomness
```solidity
function getSeed() private view returns (uint){
    uint seed;
    if(random.seedUp() == random.seedDw()){
        seed = random.seedDw();
    } else {
        seed = random.seedUp();
    }
    return seed;
}
```
**Issue:** External random contract - need to audit that too

### 3. No Minimum Players
```solidity
uint i = seed % players.length;  // Could be 1 player
```

### 4. Affiliate Earnings Not Claimable
```solidity
mapping(address => uint) public affiliateEarnings;
```
**Issue:** Earnings tracked but no function to claim them!

### 5. Solidity 0.6.x (No Overflow Protection)

### 6. Manager Can Set High Fees
```solidity
function setFee(uint64 _fee) public restricted {
    require(_fee <= 50 ether, "Cant set the dev fee higher then 50 xDai");
    fee = _fee;
}
```

---

## 🟡 MEDIUM ISSUES

### 7. Affiliate Tracking But No Payout
```solidity
// In enter()
gambler[msg.sender].affiliate = _affiliate;  // Tracked
affiliateEarnings[_affiliate] += commission;  // Earned
// But no claim function!
```

### 8. No Affiliate Validation
```solidity
function enter(address _affiliate) public payable alw {
    // No check if _affiliate is valid
    // Could be zero address
    // Could be self-referral
}
```

### 9. No Events for Affiliate Actions
**Issue:** No event for affiliate earnings

### 10. Fixed Affiliate Percentage
```solidity
uint public affiliatePercent = 10;  // 10% fixed
```
**Issue:** Cannot change without code modification

---

## 📐 Affiliate System Analysis

### How It Works (Intended)

```
1. User A becomes affiliate (gets referral link)
2. User B enters lottery using A's referral
3. User B pays 0.001 RARE for ticket
4. 10% (0.0001 RARE) goes to User A
5. 90% (0.0009 RARE) goes to lottery pot
6. User A accumulates earnings
7. User A claims earnings (MISSING FUNCTION!)
```

### Current Code Flow

```solidity
function enter(address _affiliate) public payable alw {
    // ... validation ...
    
    // Track affiliate
    gambler[msg.sender].affiliate = _affiliate;
    
    // Calculate commission
    uint commission = (gambler[msg.sender].allowance * affiliatePercent) / 100;
    
    // Add to affiliate earnings
    affiliateEarnings[_affiliate] += commission;
    
    // ... rest of entry logic ...
}
```

### Missing: Affiliate Claim Function
```solidity
// NEEDED BUT MISSING:
function claimAffiliateEarnings() public {
    uint earnings = affiliateEarnings[msg.sender];
    require(earnings > 0, "No earnings");
    
    affiliateEarnings[msg.sender] = 0;
    rare.transfer(msg.sender, earnings);
    
    emit AffiliateClaimed(msg.sender, earnings);
}
```

---

## 🔧 Required Fixes

### 1. Add ReentrancyGuard
```solidity
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

function pickWinner() public nonReentrant {
    // ...
}
```

### 2. Add Affiliate Claim Function
```solidity
function claimAffiliateEarnings() public nonReentrant {
    uint earnings = affiliateEarnings[msg.sender];
    require(earnings > 0, "No earnings to claim");
    
    affiliateEarnings[msg.sender] = 0;
    
    // State updated before transfer
    emit AffiliateClaimed(msg.sender, earnings);
    
    rare.transfer(msg.sender, earnings);
}
```

### 3. Validate Affiliate
```solidity
function enter(address _affiliate) public payable {
    // Prevent self-referral
    require(_affiliate != msg.sender, "Cannot refer yourself");
    
    // Prevent zero address
    require(_affiliate != address(0), "Invalid affiliate");
    
    // ...
}
```

### 4. Add Affiliate Events
```solidity
event AffiliateEarned(address indexed affiliate, address indexed player, uint amount);
event AffiliateClaimed(address indexed affiliate, uint amount);
```

### 5. Use Chainlink VRF
```solidity
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
    uint256 winnerIndex = randomness % players.length;
    // ...
}
```

---

## 📊 Comparison: Lotto vs Lotto+Affiliate

| Feature | Basic Lotto | Lotto + Affiliate |
|---------|-------------|-------------------|
| **Ticket Purchase** | ✅ | ✅ |
| **Winner Selection** | ✅ | ✅ |
| **Affiliate Tracking** | ❌ | ✅ |
| **Affiliate Earnings** | ❌ | ✅ (tracked) |
| **Affiliate Claim** | ❌ | ❌ (MISSING) |
| **Self-Referral Prevention** | ❌ | ❌ (MISSING) |

---

## ✅ Good Features

1. ✅ Affiliate tracking system
2. ✅ Percentage-based commissions
3. ✅ Earnings accumulation
4. ✅ Referral linking

---

## 🔴 Missing Features (Critical)

1. ❌ **Affiliate claim function** - Cannot withdraw earnings!
2. ❌ **Self-referral prevention** - Users can refer themselves
3. ❌ **Zero address check** - Invalid affiliates possible
4. ❌ **Affiliate events** - No tracking of earnings

---

## 📋 For New Contract

### Keep:
1. ✅ Affiliate tracking
2. ✅ Percentage commissions
3. ✅ Earnings accumulation

### Add:
1. ✅ Affiliate claim function
2. ✅ Self-referral prevention
3. ✅ Zero address validation
4. ✅ Affiliate events
5. ✅ Configurable commission %
6. ✅ ReentrancyGuard
7. ✅ Chainlink VRF

---

## Summary

| Issue | Severity | Fix Required |
|-------|----------|--------------|
| Reentrancy | 🔴 Critical | Yes |
| No affiliate claim | 🔴 Critical | Yes |
| Self-referral possible | 🔴 Critical | Yes |
| Predictable randomness | 🔴 Critical | Yes |
| No minimum players | 🔴 Critical | Yes |
| Solidity 0.6.x | 🔴 Critical | Yes |
| No affiliate events | 🟡 Medium | Yes |

---

*Audit v1.0*
*Created: 2026-02-24*
*Auditor: Felix*
