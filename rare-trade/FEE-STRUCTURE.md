# Rare Trade - Fee Structure

> Flexible, configurable fees that scale with RARE price
> Mix of RARE + ETH for sustainability

---

## Current State Analysis

### RARE Token Context
- **Daily Distribution**: 200 RARE/day via claims
- **Circulating Supply**: ~560,000 RARE
- **Price Scenarios**:
  - At $0.10: 500 RARE = $50/mo ✅
  - At $0.50: 500 RARE = $250/mo ⚠️
  - At $1.00: 500 RARE = $500/mo ❌ Too steep
  - At $5.00: 500 RARE = $2,500/mo ❌ Impossible

### Design Goals
1. **Affordable**: Target ~$20-50/month for basic users
2. **Sustainable**: Generate real revenue in ETH/stablecoins
3. **Configurable**: Adjustable via governance/contract
4. **Hybrid**: Mix RARE (utility) + ETH (revenue)

---

## Proposed Fee Structure

### Option A: Hybrid RARE + ETH (Recommended)

```yaml
# Bot Subscription (Monthly)
bot_tiers:
  paper:
    rare: 0
    eth: 0
    features: "Simulation only"
    
  basic:
    rare: 50          # $5-50 depending on price
    eth: 0.005        # ~$15 at 3k ETH
    total_usd: "~$20-65/mo"
    features: "1 bot, public, basic strategies"
    
  pro:
    rare: 100         # $10-100 depending on price
    eth: 0.01         # ~$30 at 3k ETH
    total_usd: "~$40-130/mo"
    features: "3 bots, private option, all strategies"
    
  whale:
    rare: 250         # $25-250 depending on price
    eth: 0.025        # ~$75 at 3k ETH
    total_usd: "~$100-325/mo"
    features: "Unlimited bots, API access, priority"

# Per-Action Fees (Small, in ETH)
action_fees:
  trade_execution: 0.0001 ETH    # ~$0.30 per trade
  copy_strategy: 0.002 ETH       # ~$6 one-time
  skill_purchase: 0.001 ETH      # ~$3 per skill
  
# Royalty Split (On Profits)
royalties:
  creator_share: 10%             # In RARE
  platform_share: 5%             # In ETH equivalent
  sub_copier: 5%                 # In RARE
```

### Option B: Dynamic RARE Pricing

```yaml
# USD-pegged RARE fees (via oracle)
pricing:
  target_monthly_usd:
    basic: $25
    pro: $75
    whale: $200
    
  rare_amount:
    # Calculated at payment time
    formula: "target_usd / rare_price_usd"
    min_rare: 10      # Floor amount
    max_rare: 500     # Cap amount
    
  example:
    at_0.10_rare:
      basic: 250 RARE ($25)
      pro: 750 RARE ($75)
    at_0.50_rare:
      basic: 50 RARE ($25)
      pro: 150 RARE ($75)
    at_1.00_rare:
      basic: 25 RARE ($25)
      pro: 75 RARE ($75)
    at_5.00_rare:
      basic: 10 RARE ($50, floored)
      pro: 40 RARE ($200)
```

### Option C: Credit System (Most Flexible)

```yaml
# Buy credits with RARE or ETH
credits:
  purchase:
    100_credits: 50 RARE or 0.005 ETH
    500_credits: 200 RARE or 0.02 ETH
    2000_credits: 700 RARE or 0.07 ETH
    
  usage:
    bot_monthly: 100 credits
    trade_execution: 1 credit
    copy_strategy: 50 credits
    skill_purchase: 20 credits
    
  benefits:
    - Pay with RARE OR ETH (user choice)
    - Bulk discounts
    - Never expires
    - Transferable
```

---

## Recommended: Hybrid Model (Option A Enhanced)

### Fee Schedule

| Tier | RARE/mo | ETH/mo | USD Est. | Features |
|------|---------|--------|----------|----------|
| **Paper** | 0 | 0 | Free | Simulation only |
| **Basic** | 50 | 0.005 | ~$20-65 | 1 bot, public |
| **Pro** | 100 | 0.01 | ~$40-130 | 3 bots, private |
| **Whale** | 250 | 0.025 | ~$100-325 | Unlimited, API |

### Per-Action Fees (ETH)

| Action | ETH Fee | USD Est. | Notes |
|--------|---------|----------|-------|
| Trade execute | 0.0001 | ~$0.30 | Covers gas + revenue |
| Copy strategy | 0.002 | ~$6 | One-time copy fee |
| Skill buy | 0.001 | ~$3 | Per skill purchase |
| Withdraw | 0.0005 | ~$1.50 | Security fee |

