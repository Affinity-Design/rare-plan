# Bot-Proofing Strategy - Rare Coin

## Problem Summary

Original Rare Coin failed because:
- Bots registered 100+ addresses
- Bots claimed every day automatically
- Real humans got crumbs or nothing
- Distribution was gamed, not fair

---

## Stake-to-Claim Explained

**Concept:** Require users to lock up some amount of RARE (or a small amount of ETH/USDC) to register for claiming.

**How it works:**
1. User wants to register for distribution
2. Must stake X RARE tokens (e.g., 100 RARE) to qualify
3. Staked tokens are locked until claim period
4. After claim, staked tokens are RETURNED + earned claim reward
5. Staking serves as "skin in the game"

**Why it stops bots:**
- Economic barrier: If you have 1,000 bot addresses, you'd need to stake 100,000 RARE across all of them
- Single claim reward < stake cost → bot farming loses money
- Real users only need 1-2 addresses to claim
- Returns to normal users, not bots

**Variation:**
- **Small ETH/USDC stake** instead of RARE (e.g., $1-2 USD)
- Returned after claim period completes
- Acts as "anti-sybil fee" without permanently costing users money

---

## Recommended Solution: Multi-Layer Defense

### Layer 1: Cloudflare Turnstile (Frontend)
**Purpose:** Catch basic bots before they hit the contract

**Implementation:**
- Add Turnstile widget to registration form
- User must solve challenge before being allowed to register
- Verify on backend before allowing contract interaction

**Pros:**
- Free (up to 1M requests/month)
- Privacy-focused (better than reCAPTCHA)
- Passes for humans, blocks 90%+ of bots
- Fast, no CAPTCHA images

**Cons:**
- Sophisticated bots can bypass
- Doesn't prevent humans creating multiple accounts

---

### Layer 2: Stake-to-Claim (Contract Level)
**Purpose:** Make bot farming economically unattractive

**Implementation:**

```solidity
// Add to rare-fountain contract
uint256 public claimStakeRequirement = 100 * 10**18; // 100 RARE
mapping(address => uint256) public stakedAmount;
mapping(address => bool) public hasStaked;

function stakeForClaim() public payable {
    require(!hasStaked[msg.sender], "Already staked");
    require(
        msg.value >= 0.001 ether || // Small ETH stake
        erc20Token.transferFrom(msg.sender, address(this), claimStakeRequirement),
        "Stake amount too low"
    );
    
    stakedAmount[msg.sender] = msg.value > 0 ? msg.value : claimStakeRequirement;
    hasStaked[msg.sender] = true;
    
    // Now allow registration
    // ...
}

function returnStake() public {
    require(hasStaked[msg.sender], "No stake to return");
    require(claimCompleted, "Claim period not over");
    
    hasStaked[msg.sender] = false;
    
    if (isEthStake) {
        payable(msg.sender).transfer(stakedAmount[msg.sender]);
    } else {
        erc20Token.transfer(msg.sender, stakedAmount[msg.sender]);
    }
}
```

**Pros:**
- Economic barrier to bot farming
- Doesn't permanently cost real users
- Stakes are returned after claim
- Easy to tune (adjust stake amount based on claim reward)

**Cons:**
- Adds complexity to contract
- Need to handle stake returns correctly
- Requires users to have funds to stake

---

### Layer 3: Time-Based Rate Limiting (Contract Level)
**Purpose:** Prevent rapid-fire multiple registrations

**Implementation:**

```solidity
mapping(address => uint256) public lastRegistrationTime;
uint256 public registrationCooldown = 24 hours;

function register() public {
    require(
        block.timestamp >= lastRegistrationTime[msg.sender] + registrationCooldown,
        "Must wait 24h between registrations"
    );
    lastRegistrationTime[msg.sender] = block.timestamp;
    // ... rest of registration logic
}
```

**Pros:**
- Simple to implement
- Prevents same-day multiple registrations
- Doesn't affect normal users

**Cons:**
- Doesn't prevent multiple accounts created over time
- Sophisticated bots can still game it

---

### Layer 4: Claim Window Randomization (Contract Level)
**Purpose:** Make automated timing harder

**Implementation:**

```solidity
// Instead of fixed 24h cycles
uint256 public randomWindow = 22 hours + random(0, 4 hours);

// Claims only open during randomized window
bool public claimWindowOpen;

function openClaimWindow() public {
    require(blockTarget >= block.number, "Not time yet");
    claimWindowOpen = true;
    
    // Random window 2-4 hours
    uint256 window = 2 hours + (blockhash(block.number) % 2 hours);
    
    // Close after window
    uint256 closeTime = block.timestamp + window;
    // ... scheduler logic
}

function claim() public {
    require(claimWindowOpen, "Claim window not open");
    // ... claim logic
}
```

**Pros:**
- Makes bot timing unpredictable
- Humans can still claim within window
- Adds fairness (fastest isn't always winner)

**Cons:**
- Adds complexity
- Could frustrate users if windows are too short

---

## BrightID Replacement Options

Since BrightID "sucks", here are alternatives:

### 1. Gitcoin Passport
- Score-based identity verification
- Multiple verification methods (social, ENS, etc.)
- Used by many DeFi protocols
- **Cons:** Can be gamed, requires setup

### 2. Proof of Humanity
- Human-verified DAO
- Video verification
- **Cons:** Slow, controversial

### 3. World ID (Worldcoin)
- Biometric iris scanning
- **Cons:** Privacy concerns, hardware requirement

### 4. Simple Sybil Resistance (Recommended)
Skip identity, use economic barriers:
- Stake-to-Claim (primary)
- Turnstile (secondary)
- Small registration fee (burned or redistributed)
- **Pros:** Simple, effective, works immediately

---

## Final Recommendation

**Use these 3 layers:**

1. **Cloudflare Turnstile** - Frontend protection
2. **Stake-to-Claim** - Economic barrier (100 RARE or $1 ETH)
3. **24h Rate Limiting** - Prevent rapid-fire abuse

**Skip:**
- ❌ BrightID (you don't want it)
- ❌ Complex identity verification (unnecessary friction)
- ❌ Randomized claim windows (adds UX pain)

**Math Check:**
- If claim reward = ~10 RARE/day
- If stake requirement = 100 RARE
- Bot needs 10 days of claiming to break even
- Normal users claim indefinitely → profit
- Bot farmers can't make money quickly

---

## Implementation Order

1. **Contract Layer:**
   - Add stake-to-claim logic
   - Add 24h rate limiting
   - Update `register()` function
   - Add `returnStake()` function

2. **Frontend Layer:**
   - Add Cloudflare Turnstile widget
   - Update registration form
   - Add stake amount UI
   - Show stake return status

3. **Testing:**
   - Test on testnet with automated bot
   - Verify stake returns work
   - Check Turnstile passes humans

4. **Audit:**
   - Get smart contract audit after changes
   - Security review of staking logic

---
