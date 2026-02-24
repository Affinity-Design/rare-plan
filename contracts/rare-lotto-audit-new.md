# Rare Lotto Contract Audit

## Contract Overview

**File:** Rare Lotto
**Solidity:** >=0.6.0 <0.8.0
**Purpose:** Lottery system with ticket purchases and winner selection
**Dependencies:** SafeMath, Allerc20, external Random contract

---

## 🔴 CRITICAL ISSUES

### 1. Reentrancy Vulnerability in pickWinner()
```solidity
function pickWinner() public blk {
    random.useSeed();
    uint seed = getSeed();
    uint i = seed % players.length;
    
    uint rareRefund = gambler[msg.sender].amt;
    uint winnerAmt = rare.balanceOf(address(this)).sub(rareRefund);
    
    // VULNERABLE: External transfer BEFORE state reset
    rare.transfer(payable(players[i]), winnerAmt);
    
    // State still not reset - reentrancy possible!
    lastWinner = players[i];
    emit NewWinner(players[i],rare.balanceOf(address(this)),drawCount);
    
    // State reset AFTER transfer
    players = new address[](0);
    drawCount = uint16(drawCount.add(1));
}
```

**Attack Vector:**
1. Winner's fallback function re-enters during transfer
2. Can call pickWinner() again before players array is reset
3. Drains contract

### 2. Randomness Depends on External Contract
```solidity
Rnd private random; // External random contract

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

**Issues:**
- Randomness depends on external contract at `0x326225AEEa3D45435A53e9Dd801A6Ee8155006e5`
- If this contract is manipulable, lottery can be rigged
- Need to audit the random contract separately

**Recommendation:** Use Chainlink VRF for verifiable randomness

### 3. No Minimum Players
```solidity
function pickWinner() public blk {
    uint i = seed % players.length;  // Could be 1 player
```
**Issue:** Lottery can be drawn with 1 player

**Fix:**
```solidity
require(players.length >= 3, "Need at least 3 players");
```

### 4. No Bot Protection
**Issue:** Anyone can buy unlimited tickets

**Fix:** Limit tickets per address

### 5. Solidity 0.6.x
**Issue:** No built-in overflow protection

### 6. Manager Can Drain via Fees
```solidity
manager.transfer(fee);  // In enter()
msg.sender.transfer(address(this).balance);  // In pickWinner()
```
**Issue:** High fees (up to 50 ETH) can be set by manager

---

## 🟡 MEDIUM ISSUES

### 7. Bounty Hunter Gets Refund
```solidity
function pickWinner() public blk {
    uint rareRefund = gambler[msg.sender].amt;  // Bounty hunter's entry
    // ...
    rare.transfer(payable(msg.sender), rareRefund);  // Returns their tickets
    msg.sender.transfer(address(this).balance);  // Returns all ETH
}
```
**Issue:** Bounty hunter gets all remaining ETH (fees paid by players)

### 8. Luck Calculation Overflow Risk
```solidity
function getLuck() public view returns (uint) {
    require((gambler[msg.sender].timesEntered.mul(1000000)).div(getPlayersNum()) >= 1, "...");
    return (gambler[msg.sender].timesEntered.mul(1000000)).div(getPlayersNum());
}
```
**Issue:** Multiplication before division can overflow

### 9. No Events for Entry
**Issue:** No event emitted when player enters lottery

**Fix:**
```solidity
event LotteryEntry(address indexed player, uint256 amount);
```

### 10. Array Gas Cost
```solidity
players.push(msg.sender);  // Unbounded array
```
**Issue:** With many players, array operations get expensive

### 11. No Pause Function
**Issue:** Cannot stop lottery if bug found

---

## 🔍 RANDOM CONTRACT ANALYSIS

The lottery depends on an external random contract at:
`0x326225AEEa3D45435A53e9Dd801A6Ee8155006e5`

**Functions used:**
- `seedUp()` - Returns upper seed value
- `seedDw()` - Returns lower seed value  
- `useSeed()` - Called before getting seed

**Concerns:**
- Cannot verify randomness without auditing this contract
- If seeds are predictable, lottery is exploitable
- `useSeed()` suggests state changes that could be front-run

**Recommendation:** Replace with Chainlink VRF

---

## 📋 LOTTERY MECHANICS ANALYSIS

**How it works:**
1. Players call `enter()` and pay RARE + ETH fee
2. Tickets accumulate until pot reaches `target`
3. Anyone can call `pickWinner()` when pot > target
4. Winner gets pot, bounty hunter gets fees

**Fee Structure:**
- `fee` = 1 ETH (goes to manager)
- `btnReward` = 0.5 ETH (goes to bounty hunter)
- `price` = 0.001 RARE per ticket

**Issues with current design:**
- Fees are very high (1.5 ETH per entry)
- No maximum tickets per player
- No minimum pot before drawing

---

## 🔧 REQUIRED FIXES

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract RareLotto is ReentrancyGuard, Pausable, VRFConsumerBase {
    // Chainlink VRF
    bytes32 internal keyHash;
    uint256 internal fee;
    
    // Limits
    uint256 public constant MIN_PLAYERS = 3;
    uint256 public constant MAX_TICKETS_PER_ADDRESS = 100;
    
    // State
    address[] private players;
    mapping(address => uint256) public ticketsPerPlayer;
    
    function enter() public payable nonReentrant whenNotPaused {
        require(msg.value >= fee, "Insufficient fee");
        require(ticketsPerPlayer[msg.sender] < MAX_TICKETS_PER_ADDRESS, "Too many tickets");
        
        // Update state FIRST
        players.push(msg.sender);
        ticketsPerPlayer[msg.sender]++;
        
        // Then external calls
        rare.transferFrom(msg.sender, address(this), price);
        
        emit LotteryEntry(msg.sender, price);
    }
    
    function pickWinner() public nonReentrant whenNotPaused {
        require(players.length >= MIN_PLAYERS, "Not enough players");
        
        // Request random number from Chainlink VRF
        requestRandomness(keyHash, fee);
    }
    
    // Chainlink callback
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        uint256 winnerIndex = randomness % players.length;
        address winner = players[winnerIndex];
        
        // Update state FIRST
        uint256 prize = rare.balanceOf(address(this));
        players = new address[](0);
        for (all players) ticketsPerPlayer[player] = 0;
        
        // Then transfer
        rare.transfer(winner, prize);
        
        emit NewWinner(winner, prize, drawCount);
    }
}
```

---

## SUMMARY

| Issue | Severity | Fix Required |
|-------|----------|--------------|
| Reentrancy in pickWinner() | 🔴 Critical | Yes |
| External randomness untrusted | 🔴 Critical | Yes |
| No minimum players | 🔴 Critical | Yes |
| No bot protection | 🔴 Critical | Yes |
| Solidity 0.6.x | 🔴 Critical | Yes |
| High fees | 🟡 Medium | Review |
| No entry event | 🟡 Medium | Yes |
| No pause | 🟡 Medium | Yes |

---

## 🎯 RECOMMENDATION

**Complete rewrite required:**
1. Upgrade to Solidity 0.8.20
2. Use Chainlink VRF for randomness
3. Add ReentrancyGuard
4. Add minimum players
5. Add ticket limits
6. Reduce fees

---

*Audit completed: 2026-02-24*
