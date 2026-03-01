# Rare Claims API Audit & Migration Plan

> Complete audit of all API endpoints and migration plan from Gnosis to Base Chain

---

## 📊 Current API Structure

```
pages/api/
├── [query].ts                    ← Dynamic query handler
└── rarecoin/
    ├── 24hour-volume.ts          ← Trading volume (Gnosis)
    ├── address.ts                ← Token contract address
    ├── circulating-supply.ts     ← Supply stats
    ├── decimals.ts               ← Token decimals
    ├── name.ts                   ← Token name
    ├── symbol.ts                 ← Token symbol
    ├── total-supply.ts           ← Total supply
    ├── max-supply.ts             ← Max supply
    ├── market-cap.ts             ← Market cap
    ├── market-cap-diluted.ts     ← Diluted market cap
    ├── distro.ts                 ← Distribution stats
    ├── trading-pairs.ts          ← DEX pairs (Honeyswap)
    ├── price/
    │   ├── index.ts              ← Current price
    │   ├── 24hour.ts             ← 24h price change
    │   ├── days/[days].ts        ← Historical price (days)
    │   └── hours/[hours].ts      ← Historical price (hours)
    ├── volume/
    │   ├── index.ts              ← Volume data
    │   └── days/[days].ts        ← Historical volume
    ├── marketcap/
    │   ├── index.ts              ← Market cap data
    │   ├── est.ts                ← Estimated market cap
    │   └── days/[days].ts        ← Historical market cap
    ├── claims/
    │   ├── index.ts              ← Claims data
    │   └── [days].ts             ← Historical claims
    ├── issued/
    │   ├── index.ts              ← Tokens issued
    │   └── [date].ts             ← By date
    ├── lotto/
    │   ├── index.ts              ← Lottery data
    │   ├── active.ts             ← Active round
    │   ├── islive.ts             ← Is live?
    │   ├── entries.ts            ← Entry count
    │   ├── price.ts              ← Ticket price
    │   ├── jackpot_value.ts      ← Jackpot value
    │   ├── jackpot_reward.ts     ← Reward amount
    │   └── lastWinner.ts         ← Last winner
    ├── staking/
    │   ├── index.ts              ← Staking data
    │   ├── tvl.ts                ← Total value locked
    │   ├── liquidity-locked.ts   ← LP locked
    │   ├── lp-tokens-locked.ts   ← LP tokens count
    │   ├── value_per_lp.ts       ← Value per LP
    │   └── [user]/
    │       ├── index.ts          ← User stakes
    │       └── [amt]/index.ts    ← Specific stake
    ├── nft/
    │   ├── index.ts              ← NFT data
    │   └── [id].ts               ← NFT by ID
    └── easybuy/
        ├── index.ts              ← Buy system
        └── client/
            ├── index.ts          ← Client data
            └── order.ts          ← Order data
```

---

## 🔄 Endpoint Migration Status

### ✅ Keep (Update to V3)

| Endpoint | Gnosis | Base V3 | Status |
|----------|--------|---------|--------|
| `/api/v3/address` | Token address | `RareTokenV3` | ⏳ Update |
| `/api/v3/circulating-supply` | On-chain | On-chain | ⏳ Update |
| `/api/v3/total-supply` | 36,500 | 3,650,000 | ⏳ Update |
| `/api/v3/decimals` | 18 | 18 | ✅ Same |
| `/api/v3/name` | RARE | RARE | ✅ Same |
| `/api/v3/symbol` | RARE | RARE | ✅ Same |

### 🔁 Replace (New Logic)

| Old Endpoint | New Endpoint | Changes |
|--------------|--------------|---------|
| `/price` | `/api/v3/price` | Use Aerodrome instead of Honeyswap |
| `/24hour-volume` | `/api/v3/volume/24h` | Aerodrome API |
| `/trading-pairs` | `/api/v3/pairs` | Base DEX pairs |
| `/market-cap` | `/api/v3/marketcap` | New price source |

### 🆕 New Endpoints (V3 Features)

