# Fee Management System Design

## Problem

**On xDai:** 1 ETH ≈ 1 USD (stable)
- 0.01 ETH = $0.01
- Easy to price fees

**On Base:** ETH fluctuates
- 1 ETH = $1,500 - $4,000+
- 0.01 ETH = $15 - $40 (way too expensive!)
- Need to adjust fees constantly

---

## Solution: Fee Registry + Price Feed

### Components

1. **FeeRegistry** - Central contract managing all fees
2. **Price Feed** - Chainlink ETH/USD oracle
3. **Fee-aware contracts** - Read fees from registry

---

## 📐 Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    FeeRegistry                          │
│  - ETH/USD price (Chainlink or manual)                  │
│  - Fee amounts in USD cents                             │
│  - Convert USD → ETH for payments                       │
│  - Manager can update anytime                           │
└─────────────────────────────────────────────────────────┘
                          │
                          │ read fees
                          ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│  Fountain   │  │   Lotto     │  │   Staking   │
│  (claims)   │  │  (tickets)  │  │   (entry)   │
└─────────────┘  └─────────────┘  └─────────────┘
```

---

## 💰 Target Fees (USD)

| Action | Target USD | Current (if 1 ETH = $2000) |
|--------|------------|---------------------------|
| **Claim registration** | $0.05 | 0.000025 ETH |
| **Stake entry** | $3.00 | 0.0015 ETH |
| **Stake exit** | $0.00 | Free |
| **Lottery ticket** | $0.50 | 0.00025 ETH |
| **Bounty hunter reward** | Variable | Based on gas |

---

## 🔧 Contract Design

### FeeRegistry.sol

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
    
    // Chainlink ETH/USD price feed
    AggregatorV3Interface public priceFeed;
    
    // Whether to use Chainlink or manual price
    bool public useChainlink = true;
    
    // Manual price (in USD with 8 decimals, matching Chainlink)
    int256 public manualEthPrice = 2000 * 10**8; // $2000 default
    
    // Fee types
    bytes32 public constant CLAIM_FEE = keccak256("CLAIM_FEE");
    bytes32 public constant STAKE_FEE = keccak256("STAKE_FEE");
    bytes32 public constant LOTTERY_FEE = keccak256("LOTTERY_FEE");
    bytes32 public constant REGISTER_FEE = keccak256("REGISTER_FEE");
    
    // Fees in USD cents (100 = $1.00)
    mapping(bytes32 => uint256) public feesInCents;
    
    // Events
    event FeeUpdated(bytes32 indexed feeType, uint256 usdCents);
    event PriceUpdated(int256 ethPrice);
    event ChainlinkToggled(bool useChainlink);
    
    constructor(
        address _priceFeed,  // Base ETH/USD price feed
        address _owner
    ) Ownable(_owner) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        
        // Set default fees (in USD cents)
        feesInCents[CLAIM_FEE] = 5;      // $0.05
        feesInCents[REGISTER_FEE] = 5;   // $0.05
        feesInCents[STAKE_FEE] = 300;    // $3.00
        feesInCents[LOTTERY_FEE] = 50;   // $0.50
    }
    
    /**
     * @notice Get current ETH price in USD (8 decimals)
     */
    function getEthPrice() public view returns (int256) {
        if (useChainlink) {
            (, int256 price, , , ) = priceFeed.latestRoundData();
            require(price > 0, "Invalid price");
            return price;
        } else {
            return manualEthPrice;
        }
    }
    
    /**
     * @notice Convert USD cents to ETH wei
     * @param _usdCents Amount in USD cents (100 = $1.00)
     * @return Amount in ETH wei
     */
    function usdCentsToEthWei(uint256 _usdCents) public view returns (uint256) {
        int256 ethPrice = getEthPrice();
        require(ethPrice > 0, "Invalid ETH price");
        
        // ETH price is in 8 decimals
        // USD cents is in 2 decimals
        // We want ETH wei (18 decimals)
        
        // Formula: (usdCents * 10^16) / ethPrice
        // This gives us ETH wei
        
        return (uint256(_usdCents) * 10**16) / uint256(ethPrice);
    }
    
    /**
     * @notice Get fee amount in ETH wei for a fee type
     * @param _feeType The fee type (CLAIM_FEE, STAKE_FEE, etc.)
     * @return Amount in ETH wei
     */
    function getFeeInEth(bytes32 _feeType) public view returns (uint256) {
        uint256 usdCents = feesInCents[_feeType];
        return usdCentsToEthWei(usdCents);
    }
    
    /**
     * @notice Set fee in USD cents
     * @param _feeType Fee type
     * @param _usdCents Amount in USD cents (100 = $1.00)
     */
    function setFee(bytes32 _feeType, uint256 _usdCents) external onlyOwner {
        feesInCents[_feeType] = _usdCents;
        emit FeeUpdated(_feeType, _usdCents);
    }
    
    /**
     * @notice Set multiple fees at once
     * @param _feeTypes Array of fee types
     * @param _usdCents Array of amounts in USD cents
     */
    function setFees(
        bytes32[] calldata _feeTypes,
        uint256[] calldata _usdCents
    ) external onlyOwner {
        require(_feeTypes.length == _usdCents.length, "Length mismatch");
        
        for (uint256 i = 0; i < _feeTypes.length; i++) {
            feesInCents[_feeTypes[i]] = _usdCents[i];
            emit FeeUpdated(_feeTypes[i], _usdCents[i]);
        }
    }
    
    /**
     * @notice Set manual ETH price (if not using Chainlink)
     * @param _ethPrice ETH price in USD (8 decimals)
     */
    function setManualEthPrice(int256 _ethPrice) external onlyOwner {
        require(_ethPrice > 0, "Invalid price");
        manualEthPrice = _ethPrice;
        emit PriceUpdated(_ethPrice);
    }
    
    /**
     * @notice Toggle between Chainlink and manual price
     * @param _useChainlink Use Chainlink if true
     */
    function setUseChainlink(bool _useChainlink) external onlyOwner {
        useChainlink = _useChainlink;
        emit ChainlinkToggled(_useChainlink);
    }
    
    /**
     * @notice View current fees with ETH equivalent
     */
    function getAllFees() external view returns (
        uint256 claimFeeEth,
        uint256 registerFeeEth,
        uint256 stakeFeeEth,
        uint256 lotteryFeeEth,
        int256 currentEthPrice
    ) {
        claimFeeEth = getFeeInEth(CLAIM_FEE);
        registerFeeEth = getFeeInEth(REGISTER_FEE);
        stakeFeeEth = getFeeInEth(STAKE_FEE);
        lotteryFeeEth = getFeeInEth(LOTTERY_FEE);
        currentEthPrice = getEthPrice();
    }
}
```

