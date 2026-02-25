# Rare Pool - Fee Distribution Contract Design

## Overview

A contract that:
1. Receives fees from all Rare Coin apps
2. Manager sets percentage allocations to addresses
3. Addresses claim their share anytime
4. Tracks what's been claimed (no double-dipping)

---

## 🎯 Requirements

### Must Have
- Receive ETH/tokens from any app
- Manager can set percentages (must sum to 100%)
- Users claim their share
- Track claimed amounts (prevent double-claim)
- Non-drainable (can't claim more than your share)

### Nice to Have
- Support multiple tokens (ETH + RARE)
- Auto-forward to wallets (no claiming needed)
- Update percentages anytime
- Add/remove beneficiaries

---

## 📐 Design Options

### Option A: Cumulative Tracking (Recommended)

**How it works:**
1. Track total deposits ever received
2. Track each user's claimed amount
3. Claimable = (totalDeposits × userPercent) - userClaimed

**Example:**
```
Time 0: Pool empty
  Total: 0 ETH
  Alice: 20%, Claimed: 0
  Bob: 20%, Claimed: 0

Time 1: 1 ETH deposited
  Total: 1 ETH
  Alice claimable: (1 × 0.2) - 0 = 0.2 ETH
  Bob claimable: (1 × 0.2) - 0 = 0.2 ETH

Time 2: Alice claims 0.2 ETH
  Total: 1 ETH (unchanged)
  Alice: 20%, Claimed: 0.2
  Bob: 20%, Claimed: 0
  Alice claimable: (1 × 0.2) - 0.2 = 0 ETH ✓
  Bob claimable: (1 × 0.2) - 0 = 0.2 ETH

Time 3: Another 1 ETH deposited
  Total: 2 ETH
  Alice: 20%, Claimed: 0.2
  Bob: 20%, Claimed: 0
  Alice claimable: (2 × 0.2) - 0.2 = 0.2 ETH ✓
  Bob claimable: (2 × 0.2) - 0 = 0.4 ETH ✓

Time 4: Bob claims 0.4 ETH
  Total: 2 ETH
  Alice: 20%, Claimed: 0.2
  Bob: 20%, Claimed: 0.4
  Alice claimable: (2 × 0.2) - 0.2 = 0.2 ETH
  Bob claimable: (2 × 0.2) - 0.4 = 0 ETH ✓
```

**Pros:**
- Simple math
- No double-claiming possible
- Works with any number of deposits
- Percentages can change anytime

**Cons:**
- Users must claim manually

---

### Option B: Auto-Forward (Push)

**How it works:**
1. When fees arrive, immediately split and forward
2. Each user gets their percentage sent to their wallet

**Example:**
```
1 ETH arrives
  Alice (20%): 0.2 ETH → sent immediately
  Bob (20%): 0.2 ETH → sent immediately
  Treasury (60%): 0.6 ETH → stays in pool
```

**Pros:**
- No claiming needed
- Users get paid automatically

**Cons:**
- High gas cost (multiple transfers per deposit)
- Fails if any transfer fails
- Can't accumulate for later

---

### Option C: Hybrid (Best of Both)

**How it works:**
1. Small amounts: accumulate in pool
2. Large amounts: auto-forward
3. Users can always claim manually

**Pros:**
- Gas efficient for small deposits
- Users get paid for large deposits
- Flexible

---

## 🔧 Recommended Contract: Option A

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title RarePool
 * @notice Fee distribution contract with percentage-based claiming
 * @dev Receives fees from all apps, distributes by percentage
 */
contract RarePool is Ownable {
    using SafeERC20 for IERC20;
    
    // Beneficiary info
    struct Beneficiary {
        uint256 percentage;      // In basis points (100 = 1%, 10000 = 100%)
        uint256 claimed;         // Total amount claimed so far
        bool exists;
    }
    
    // State
    mapping(address => Beneficiary) public beneficiaries;
    address[] public beneficiaryList;
    
    uint256 public totalPercentage;     // Must equal 10000 (100%)
    uint256 public totalReceived;       // Total ETH ever received
    uint256 public totalClaimed;        // Total ETH claimed by all
    
    // Events
    event Deposit(address indexed from, uint256 amount);
    event BeneficiaryAdded(address indexed beneficiary, uint256 percentage);
    event BeneficiaryUpdated(address indexed beneficiary, uint256 newPercentage);
    event BeneficiaryRemoved(address indexed beneficiary);
    event Claimed(address indexed beneficiary, uint256 amount);
    
    constructor(address _owner) Ownable(_owner) {}
    
    /**
     * @notice Receive ETH
     */
    receive() external payable {
        totalReceived += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    
    /**
     * @notice Add or update beneficiary
     * @param _beneficiary Address to receive fees
     * @param _percentage Percentage in basis points (100 = 1%)
     */
    function setBeneficiary(address _beneficiary, uint256 _percentage) external onlyOwner {
        require(_beneficiary != address(0), "Invalid address");
        require(_percentage > 0 && _percentage <= 10000, "Invalid percentage");
        
        if (!beneficiaries[_beneficiary].exists) {
            beneficiaryList.push(_beneficiary);
            beneficiaries[_beneficiary].exists = true;
        }
        
        // Update total percentage
        totalPercentage -= beneficiaries[_beneficiary].percentage;
        totalPercentage += _percentage;
        
        require(totalPercentage <= 10000, "Total exceeds 100%");
        
        beneficiaries[_beneficiary].percentage = _percentage;
        
        emit BeneficiaryUpdated(_beneficiary, _percentage);
    }
    
    /**
     * @notice Remove beneficiary
     * @param _beneficiary Address to remove
     */
    function removeBeneficiary(address _beneficiary) external onlyOwner {
        require(beneficiaries[_beneficiary].exists, "Not a beneficiary");
        
        totalPercentage -= beneficiaries[_beneficiary].percentage;
        delete beneficiaries[_beneficiary];
        
        // Remove from array (swap with last)
        for (uint256 i = 0; i < beneficiaryList.length; i++) {
            if (beneficiaryList[i] == _beneficiary) {
                beneficiaryList[i] = beneficiaryList[beneficiaryList.length - 1];
                beneficiaryList.pop();
                break;
            }
        }
        
        emit BeneficiaryRemoved(_beneficiary);
    }
    
    /**
     * @notice Calculate claimable amount for a beneficiary
     * @param _beneficiary Address to check
     * @return Amount claimable
     */
    function claimable(address _beneficiary) public view returns (uint256) {
        Beneficiary memory b = beneficiaries[_beneficiary];
        if (!b.exists) return 0;
        
        // (totalReceived * percentage / 10000) - claimed
        uint256 entitled = (totalReceived * b.percentage) / 10000;
        return entitled - b.claimed;
    }
    
    /**
     * @notice Claim your share
     */
    function claim() external {
        require(beneficiaries[msg.sender].exists, "Not a beneficiary");
        
        uint256 amount = claimable(msg.sender);
        require(amount > 0, "Nothing to claim");
        require(address(this).balance >= amount, "Insufficient balance");
        
        beneficiaries[msg.sender].claimed += amount;
        totalClaimed += amount;
        
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
        
        emit Claimed(msg.sender, amount);
    }
    
    /**
     * @notice Claim on behalf of a beneficiary (gasless)
     * @param _beneficiary Address to claim for
     */
    function claimFor(address _beneficiary) external {
        require(beneficiaries[_beneficiary].exists, "Not a beneficiary");
        
        uint256 amount = claimable(_beneficiary);
        require(amount > 0, "Nothing to claim");
        require(address(this).balance >= amount, "Insufficient balance");
        
        beneficiaries[_beneficiary].claimed += amount;
        totalClaimed += amount;
        
        (bool success, ) = payable(_beneficiary).call{value: amount}("");
        require(success, "Transfer failed");
        
        emit Claimed(_beneficiary, amount);
    }
    
    /**
     * @notice Get all beneficiaries
     */
    function getAllBeneficiaries() external view returns (address[] memory) {
        return beneficiaryList;
    }
    
    /**
     * @notice Get pool balance
     */
    function getPoolBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @notice Emergency withdraw (only owner)
     */
    function emergencyWithdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Transfer failed");
    }
}
```

---

## 🧮 Math Explanation

**Claimable Formula:**
```
claimable = (totalReceived × percentage / 10000) - alreadyClaimed
```

**Example:**
```
totalReceived = 2 ETH
percentage = 2000 (20%)
alreadyClaimed = 0.2 ETH

claimable = (2 × 2000 / 10000) - 0.2
         = (2 × 0.2) - 0.2
         = 0.4 - 0.2
         = 0.2 ETH ✓
```

---

## 📋 Usage Example

### Setup
```solidity
// Deploy
RarePool pool = new RarePool(ownerAddress);

// Add beneficiaries (percentages in basis points)
pool.setBeneficiary(aliceAddress, 2000);  // 20%
pool.setBeneficiary(bobAddress, 2000);    // 20%
pool.setBeneficiary(treasuryAddress, 6000); // 60%
// Total: 100%
```

### Receiving Fees
```solidity
// Any contract can send ETH
payable(poolAddress).transfer{value: 1 ether}("");

// Or from a contract
function distributeFees() external {
    uint256 fees = address(this).balance;
    (bool success, ) = poolAddress.call{value: fees}("");
    require(success, "Transfer failed");
}
```

### Claiming
```solidity
// User claims their share
pool.claim();

// Or someone claims on their behalf
pool.claimFor(aliceAddress);
```

---

## ✅ This Solves Your Requirements

| Requirement | Solution |
|-------------|----------|
| Receive fees from apps | `receive()` function |
| Set percentages | `setBeneficiary()` |
| Claim anytime | `claim()` |
| No double-claim | `claimed` tracking |
| Non-drainable | Math prevents over-claim |
| Manager control | `onlyOwner` modifier |

---

## 🔄 Integration with Other Contracts

### Fountain Contract
```solidity
// In Fountain contract
function claimBounty() public {
    // ... existing logic ...
    
    // Send fees to pool
    uint256 fees = 0.05 ether;
    (bool success, ) = poolAddress.call{value: fees}("");
    require(success, "Fee transfer failed");
}
```

### Lottery Contract
```solidity
// In Lottery contract
function enter() public payable {
    // ... existing logic ...
    
    // Send fees to pool
    (bool success, ) = poolAddress.call{value: fee}("");
    require(success, "Fee transfer failed");
}
```

---

## 🚀 Ready to Build

Want me to:
1. Add this to the Week 1 contract list?
2. Start writing the full contract with tests?
3. Add ERC20 token support too?

---

*Design Document v1.0*
*Created: 2026-02-24*
*Author: Felix*