| Endpoint | Purpose |
|----------|---------|
| `/api/v3/streak/:address` | Get user's claim streak |
| `/api/v3/holding-tier/:address` | Get RARE holding tier |
| `/api/v3/eligibility/:address` | 3-Tier whitelist check |
| `/api/v3/fee/claim` | Get $0.10 fee in ETH (Chainlink) |
| `/api/v3/fee/stake` | Get $0.10 fee in ETH (Chainlink) |
| `/api/v3/pool/status` | Fountain pool A/B status |
| `/api/v3/pool/countdown` | Time to next flip |
| `/api/v3/lottery/vrf-status` | VRF randomness status |

### ❌ Remove (Legacy)

| Endpoint | Reason |
|----------|--------|
| `/easybuy/*` | Deprecated payment system |
| `/brightid/*` | BrightID not in V3 |
| `/nft/*` | Replaced by holding tiers |

---

## 🔧 Implementation Plan

### Phase 1: Create V3 API Structure

```
pages/api/v3/
├── index.ts                      ← API version info
├── network.ts                    ← Current network config
├── contracts.ts                  ← Contract addresses
├── price/
│   ├── index.ts                  ← Current price (Aerodrome)
│   ├── 24h.ts                    ← 24h change
│   └── history/[period].ts       ← Historical
├── supply/
│   ├── circulating.ts            ← Circulating supply
│   ├── total.ts                  ← Total supply (3.65M)
│   └── max.ts                    ← Max supply (3.65M)
├── market/
│   ├── cap.ts                    ← Market cap
│   └── volume.ts                 ← Trading volume
├── fountain/
│   ├── status.ts                 ← Pool A/B, cycle count
│   ├── countdown.ts              ← Time to flip
│   ├── balance.ts                ← Pool balance
│   └── unclaimed.ts              ← Unclaimed tokens
├── staking/
│   ├── tvl.ts                    ← Total value locked
│   ├── apr.ts                    ← Estimated APR
│   └── [address].ts              ← User stakes
├── lottery/
│   ├── status.ts                 ← Round status
│   ├── prize.ts                  ← ETH + RARE prize
│   ├── entries.ts                ← Entry count
│   └── history.ts                ← Past winners
├── user/
│   ├── [address]/streak.ts       ← Claim streak
│   ├── [address]/tier.ts         ← Holding tier
│   ├── [address]/eligibility.ts  ← 3-Tier check
│   ├── [address]/claims.ts       ← Claim history
│   └── [address]/stakes.ts       ← Stake history
├── fee/
│   ├── claim.ts                  ← $0.10 in ETH
│   └── stake.ts                  ← $0.10 in ETH
└── migration/
    ├── snapshot/:address.ts      ← Gnosis snapshot balance
    ├── nft-bonus/:address.ts     ← NFT bonus calculation
    └── merkle-proof/:address.ts  ← Airdrop proof
```

### Phase 2: Implement Core Endpoints

```typescript
// pages/api/v3/fee/claim.ts
import { NextApiRequest, NextApiResponse } from 'next';
import { createPublicClient, http } from 'viem';
import { base } from 'wagmi/chains';

const CLAIM_FEE_USD = 0.1; // $0.10

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  try {
    const client = createPublicClient({
      chain: base,
      transport: http(),
    });

    // Get ETH price from Chainlink
    const ethPrice = await client.readContract({
      address: '0x...', // Chainlink ETH/USD on Base
      abi: [...], // Chainlink ABI
      functionName: 'latestRoundData',
    });

    // Calculate fee in ETH
    const feeInEth = (CLAIM_FEE_USD * 1e18) / Number(ethPrice.answer) * 1e10;

    res.status(200).json({
      usd: CLAIM_FEE_USD,
      eth: feeInEth.toString(),
      ethFormatted: (feeInEth / 1e18).toFixed(8),
      ethPrice: Number(ethPrice.answer) / 1e8,
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch fee' });
  }
}
```

