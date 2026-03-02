# V3 API Documentation

> Complete reference for Rare Coin V3 API endpoints

**Total Endpoints:** 13

---

## 📋 Base URL

| Environment | URL |
|-------------|-----|
| Testnet | `https://test.rare.claims/api/v3` |
| Mainnet | `https://rare.claims/api/v3` |

---

## 🔗 Endpoints

### API Info

```
GET /api/v3
```

Returns API version, network info, and contract addresses.

**Response:**
```json
{
  "version": "3.0.0",
  "network": {
    "name": "Base",
    "chainId": 8453
  },
  "contracts": {
    "rareToken": "0x...",
    "fountain": "0x...",
    "staking": "0x...",
    "lottery": "0x..."
  }
}
```

---

### Supply

```
GET /api/v3/supply
```

Returns token supply information.

**Response:**
```json
{
  "totalSupply": "3650000",
  "circulatingSupply": "3200000",
  "maxSupply": "3650000",
  "decimals": 18
}
```

---

### Claim Fee (Chainlink)

```
GET /api/v3/fee/claim
```

Returns the current $0.10 claim fee converted to ETH via Chainlink.

**Response:**
```json
{
  "usd": 0.1,
  "eth": "0.00004012",
  "ethWei": "40120000000000",
  "ethPrice": {
    "usd": 2492.50,
    "timestamp": 1709356800,
    "source": "chainlink"
  }
}
```

---

### Fountain Status

```
GET /api/v3/fountain/status
```

Returns current fountain pool status and flip countdown.

**Response:**
```json
{
  "pool": {
    "balance": {
      "raw": "100000000000000000000",
      "formatted": "100.0",
      "symbol": "RARE"
    },
    "cycleCount": 42,
    "activePool": "A",
    "registrations": {
      "poolA": 150,
      "poolB": 0,
      "total": 150
    }
  },
  "flip": {
    "lastFlip": "2024-03-01T00:00:00.000Z",
    "nextFlip": "2024-03-02T00:00:00.000Z",
    "secondsRemaining": 43200,
    "canFlip": false
  },
  "estimatedClaim": {
    "raw": "666666666666666666",
    "formatted": "0.67",
    "symbol": "RARE"
  }
}
```

---

### User Streak

```
GET /api/v3/user/:address/streak
```

Returns user's claim streak and tier.

**Response:**
```json
{
  "address": "0x...",
  "streak": 30,
  "tier": 2,
  "bonus": 5,
  "lastClaimDay": "2024-03-01T00:00:00.000Z",
  "daysSinceLastClaim": 0,
  "streakAtRisk": false,
  "nextTier": {
    "tier": 3,
    "daysRequired": 60,
    "daysRemaining": 30,
    "bonusIncrease": 10
  },
  "isMaxTier": false
}
```

---

### User Holding Tier

```
GET /api/v3/user/:address/tier
```

Returns user's RARE holding tier.

**Response:**
```json
{
  "address": "0x...",
  "balance": {
    "raw": "5000000000000000000000",
    "formatted": "5000.00",
    "symbol": "RARE"
  },
  "tier": {
    "level": 4,
    "label": "Champion",
    "threshold": 1000,
    "bonus": 35
  },
  "nextTier": {
    "level": 5,
    "label": "Whale",
    "threshold": 10000,
    "additionalRequired": 5000,
    "bonusIncrease": 65
  },
  "isMaxTier": false
}
```

---

### User Eligibility

```
GET /api/v3/user/:address/eligibility
```

Returns user's eligibility across all 3 tiers.

**Response:**
```json
{
  "address": "0x...",
  "eligible": true,
  "qualifyingTier": "holding",
  "tiers": {
    "manual": {
      "name": "Manual Whitelist",
      "qualifies": false,
      "description": "Admin-added to whitelist"
    },
    "holding": {
      "name": "RARE Holder",
      "qualifies": true,
      "balance": "5000.0",
      "threshold": "1000.0",
      "description": "Hold 1000+ RARE"
    },
    "basename": {
      "name": "Basename Owner",
      "qualifies": false,
      "description": "Own a Basename on Base",
      "available": true
    }
  }
}
```

