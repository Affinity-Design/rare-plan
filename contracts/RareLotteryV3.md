# Rare Lottery V3

> Provably fair lottery with Chainlink VRF and sybil resistance

---

## 🎯 Overview

The Rare Lottery is a community jackpot system where users can win accumulated ETH and RARE prizes.

| Property | Value |
|----------|-------|
| **Network** | Base Chain |
| **Solidity** | 0.8.20 |
| **Randomness** | Chainlink VRF V2.5 / Pyth Entropy |
| **Entry Methods** | Native ETH or RARE tokens |

---

## 🎰 How It Works

1. **Enter** - Pay with ETH or RARE tokens
2. **Wait** - Minimum 3 players required
3. **Draw** - Manager triggers VRF randomness
4. **Win** - Winner takes entire pot (ETH + RARE)

---

## 🎫 Entry System

### Entry Limits
- **Max entries per address:** 5
- **Minimum players:** 3 (to draw)
- **Entry methods:** Native ETH or RARE

### Anti-Whale Protection
```solidity
uint256 public constant MAX_ENTRIES_PER_ADDRESS = 5;

function enter() external {
    require(entryCount[msg.sender] < MAX_ENTRIES_PER_ADDRESS, "Too many entries");
    entryCount[msg.sender]++;
    players.push(msg.sender);
}
```

---

## 🔐 Provably Fair Randomness

V3 is designed for **Chainlink VRF V2.5** or **Pyth Entropy**:

```solidity
// VRF Integration Point
function pickWinner() external onlyOwner {
    require(players.length >= MIN_PLAYERS, "Not enough players");
    // Request randomness from Chainlink VRF
    requestRandomness(keyHash, fee);
}

function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
    uint256 winnerIndex = randomness % players.length;
    address winner = players[winnerIndex];
    
    // Transfer entire pot
    payable(winner).transfer(address(this).balance);
    rareToken.transfer(winner, rareToken.balanceOf(address(this)));
}
```

**Why VRF?**
- Cannot be manipulated by miners
- Verifiable on-chain
- Tamper-proof

---

## 💰 Prize Pool Sources

| Source | Amount |
|--------|--------|
| **Entry Fees** | ETH + RARE from participants |
| **Fountain Unclaimed** | Automatic transfer every 24h |
| **Staking Fees** | $0.10 per stake (optional) |

---

## 📋 Contract Functions

### User Functions

| Function | Description |
|----------|-------------|
| `enter()` | Enter lottery (pay ETH or hold RARE) |
| `startLottery()` | Start a new round (if ended) |

### Admin Functions

| Function | Description |
|----------|-------------|
| `pickWinner()` | Trigger VRF draw |
| `pause()` / `unpause()` | Emergency controls |

### View Functions

| Function | Description |
|----------|-------------|
| `getPlayersCount()` | Number of entries |
| `lotteryActive` | Is round open? |

---

## 🎲 Example Scenario

```
Round 1:
- Alice enters (2 entries) - 0.002 ETH
- Bob enters (5 entries) - 0.005 ETH + 50 RARE
- Charlie enters (1 entry) - 0.001 ETH
- Fountain sends unclaimed: 100 RARE

Total Pot: 0.008 ETH + 150 RARE

Draw:
- VRF returns random number: 42
- Winner index: 42 % 8 = 2 (Charlie)
- Charlie wins entire pot!
```

---

## 🔒 Security Features

| Feature | Status |
|---------|--------|
| Solidity 0.8.20 | ✅ |
| ReentrancyGuard | ✅ |
| Pausable | ✅ |
| Entry Limits | ✅ (5 per address) |
| Minimum Players | ✅ (3 required) |
| VRF Randomness | ✅ (Chainlink/Pyth) |

---

## ⚠️ Important Notes

- **No refunds** after entry
- **Must wait** for minimum players
- **VRF fee** paid in LINK (or native on Base)
- **Winner takes all** - no second place

---

## 🔗 Integration

### Chainlink VRF
- **Network:** Base Chain
- **Coordinator:** VRF Coordinator V2.5
- **Fee:** ~0.1 LINK per request

### Pyth Entropy (Alternative)
- **Network:** Base Chain
- **Fee:** Native ETH

---

## 📊 Odds Calculation

```
Your Odds = Your Entries / Total Entries

Example:
- You: 5 entries
- Total: 50 entries
- Your odds: 10%
```

---

*Version: V3 (Base Chain)*
