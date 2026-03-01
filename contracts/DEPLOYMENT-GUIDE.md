# V3 Contract Deployment Guide - Base Sepolia Testnet

> Step-by-step deployment of Rare Coin V3 contracts to Base Sepolia

---

## 📋 Prerequisites

### 1. Wallet Setup
- MetaMask with ETH on Base Sepolia
- Get testnet ETH: https://faucets.base.org/

### 2. Base Sepolia Network
```
Network Name: Base Sepolia
Chain ID: 84532
RPC URL: https://sepolia.base.org
Currency Symbol: ETH
Block Explorer: https://sepolia.basescan.org
```

### 3. Required Addresses (Base Sepolia)

| Contract | Address |
|----------|---------|
| **Chainlink ETH/USD** | `0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc88cb` |
| **Basename Registry** | `0x4d9142056d960606E7f7f8f7b4f8b7e4C8d9b4f8` *(placeholder - TBD)* |

---

## 🚀 Deployment Order

Deploy in this order due to dependencies:

```
1. RareTokenV3
   └─ No dependencies

2. RareLotteryV3
   └─ Depends on: RareTokenV3

3. RareStakingV3
   └─ Depends on: RareTokenV3, LP Token (use RareToken as placeholder), Chainlink

4. RareFountainV3
   └─ Depends on: RareTokenV3, Staking, Lottery, Basename, Chainlink
```

---

## 📝 Deployment via Remix

### Step 1: Prepare Remix

1. Open https://remix.ethereum.org/
2. Create folder `rare-v3/`
3. Upload all 4 contract files
4. Install dependencies via `npm` in Remix terminal:
   ```bash
   npm install @openzeppelin/contracts @chainlink/contracts
   ```

### Step 2: Deploy RareTokenV3

**Compiler Settings:**
- Version: `0.8.20`
- Optimizer: Enabled, 200 runs

**Constructor Arguments:**
```javascript
[
  "0x0000000000000000000000000000000000000000", // _fountainAddress (update later)
  "<YOUR_WALLET_ADDRESS>"                       // _initialOwner
]
```

**After Deployment:**
1. Copy deployed address → `RARE_TOKEN_ADDRESS`
2. Verify on Basescan

---

### Step 3: Deploy RareLotteryV3

**Constructor Arguments:**
```javascript
[
  "<RARE_TOKEN_ADDRESS>",   // _rareToken
  "<YOUR_WALLET_ADDRESS>"   // _initialOwner
]
```

**After Deployment:**
1. Copy deployed address → `LOTTERY_ADDRESS`
2. Call `startLottery()` to activate

---

### Step 4: Deploy RareStakingV3

**Constructor Arguments:**
```javascript
[
  "<RARE_TOKEN_ADDRESS>",                       // _rareToken
  "<RARE_TOKEN_ADDRESS>",                       // _lpToken (placeholder - no LP yet)
  "<YOUR_WALLET_ADDRESS>",                      // _treasury
  "0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc88cb", // _ethUsdPriceFeed (Chainlink)
  "<YOUR_WALLET_ADDRESS>"                       // _initialOwner
]
```

**After Deployment:**
1. Copy deployed address → `STAKING_ADDRESS`
2. Transfer RARE tokens to contract for rewards

---

### Step 5: Deploy RareFountainV3

**Constructor Arguments:**
```javascript
[
  "<RARE_TOKEN_ADDRESS>",                       // _rareToken
  "<STAKING_ADDRESS>",                          // _stakingContract
  "<LOTTERY_ADDRESS>",                          // _lotteryContract
  "0x0000000000000000000000000000000000000000", // _basenameRegistry (none on testnet)
  "0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc88cb", // _ethUsdPriceFeed (Chainlink)
  "<YOUR_WALLET_ADDRESS>"                       // _initialOwner
]
```

**After Deployment:**
1. Copy deployed address → `FOUNTAIN_ADDRESS`
2. Update RareTokenV3 with fountain address (if needed)
3. Transfer RARE tokens to fountain for distribution

---

## ⚙️ Post-Deployment Configuration

### 1. Fund Contracts

```javascript
// Transfer RARE to Fountain for claims
await rareToken.transfer(FOUNTAIN_ADDRESS, ethers.parseEther("100000"));

// Transfer RARE to Staking for rewards
await rareToken.transfer(STAKING_ADDRESS, ethers.parseEther("50000"));

// Transfer RARE to Lottery for prizes
await rareToken.transfer(LOTTERY_ADDRESS, ethers.parseEther("10000"));
```

### 2. Configure Fountain

```javascript
// Set pool balance (100 RARE per cycle)
await fountain.setPoolBalance(ethers.parseEther("100"));

// Add yourself to whitelist for testing
await fountain.setManualWhitelist(YOUR_ADDRESS, true);

// Unpause
await fountain.unpause();
```

### 3. Configure Lottery

```javascript
// Start lottery
await lottery.startLottery();
await lottery.unpause();
```

### 4. Configure Staking

```javascript
// Unpause
await staking.unpause();
```

---

## 🧪 Testing Checklist

### Fountain Tests

| Test | Command | Expected |
|------|---------|----------|
| Check eligibility | `fountain.isEligible(YOUR_ADDRESS)` | `true` (whitelisted) |
| Get fee | `fountain.getClaimFeeInEth()` | ~0.00004 ETH |
| Register | `fountain.register({value: fee})` | Success |
| Check streak | `fountain.claimStreak(YOUR_ADDRESS)` | `0` |
| Claim | `fountain.claim()` | Receive RARE |
| Check streak | `fountain.claimStreak(YOUR_ADDRESS)` | `1` |
| Get bonus | `fountain.getTotalBonus(YOUR_ADDRESS)` | Based on tier |

### Staking Tests

| Test | Command | Expected |
|------|---------|----------|
| Get fee | `staking.getEntryFeeInEth()` | ~0.00004 ETH |
| Stake | `staking.stake(amount, 0, {value: fee})` | Success |
| Check stake | `staking.userStakes(addr, 0)` | Stake info |
| Claim reward | `staking.claimReward(0)` | (after 7 days) |

### Lottery Tests

| Test | Command | Expected |
|------|---------|----------|
| Enter | `lottery.enter({value: 0.001})` | Success |
| Check players | `lottery.players(0)` | Your address |
| Pick winner | `lottery.pickWinner()` | (need 3+ players) |

---

## 📋 Deployment Record

### Base Sepolia (Testnet)

| Contract | Address | TX Hash |
|----------|---------|---------|
| RareTokenV3 | `0x...` | `0x...` |
| RareLotteryV3 | `0x...` | `0x...` |
| RareStakingV3 | `0x...` | `0x...` |
| RareFountainV3 | `0x...` | `0x...` |

### Update .env

After deployment, update `rarify-claim/.env.local`:

```bash
NEXT_PUBLIC_NETWORK=testnet
NEXT_PUBLIC_RARE_TOKEN_TESTNET=0x...
NEXT_PUBLIC_FOUNTAIN_TESTNET=0x...
NEXT_PUBLIC_STAKING_TESTNET=0x...
NEXT_PUBLIC_LOTTERY_TESTNET=0x...
```

---

## ⚠️ Known Issues / TODO

1. **Basename Registry**: No testnet address - set to `0x0` for testing
2. **LP Token**: Using RARE token as placeholder - need Aerodrome LP
3. **VRF**: Lottery uses placeholder randomness - integrate Chainlink VRF
4. **Unclaimed tracking**: Fountain's `_countClaimedA/B` returns 0 - implement properly

---

*Deployment Guide v1.0*
*Created: 2026-03-01*