```typescript
// pages/api/v3/user/[address]/eligibility.ts
import { NextApiRequest, NextApiResponse } from 'next';
import { createPublicClient, http } from 'viem';
import { base } from 'wagmi/chains';
import { getContracts } from '@/config';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { address } = req.query;
  
  if (!address || typeof address !== 'string') {
    return res.status(400).json({ error: 'Address required' });
  }

  try {
    const contracts = getContracts();
    const client = createPublicClient({
      chain: base,
      transport: http(),
    });

    // Check all 3 tiers
    const [manualWhitelist, rareBalance, basenameBalance] = await Promise.all([
      // Tier 1: Manual whitelist
      client.readContract({
        address: contracts.RareFountain as `0x${string}`,
        abi: [...], // Fountain ABI
        functionName: 'manualWhitelist',
        args: [address],
      }),
      // Tier 2: RARE balance
      client.readContract({
        address: contracts.RareToken as `0x${string}`,
        abi: [...], // ERC20 ABI
        functionName: 'balanceOf',
        args: [address],
      }),
      // Tier 3: Basename
      client.readContract({
        address: contracts.BasenameRegistry as `0x${string}`,
        abi: [...], // Basename ABI
        functionName: 'balanceOf',
        args: [address],
      }),
    ]);

    const holdingThreshold = 1000n * 10n ** 18n; // 1,000 RARE
    const isEligible = 
      manualWhitelist === true ||
      BigInt(rareBalance) >= holdingThreshold ||
      BigInt(basenameBalance) > 0;

    res.status(200).json({
      address,
      eligible: isEligible,
      tiers: {
        manual: manualWhitelist,
        holding: {
          balance: rareBalance.toString(),
          threshold: holdingThreshold.toString(),
          qualifies: BigInt(rareBalance) >= holdingThreshold,
        },
        basename: {
          balance: basenameBalance.toString(),
          qualifies: BigInt(basenameBalance) > 0,
        },
      },
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to check eligibility' });
  }
}
```

```typescript
// pages/api/v3/user/[address]/streak.ts
import { NextApiRequest, NextApiResponse } from 'next';
import { supabase } from '@/lib/supabase';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { address } = req.query;
  
  if (!address || typeof address !== 'string') {
    return res.status(400).json({ error: 'Address required' });
  }

  try {
    const { data: user, error } = await supabase
      .from('users')
      .select('claim_streak, last_claim_day')
      .eq('wallet_address', address.toLowerCase())
      .single();

    if (error || !user) {
      return res.status(200).json({
        address,
        streak: 0,
        tier: 0,
        bonus: 0,
      });
    }

    // Calculate tier and bonus
    const streak = user.claim_streak || 0;
    let tier = 0;
    let bonus = 0;

    if (streak >= 365) { tier = 5; bonus = 100; }
    else if (streak >= 150) { tier = 4; bonus = 35; }
    else if (streak >= 60) { tier = 3; bonus = 15; }
    else if (streak >= 30) { tier = 2; bonus = 5; }
    else if (streak >= 10) { tier = 1; bonus = 1; }

    res.status(200).json({
      address,
      streak,
      tier,
      bonus,
      lastClaimDay: user.last_claim_day,
      nextTierAt: tier < 5 ? [10, 30, 60, 150, 365][tier] : null,
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch streak' });
  }
}
```

---

## 🧪 Testing Strategy

### Environment Switching

```bash
# Development (testnet)
NEXT_PUBLIC_NETWORK=testnet npm run dev

# Production preview (testnet)
NEXT_PUBLIC_NETWORK=testnet npm run build && npm start

# Production (mainnet)
NEXT_PUBLIC_NETWORK=mainnet npm run build
```

### Subdomain Routing

```javascript
// next.config.js
module.exports = {
  env: {
    NEXT_PUBLIC_NETWORK: process.env.VERCEL_GIT_BRANCH === 'main' ? 'mainnet' : 'testnet',
  },
};
```

### Test Domains

| Domain | Environment | Contracts |
|--------|-------------|-----------|
| `test.rare.claims` | Testnet | Sepolia Base |
| `rare.claims` | Mainnet | Base Mainnet |
| `localhost:3000` | Development | Configurable |

---

## 📋 Migration Checklist

### Pre-Migration
- [ ] Deploy V3 contracts to Base testnet
- [ ] Fill in `.env.local` with testnet addresses
- [ ] Create Supabase tables
- [ ] Test all V3 endpoints locally

### Migration Week
- [ ] Create `/api/v3/*` endpoints
- [ ] Update frontend to use V3 endpoints
- [ ] Keep `/api/rarecoin/*` as fallback
- [ ] Test on `test.rare.claims`

### Launch
- [ ] Deploy V3 contracts to Base mainnet
- [ ] Update `.env` with mainnet addresses
- [ ] Deploy to `rare.claims`
- [ ] Monitor for issues

---

*API Audit v1.0*
*Created: 2026-03-01*