### Revenue Split

```
ALL Revenue → Rare Pool Treasury:
├── 100% RARE subscriptions → Rare Pool
├── 100% ETH subscriptions → Rare Pool  
├── 100% Action fees → Rare Pool
├── 100% Royalties → Rare Pool
└── 100% Marketplace fees → Rare Pool

Distribution (Managed by Rare Pool):
├── Airdrops to holders
├── Reward cycles
├── Buyback & burn
├── Development fund
├── Operations
└── Staking rewards

Note: All profits collected centrally.
      Distribution happens via Rare Pool cycles
      as determined by governance/team.
```

---

## Smart Contract Configuration

### FeeSettings.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FeeSettings {
    address public owner;
    address public treasury;
    
    // Subscription tiers
    struct Tier {
        uint256 rareAmount;      // RARE per month (wei)
        uint256 ethAmount;       // ETH per month (wei)
        uint256 maxBots;
        bool canPrivate;
        bool apiAccess;
    }
    
    mapping(string => Tier) public tiers;
    
    // Per-action fees (in ETH)
    mapping(bytes32 => uint256) public actionFees;
    
    // Events
    event TierUpdated(string tierName, Tier tier);
    event ActionFeeUpdated(bytes32 action, uint256 fee);
    
    constructor() {
        owner = msg.sender;
        treasury = msg.sender;
        
        // Initialize tiers
        tiers["basic"] = Tier({
            rareAmount: 50 * 1e18,    // 50 RARE
            ethAmount: 0.005 ether,   // 0.005 ETH
            maxBots: 1,
            canPrivate: false,
            apiAccess: false
        });
        
        tiers["pro"] = Tier({
            rareAmount: 100 * 1e18,
            ethAmount: 0.01 ether,
            maxBots: 3,
            canPrivate: true,
            apiAccess: false
        });
        
        tiers["whale"] = Tier({
            rareAmount: 250 * 1e18,
            ethAmount: 0.025 ether,
            maxBots: 100,
            canPrivate: true,
            apiAccess: true
        });
        
        // Initialize action fees
        actionFees["TRADE"] = 0.0001 ether;
        actionFees["COPY"] = 0.002 ether;
        actionFees["SKILL"] = 0.001 ether;
        actionFees["WITHDRAW"] = 0.0005 ether;
    }
    
    // Admin functions
    function updateTier(string calldata name, Tier calldata tier) external onlyOwner {
        tiers[name] = tier;
        emit TierUpdated(name, tier);
    }
    
    function updateActionFee(bytes32 action, uint256 fee) external onlyOwner {
        actionFees[action] = fee;
        emit ActionFeeUpdated(action, fee);
    }
    
    function getTierCost(string calldata name) external view returns (uint256 rare, uint256 eth) {
        Tier memory tier = tiers[name];
        return (tier.rareAmount, tier.ethAmount);
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}
```

### SubscriptionManager.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./FeeSettings.sol";

contract SubscriptionManager {
    FeeSettings public feeSettings;
    IERC20 public rareToken;
    address public rarePool;  // Central treasury for ALL revenue
    
    struct Subscription {
        string tier;
        uint256 startTime;
        uint256 endTime;
        bool active;
    }
    
    mapping(address => Subscription) public subscriptions;
    
    event Subscribed(address user, string tier, uint256 endTime);
    event SubscriptionExpired(address user);
    event RevenueCollected(address token, uint256 amount);
    
    constructor(address _feeSettings, address _rareToken, address _rarePool) {
        feeSettings = FeeSettings(_feeSettings);
        rareToken = IERC20(_rareToken);
        rarePool = _rarePool;
    }
    
    function subscribe(string calldata tier) external payable {
        (uint256 rareAmount, uint256 ethAmount) = feeSettings.getTierCost(tier);
        
        require(msg.value >= ethAmount, "Insufficient ETH");
        require(rareToken.transferFrom(msg.sender, address(this), rareAmount), "RARE transfer failed");
        
        // Send ALL RARE to Rare Pool
        rareToken.transfer(rarePool, rareAmount);
        emit RevenueCollected(address(rareToken), rareAmount);
        
        // Send ALL ETH to Rare Pool
        (bool success, ) = rarePool.call{value: msg.value}("");
        require(success, "ETH transfer failed");
        emit RevenueCollected(address(0), msg.value);
        
        // Create subscription
        subscriptions[msg.sender] = Subscription({
            tier: tier,
            startTime: block.timestamp,
            endTime: block.timestamp + 30 days,
            active: true
        });
        
        emit Subscribed(msg.sender, tier, block.timestamp + 30 days);
    }
    
    function checkSubscription(address user) external view returns (bool active, string memory tier) {
        Subscription memory sub = subscriptions[user];
        if (block.timestamp > sub.endTime) {
            return (false, sub.tier);
        }
        return (true, sub.tier);
    }
    
    function payActionFee(bytes32 action) external payable {
        uint256 fee = feeSettings.actionFees(action);
        require(msg.value >= fee, "Insufficient fee");
        
        // ALL fees go to Rare Pool
        (bool success, ) = rarePool.call{value: msg.value}("");
        require(success, "Fee transfer failed");
        emit RevenueCollected(address(0), msg.value);
    }
    
    // Emergency functions
    function updateRarePool(address _newPool) external onlyOwner {
        rarePool = _newPool;
    }
    
    modifier onlyOwner() {
        require(msg.sender == feeSettings.owner(), "Not owner");
        _;
    }
}
```