---

## 📊 Streak & Holding Tiers

### Streak Tiers

| Tier | Days | Bonus |
|------|------|-------|
| 1 | 10 | +1% |
| 2 | 30 | +5% |
| 3 | 60 | +15% |
| 4 | 150 | +35% |
| 5 | 365 | +100% |

### Holding Tiers

| Tier | RARE | Bonus |
|------|------|-------|
| 1 | 1 | +1% |
| 2 | 10 | +5% |
| 3 | 100 | +15% |
| 4 | 1,000 | +35% |
| 5 | 10,000 | +100% |

**Note:** Bonuses **do NOT stack**. User gets the **HIGHER** of streak OR holding.

---

## 🚦 Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 400 | Bad Request (invalid address) |
| 405 | Method Not Allowed |
| 500 | Internal Server Error |
| 503 | Service Unavailable (contracts not configured) |

---

### Market Cap

```
GET /api/v3/market/cap
```

Returns market cap based on supply and ETH price.

**Response:**
```json
{
  "marketCap": {
    "usd": 0,
    "eth": 0,
    "source": "pending"
  },
  "supply": {
    "total": 3650000,
    "max": 3650000
  },
  "ethPrice": {
    "usd": 2492.50,
    "source": "chainlink"
  }
}
```

---

### Trading Volume

```
GET /api/v3/market/volume
```

Returns 24h trading volume from Aerodrome.

**Response:**
```json
{
  "volume": {
    "eth24h": 0,
    "usd24h": 0,
    "rare24h": 0
  },
  "source": "pending"
}
```

---

### Token Price

```
GET /api/v3/price
```

Returns current RARE price from Aerodrome.

**Response:**
```json
{
  "price": {
    "usd": 0,
    "eth": 0,
    "source": "pending"
  },
  "dex": {
    "name": "Aerodrome",
    "router": "0x...",
    "factory": "0x..."
  }
}
```

---

### Staking TVL

```
GET /api/v3/staking/tvl
```

Returns total value locked in staking.

**Response:**
```json
{
  "staking": {
    "totalLPStaked": {
      "raw": "1000000000000000000000",
      "formatted": "1000.0",
      "symbol": "LP"
    },
    "totalRewardsDistributed": {
      "raw": "50000000000000000000000",
      "formatted": "50000.0",
      "symbol": "RARE"
    }
  }
}
```

---

### Lottery Status

```
GET /api/v3/lottery/status
```

Returns current lottery round status and prizes.

**Response:**
```json
{
  "lottery": {
    "id": 42,
    "active": true,
    "status": "active"
  },
  "config": {
    "minPlayers": 3,
    "maxEntriesPerAddress": 5
  },
  "prize": {
    "eth": {
      "formatted": "0.5",
      "symbol": "ETH"
    },
    "rare": {
      "formatted": "1000.0",
      "symbol": "RARE"
    }
  }
}
```

---

### Migration Snapshot

```
GET /api/v3/migration/snapshot/:address
```

Returns user's Gnosis (V2) balance for migration to Base (V3).

**Response:**
```json
{
  "address": "0x...",
  "v2": {
    "rareBalance": {
      "formatted": "100.00",
      "symbol": "RARE"
    }
  },
  "v3": {
    "rareAirdrop": {
      "amount": "10000.00",
      "multiplier": "100x"
    },
    "nftAirdrop": {
      "total": "1000.00"
    },
    "totalClaim": {
      "amount": "11000.00",
      "symbol": "RARE"
    }
  }
}
```

---

## 💡 Usage Tips

### Parallel Fetching
For best performance, fetch user data in parallel:
```javascript
const [streak, tier, eligibility] = await Promise.all([
  fetch(`/api/v3/user/${address}/streak`),
  fetch(`/api/v3/user/${address}/tier`),
  fetch(`/api/v3/user/${address}/eligibility`),
]);
```

### Caching
- Supply data: Cache 60 seconds
- Fee data: Cache 30 seconds
- User data: Cache 10 seconds
- Fountain status: Cache 10 seconds

---

*API Documentation v1.0*
*Last Updated: 2026-03-02*
