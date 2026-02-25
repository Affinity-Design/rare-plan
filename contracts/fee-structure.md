# Fee Structure - Updated

## Overview

| Action | Fee Type | Amount | Goes To |
|--------|----------|--------|---------|
| **Claim Registration** | ETH | $0.05 | RarePool |
| **Stake Entry** | ETH | $3-5 | RarePool |
| **Stake Exit** | None | $0 | — |
| **Lottery Ticket** | RARE tokens | Price set by manager | Lottery Pot |
| **Swap** | Spread | ~0.3% | RarePool |

---

## 💰 Fee Breakdown

### 1. Claim Registration
- **Fee:** $0.05 USD in ETH
- **Purpose:** Cover gas + anti-bot
- **Goes to:** RarePool (distributed to beneficiaries)

### 2. Stake Entry
- **Fee:** $3-5 USD in ETH
- **Purpose:** Cover gas + stake-to-claim enforcement
- **Goes to:** RarePool (distributed to beneficiaries)

### 3. Lottery Ticket
- **Fee:** None (in ETH)
- **Ticket Price:** X RARE tokens (set by manager)
- **Goes to:** Lottery pot (winner takes all)
- **Note:** No ETH fee, just RARE for the pot

### 4. Swap
- **Fee:** ~0.3% spread
- **Purpose:** Liquidity + operations
- **Goes to:** RarePool

---

## 📐 Updated Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                       FeeRegistry                           │
│  - ETH/USD price (Chainlink)                                │
│  - Claim fee: $0.05 USD                                     │
│  - Stake fee: $3-5 USD                                      │
│  - Lottery ticket price: X RARE (not ETH)                   │
└─────────────────────────────────────────────────────────────┘
                          │
            ┌─────────────┼─────────────┐
            │             │             │
            ▼             ▼             ▼
     ┌──────────┐  ┌──────────┐  ┌──────────┐
     │ Fountain │  │ Staking  │  │  Lotto   │
     │$0.05 ETH │  │$3-5 ETH  │  │RARE only │
     └────┬─────┘  └────┬─────┘  └────┬─────┘
          │             │             │
          └──────┬──────┘             │
                 │                    │
                 ▼                    ▼
          ┌─────────────┐      ┌─────────────┐
          │  RarePool   │      │ Lottery Pot │
          │(beneficiaries)│     │  (winner)   │
          └─────────────┘      └─────────────┘
```

---

## 🔧 Updated FeeRegistry

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title FeeRegistry
 * @notice Central fee management with USD → ETH conversion
 */
contract FeeRegistry is Ownable {
    
    AggregatorV3Interface public priceFeed;
    bool public useChainlink = true;
    int256 public manualEthPrice = 2000 * 10**8;
    
    // Fee types (in USD cents)
    bytes32 public constant CLAIM_FEE = keccak256("CLAIM_FEE");
    bytes32 public constant STAKE_FEE = keccak256("STAKE_FEE");
    // Note: No LOTTERY_FEE - tickets are paid in RARE, not ETH
    
    mapping(bytes32 => uint256) public feesInCents;
    
    // Lottery config (in RARE tokens, not ETH)
    uint256 public lotteryTicketPrice = 0.001 * 10**18; // 0.001 RARE
    uint256 public lotteryTarget = 10 * 10**18;         // 10 RARE to draw
    
    event FeeUpdated(bytes32 indexed feeType, uint256 usdCents);
    event LotteryConfigUpdated(uint256 ticketPrice, uint256 target);
    
    constructor(address _priceFeed, address _owner) Ownable(_owner) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        
        // Default fees in USD cents
        feesInCents[CLAIM_FEE] = 5;     // $0.05
        feesInCents[STAKE_FEE] = 300;   // $3.00 (can be 300-500)
    }
    
    function getEthPrice() public view returns (int256) {
        if (useChainlink) {
            (, int256 price, , , ) = priceFeed.latestRoundData();
            require(price > 0, "Invalid price");
            return price;
        }
        return manualEthPrice;
    }
    
    function usdCentsToEthWei(uint256 _usdCents) public view returns (uint256) {
        int256 ethPrice = getEthPrice();
        require(ethPrice > 0, "Invalid ETH price");
        return (uint256(_usdCents) * 10**16) / uint256(ethPrice);
    }
    
    function getFeeInEth(bytes32 _feeType) public view returns (uint256) {
        return usdCentsToEthWei(feesInCents[_feeType]);
    }
    
    function setFee(bytes32 _feeType, uint256 _usdCents) external onlyOwner {
        feesInCents[_feeType] = _usdCents;
        emit FeeUpdated(_feeType, _usdCents);
    }
    
    function setLotteryConfig(
        uint256 _ticketPrice,
        uint256 _target
    ) external onlyOwner {
        lotteryTicketPrice = _ticketPrice;
        lotteryTarget = _target;
        emit LotteryConfigUpdated(_ticketPrice, _target);
    }
    
    function setManualEthPrice(int256 _ethPrice) external onlyOwner {
        require(_ethPrice > 0, "Invalid price");
        manualEthPrice = _ethPrice;
    }
    
    function setUseChainlink(bool _useChainlink) external onlyOwner {
        useChainlink = _useChainlink;
    }
}
```

---

## 📋 Fee Summary

### ETH Fees (to RarePool)

| Action | USD | ETH (at $2000) | ETH (at $4000) |
|--------|-----|----------------|----------------|
| Claim | $0.05 | 0.000025 | 0.0000125 |
| Stake | $3.00 | 0.0015 | 0.00075 |
| Stake (max) | $5.00 | 0.0025 | 0.00125 |

### RARE Fees (to Lottery Pot)

| Action | Amount |
|--------|--------|
| Lottery Ticket | 0.001 RARE (adjustable) |
| Lottery Target | 10 RARE to draw |

---

## ✅ Updated Understanding

- **Claim:** ETH fee → RarePool
- **Stake:** ETH fee → RarePool  
- **Lottery:** RARE ticket price → Lottery pot (winner)
- **No ETH fee for lottery**

---

*Fee Structure v2.0*
*Updated: 2026-02-24*