---

## 🔗 Integration with Other Contracts

### Fountain Contract Integration

```solidity
import "./FeeRegistry.sol";

contract RareFountainV2 {
    FeeRegistry public feeRegistry;
    
    constructor(address _feeRegistry) {
        feeRegistry = FeeRegistry(_feeRegistry);
    }
    
    function register() external payable {
        uint256 requiredFee = feeRegistry.getFeeInEth(feeRegistry.REGISTER_FEE());
        require(msg.value >= requiredFee, "Insufficient fee");
        
        // ... registration logic ...
    }
}
```

### Staking Contract Integration

```solidity
contract RareStakingV2 {
    FeeRegistry public feeRegistry;
    
    function stake(uint256 _amount) external payable {
        uint256 requiredFee = feeRegistry.getFeeInEth(feeRegistry.STAKE_FEE());
        require(msg.value >= requiredFee, "Insufficient fee");
        
        // ... staking logic ...
    }
}
```

### Lottery Contract Integration

```solidity
contract RareLottoV2 {
    FeeRegistry public feeRegistry;
    
    function enter() external payable {
        uint256 requiredFee = feeRegistry.getFeeInEth(feeRegistry.LOTTERY_FEE());
        require(msg.value >= requiredFee, "Insufficient fee");
        
        // ... lottery entry logic ...
    }
}
```

---

## 📊 Example Calculations

### ETH = $2,000

| Fee Type | USD | ETH Wei | ETH |
|----------|-----|---------|-----|
| Claim | $0.05 | 25,000,000,000,000 | 0.000025 |
| Register | $0.05 | 25,000,000,000,000 | 0.000025 |
| Stake | $3.00 | 1,500,000,000,000,000 | 0.0015 |
| Lottery | $0.50 | 250,000,000,000,000 | 0.00025 |

### ETH = $4,000

| Fee Type | USD | ETH Wei | ETH |
|----------|-----|---------|-----|
| Claim | $0.05 | 12,500,000,000,000 | 0.0000125 |
| Register | $0.05 | 12,500,000,000,000 | 0.0000125 |
| Stake | $3.00 | 750,000,000,000,000 | 0.00075 |
| Lottery | $0.50 | 125,000,000,000,000 | 0.000125 |

**Note:** As ETH price goes UP, ETH amount goes DOWN (same USD value)

---

## 🔄 Price Feed Options

### Option A: Chainlink (Recommended)
- **Base ETH/USD:** `0x71041dddad3595F9CEd3DcCFBe3D1F4b0a16B709`
- Automatic updates
- Decentralized
- Free to read

### Option B: Manual Updates
- Manager sets price
- Update when ETH moves >10%
- Centralized but free

### Option C: Hybrid
- Chainlink primary
- Manual fallback if Chainlink fails
- Best of both

---

## 📋 Manager Controls

| Function | What it does |
|----------|--------------|
| `setFee(type, cents)` | Set fee in USD cents |
| `setFees(types[], cents[])` | Set multiple fees at once |
| `setManualEthPrice(price)` | Set ETH price manually |
| `setUseChainlink(true/false)` | Toggle price source |

---

## ✅ Benefits

| Benefit | How |
|---------|-----|
| **Stable fees** | Always ~$0.05 per claim |
| **Manager control** | Adjust fees anytime |
| **No overcharging** | ETH amount adjusts automatically |
| **Transparent** | Users can see USD equivalent |
| **Simple integration** | One line in each contract |

---

## 📁 Files to Create

1. `FeeRegistry.sol` - Central fee management
2. `interfaces/IFeeRegistry.sol` - Interface for other contracts
3. Update all contracts to read from FeeRegistry

---

## 🚀 Ready to Build

Want me to:
1. Add FeeRegistry to Week 1 contracts?
2. Write the full contract?
3. Update other contract designs to use it?

---

*Fee Management System v1.0*
*Created: 2026-02-24*
*Author: Felix*