---

## Revenue Projections

### Scenario: 1,000 Active Users

| Tier | Users | RARE/mo | ETH/mo | Revenue |
|------|-------|---------|--------|---------|
| Basic | 600 | 30,000 | 3 ETH | ~$30K + $9K |
| Pro | 300 | 30,000 | 3 ETH | ~$30K + $9K |
| Whale | 100 | 25,000 | 2.5 ETH | ~$25K + $7.5K |
| **Total** | 1,000 | **85,000** | **8.5 ETH** | **~$110K/mo** |

### Per-Action Revenue (1,000 users)

| Action | Daily | ETH/trade | Daily ETH |
|--------|-------|-----------|-----------|
| Trades | 5,000 | 0.0001 | 0.5 ETH |
| Copies | 50 | 0.002 | 0.1 ETH |
| Skills | 100 | 0.001 | 0.1 ETH |
| **Total** | - | - | **0.7 ETH/day** |

### Monthly Summary (1,000 users)

```
Subscription Revenue:
├── RARE: 85,000 tokens → Rare Pool
├── ETH: 8.5 ETH → Rare Pool
└── Total Value: ~$110K/month

Action Fees:
├── ETH: 21 ETH/month → Rare Pool
└── Total Value: ~$63K/month

Total Revenue to Rare Pool: ~$173K/month

Distribution (via Rare Pool cycles):
├── Airdrops to holders
├── Reward distributions
├── Buyback & burn events
├── Development funding
├── Operations
└── As determined by governance
```

---

## Fee Adjustment Mechanism

### Governance-Based Updates

```solidity
// Timelock for fee changes (security)
contract FeeGovernance {
    uint256 public constant DELAY = 2 days;
    
    struct Proposal {
        string tierName;
        FeeSettings.Tier newTier;
        uint256 executeTime;
        bool executed;
    }
    
    mapping(uint256 => Proposal) public proposals;
    
    function proposeFeeChange(
        string calldata tierName,
        FeeSettings.Tier calldata newTier
    ) external onlyGovernance returns (uint256 proposalId) {
        proposalId = ++proposalCount;
        proposals[proposalId] = Proposal({
            tierName: tierName,
            newTier: newTier,
            executeTime: block.timestamp + DELAY,
            executed: false
        });
    }
    
    function executeFeeChange(uint256 proposalId) external {
        Proposal storage p = proposals[proposalId];
        require(block.timestamp >= p.executeTime, "Too early");
        require(!p.executed, "Already executed");
        
        feeSettings.updateTier(p.tierName, p.newTier);
        p.executed = true;
    }
}
```

---

## Summary

### Recommended Fees

| Tier | RARE | ETH | USD Range |
|------|------|-----|-----------|
| Basic | 50 | 0.005 | $20-65 |
| Pro | 100 | 0.01 | $40-130 |
| Whale | 250 | 0.025 | $100-325 |

### Revenue Flow

```
ALL Fees → Rare Pool → Distributed via cycles:
├── Airdrops
├── Rewards
├── Buybacks
├── Development
└── Operations
```

### Next Steps

1. [ ] Finalize fee amounts
2. [ ] Deploy FeeSettings contract
3. [ ] Deploy SubscriptionManager
4. [ ] Add to frontend
5. [ ] Test with paper trading

---

*Fee Structure v1.0*
*Created: 2026-03-02*
*Author: Felix*
