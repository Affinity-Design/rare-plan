# Rare.Claims Upgrade Plan - Modern Luxury Glass Theme

## Overview

**Goal:** Upgrade rare.claims dApp UI to match the luxury glass dark theme of rare.fyi marketing site.

**Current State:**
- rare.fyi: ✅ Luxury glass dark theme implemented
- rare-coin (dApp): ✅ Next.js created, needs design applied
- DevOps Agent: 🔄 Working on backend fixes
- GLM5: ✅ Available for frontend work
- Gemini 3.1: ✅ API key available

---

## Phase 1: Design System Migration (Priority: HIGH)

### 1.1 Apply Luxury Glass Theme to rare-coin

**Files to Update:**

#### A. Tailwind Configuration
```typescript
// rare-coin/tailwind.config.ts
// Copy from rare-fyi-marketing/tailwind.config.ts

colors: {
  bg: {
    primary: '#050505',
    secondary: '#0A0A0A',
    tertiary: '#111111',
  },
  glass: {
    subtle: 'rgba(255, 255, 255, 0.03)',
    light: 'rgba(255, 255, 255, 0.08)',
    medium: 'rgba(255, 255, 255, 0.12)',
  },
  gold: {
    primary: '#D4AF37',
    light: '#E5C558',
    dark: '#B8952E',
  },
  // ... all luxury colors from rare-fyi
}
```

#### B. Global CSS
```css
// rare-coin/app/globals.css
// Copy glass utilities from rare-fyi-marketing/app/globals.css

.glass, .glass-card, .btn-glass, .input-glass, etc.
```

#### C. Root Layout
```tsx
// rare-coin/app/layout.tsx
- Update metadata for rare.claims
- Apply Inter font (same as rare.fyi)
- Set dark theme as default (no light mode toggle)
```

### 1.2 Page Redesigns

#### A. Home Page (Main dApp Interface)
**Current Location:** `rare-coin/app/page.tsx`

**New Features:**
- Glass card hero with wallet connection
- Floating claim/stake/lottery cards
- Ambient gradient background
- Animated floating elements
- Glassmorphism throughout

**Layout:**
```
┌─────────────────────────────────────────┐
│  ┌──────────────────────────────┐  │
│  │  [Connect Wallet] Button    │  │
│  │  (Glass CTA with gold)    │  │
│  └──────────────────────────────┘  │
│                                     │
│  ┌────────────┐  ┌──────────┐  │
│  │   CLAIM    │  │  STAKE    │  │
│  │   [Count]  │  │   [APY]  │  │
│  └────────────┘  └──────────┘  │
│                                     │
│  ┌────────────┐  ┌──────────┐  │
│  │  LOTTERY   │  │  SWAP     │  │
│  │   [Enter]   │  │   [Trade]  │  │
│  └────────────┘  └──────────┘  │
│                                     │
└─────────────────────────────────────────┘
```

#### B. Claim Page
**Location:** Create `rare-coin/app/claim/page.tsx`

**Features:**
- Stake-to-Claim interface
- Period selection (1 or 2)
- Turnstile CAPTCHA widget
- Claim history table (glass cards)
- Next claim countdown

#### C. Staking Page
**Location:** Create `rare-coin/app/stake/page.tsx`

**Features:**
- Stake amount input
- APY display (estimated rewards)
- Unstaking interface
- Staking history
- Multi-stake pool visualization

#### D. Lottery Page
**Location:** Create `rare-coin/app/lottery/page.tsx`

**Features:**
- Ticket purchase interface
- Current jackpot display
- Entry history
- Countdown to next draw
- Previous winners (glass cards)

#### E. Swap/Buy Page
**Location:** Create `rare-coin/app/swap/page.tsx`

**Features:**
- Token swap interface (RARE ↔ ETH/USDC)
- Buy with fiat (rare.fyi integration)
- Price display with real-time updates
- Transaction history

#### F. Profile/Account Page
**Location:** Create `rare-coin/app/profile/page.tsx`

**Features:**
- Claim history
- Stake history
- Lottery entries
- Rewards earned
- Settings/preferences

---

## Phase 2: Web3 Integration (Priority: CRITICAL)

### 2.1 Wallet Connection

**Library:** wagmi + viem (modern, lightweight)

```bash
# Install
npm install wagmi viem @tanstack/react-query
```

**Implementation:**
```tsx
// app/components/WalletConnect.tsx
'use client'

import { useAccount, useConnect, useDisconnect } from 'wagmi'
import { Button } from '@/components/ui/button'

export function WalletConnect() {
  const { address, isConnected } = useAccount()
  const { connect } = useConnect()
  const { disconnect } = useDisconnect()

  return (
    <Button
      onClick={isConnected ? disconnect : connect}
      className="btn-glass"
    >
      {isConnected ? `${address?.slice(0,6)}...${address?.slice(-4)}` : 'Connect Wallet'}
    </Button>
  )
}
```

### 2.2 Base Chain Configuration

**RPC Endpoints:**
```typescript
// app/config/chains.ts
import { base } from 'wagmi/chains'

export const baseChain = {
  id: base.id,
  name: 'Base',
  nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
  rpcUrls: {
    public: { http: 'https://mainnet.base.org' },
    default: { http: 'https://mainnet.base.org' },
  },
}
```

### 2.3 Contract Interaction Layer

**Abstraction:**
```typescript
// app/contracts/rareToken.ts
import { parseAbi, encodeFunctionData } from 'viem'
import rareTokenAbi from './abi/rareToken.json'

export const rareTokenContract = {
  address: '0x...', // Deploy address when ready
  abi: rareTokenAbi,
}

export async function claimTokens(wallet: Address) {
  const { request } = await publicClient.simulateContract({
    address: rareTokenContract.address,
    abi: rareTokenContract.abi,
    functionName: 'claim',
    args: [wallet],
  })

  const hash = await walletClient.writeContract({
    address: rareTokenContract.address,
    abi: rareTokenContract.abi,
    functionName: 'claim',
    args: [wallet],
  })

  return hash
}
```

---

## Phase 3: Backend Integration (Priority: HIGH)

### 3.1 Supabase Connection

**Environment Variables:**
```bash
NEXT_PUBLIC_SUPABASE_URL=https://ugdflkwkbnyapgubpowc.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIs...
```

**Client Setup:**
```typescript
// app/lib/supabase.ts
import { createClient } from '@supabase/supabase-js'

export const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
)

export type Database = typeof supabase
```

### 3.2 API Routes

**Server Actions:**
```
app/
├── api/
│   ├── auth/
│   │   └── session/route.ts      # Session management
│   ├── claims/
│   │   └── route.ts              # Claim history
│   ├── stakes/
│   │   └── route.ts              # Staking operations
│   └── lottery/
│       └── route.ts              # Lottery data
```

### 3.3 Cloudflare Turnstile Integration

**Frontend:**
```tsx
// app/components/TurnstileWidget.tsx
'use client'

export function TurnstileWidget({ onVerified }: { onVerified: (token: string) => void }) {
  const [token, setToken] = useState<string | null>(null)

  useEffect(() => {
    // Load Cloudflare Turnstile script
    const script = document.createElement('script')
    script.src = 'https://challenges.cloudflare.com/turnstile/v0/api.js'
    script.async = true
    document.body.appendChild(script)

    // Listen for verification
    window.turnstileCallback = (response: string) => {
      setToken(response)
      onVerified(response)
    }
  }, [])

  return (
    <div className="turnstile-container">
      <div className="cf-turnstile" data-sitekey={process.env.NEXT_PUBLIC_TURNSTILE_SITE_KEY} />
    </div>
  )
}
```

**Backend Verification:**
```typescript
// app/api/verify-captcha/route.ts
export async function POST(request: Request) {
  const { token } = await request.json()

  // Verify with Cloudflare
  const response = await fetch('https://challenges.cloudflare.com/turnstile/v0/siteverify', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      secret: process.env.TURNSTILE_SECRET_KEY,
      response: token,
    }),
  })

  const result = await response.json()

  if (result.success) {
    return Response.json({ valid: true })
  }

  return Response.json({ valid: false }, { status: 400 })
}
```

---

## Phase 4: Contract Fixes (GLM5 - DevOps Agent)

### 4.1 Critical Security Fixes

**Contracts to Fix:**
- `rare-coin-projects/rare-coin/rare-erc20.sol` → Deploy new version
- `rare-coin-projects/rare-fountain/rare-fountain-v6.sol` → Add stake-to-claim

**Fixes Required:**

#### A. Reentrancy Guards
```solidity
// Import OpenZeppelin
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract RareFountain is ReentrancyGuard {
    using ReentrancyGuard for uint256 private _guardCounter;

    function claim() external nonReentrant {
        // Claim logic here
    }
}
```

#### B. Stake-to-Claim Implementation
```solidity
uint256 public claimStakeRequirement = 100 * 10**18; // 100 RARE
mapping(address => uint256) public stakedAmount;
mapping(address => uint256) public lastRegistrationTime;

function register() external payable {
    require(
        msg.value >= 0.001 ether ||
        rareToken.balanceOf(msg.sender) >= claimStakeRequirement,
        "Stake required"
    );
    
    if (msg.value > 0) {
        stakedAmount[msg.sender] = msg.value;
    } else {
        stakedAmount[msg.sender] = claimStakeRequirement;
    }
    
    lastRegistrationTime[msg.sender] = block.timestamp;
    _register(msg.sender);
}

function returnStake() external {
    require(stakedAmount[msg.sender] > 0, "No stake to return");
    
    uint256 amount = stakedAmount[msg.sender];
    stakedAmount[msg.sender] = 0;
    
    payable(msg.sender).transfer(amount);
}
```

#### C. Rate Limiting
```solidity
uint256 public registrationCooldown = 1 days;

function register() external payable {
    require(
        block.timestamp >= lastRegistrationTime[msg.sender] + registrationCooldown,
        "Must wait 24h between registrations"
    );
    
    // Registration logic
}
```

### 4.2 Deployment Scripts

**Base Chain Deployment:**
```typescript
// scripts/deploy.ts
import { privateKeyToAccount } from 'viem/accounts'
import { createPublicClient, createWalletClient } from 'viem/chains'

async function main() {
  const account = privateKeyToAccount('0x...') // Your deployer key
  
  const client = createPublicClient({
    chain: base,
    transport: http('https://mainnet.base.org'),
  })
  
  const wallet = createWalletClient({
    account,
    chain: base,
    transport: http(),
  })
  
  // Deploy Rare Token
  const rareTokenHash = await wallet.deployContract({
    abi: rareTokenAbi,
    bytecode: rareTokenBytecode,
    args: ['0x...', // Fountain address
  })
  
  console.log('Rare Token deployed:', rareTokenHash)
  
  // Deploy Rare Fountain (with fixes)
  const fountainHash = await wallet.deployContract({
    abi: fountainAbi,
    bytecode: fountainBytecode,
  })
  
  console.log('Fountain deployed:', fountainHash)
}
```

---

## Phase 5: Frontend AI Integration (Gemini 3.1)

### 5.1 Smart Content Suggestions

**Features:**
- AI-powered blog post suggestions
- SEO keyword recommendations
- Content optimization hints
- Image alt-text generation

**Implementation:**
```typescript
// app/lib/gemini.ts
import { GoogleGenerativeAI } from '@google/generative-ai'

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY)

export async function generateBlogPost(topic: string) {
  const response = await genAI.generateContent({
    contents: [{
      role: 'user',
      parts: [{ text: `Write a SEO-optimized blog post about: ${topic}` }],
    }],
  })

  return response.response.candidates[0].content.parts[0].text
}

export async function optimizeSEO(content: string) {
  const response = await genAI.generateContent({
    contents: [{
      role: 'user',
      parts: [{ text: `Suggest 5 SEO keywords for:\n\n${content}` }],
    }],
  })

  return extractKeywords(response)
}
```

### 5.2 Dynamic Content Generation

**Features:**
- FAQ generation from user queries
- Tutorial creation guides
- Announcement drafting
- Twitter thread suggestions

---

## Phase 6: Migration & Data Transfer

### 6.1 User Migration

**From:** Old contract data (PulseChain)  
**To:** New Supabase database

**Strategy:**
```sql
-- Insert existing users from old contract
INSERT INTO users (wallet_address, registered_at)
SELECT 
  address,
  timestamp
FROM old_contract_claims
WHERE timestamp > '2024-01-01';

-- Update claim counts
UPDATE users u
SET claim_count = (
  SELECT COUNT(*)
  FROM old_contract_claims c
  WHERE c.address = u.wallet_address
);
```

### 6.2 Airdrop to New Contracts

**Process:**
1. Snapshot current holders on old contract
2. Calculate airdrop amounts
3. Deploy new contracts on Base
4. Execute airdrop to verified addresses
5. Disable old contract claims

---

## Timeline

| Phase | Duration | Dependencies |
|--------|-----------|--------------|
| **Phase 1:** Design System | 1-2 days | None |
| **Phase 2:** Web3 Integration | 2-3 days | wagmi, viem |
| **Phase 3:** Backend Integration | 2-3 days | DevOps agent fixes |
| **Phase 4:** Contract Fixes | 3-5 days | Audits, testing |
| **Phase 5:** AI Integration | 2-3 days | Gemini API |
| **Phase 6:** Migration | 5-7 days | Data extraction |
| **TOTAL:** ~15-23 days | — |

---

## Component Library

### Core Components (to build)

1. **Glass Card** - Reusable glassmorphic container
2. **Button** - Primary (gold), Secondary (glass), Ghost
3. **Input** - Glass-styled form inputs
4. **Modal** - Glass confirmation dialogs
5. **Connect Wallet** - Web3 connection UI
6. **Turnstile Widget** - CAPTCHA integration
7. **Stat Card** - Display metrics in glass style
8. **Transaction List** - History table
9. **Countdown Timer** - For claim windows
10. **Loading Spinner** - Glass-styled loader

---

## Success Metrics

### User Experience
- [ ] Glassmorphism applied consistently
- [ ] Dark theme exclusive (no light mode)
- [ ] Smooth animations (60fps)
- [ ] Mobile responsive design
- [ ] Wallet connection < 5 seconds
- [ ] Page load < 2 seconds

### Functionality
- [ ] All engines working (claim, stake, lottery, swap)
- [ ] Web3 wallet connection stable
- [ ] Contract interactions working
- [ ] Supabase data sync working
- [ ] CAPTCHA verification working
- [ ] Rate limiting enforced

### Security
- [ ] No reentrancy vulnerabilities
- [ ] Stake-to-Claim implemented
- [ ] Rate limiting active (24h)
- [ ] CAPTCHA verification required
- [ ] Contract audited before deployment

---

## Next Steps

1. **Start Phase 1** — Apply design system to rare-coin
2. **Wait for Phase 4** — GLM5 contract fixes
3. **Coordinate migration** — Transfer data from old contract
4. **Test on Base testnet** — Before mainnet deployment
5. **Deploy to rare.claims** — Connect domain
6. **Launch campaign** — With new luxury glass theme

---

## Resource Allocation

| Task | Owner | Model/Tool |
|-------|--------|------------|
| **Design System** | Felix (me) | Direct implementation |
| **Web3 Integration** | Felix | wagmi, viem |
| **Backend API** | DevOps Agent | GLM5 |
| **Contract Fixes** | DevOps Agent | GLM5 (code analysis) |
| **AI Features** | Felix | Gemini 3.1 |
| **Database Migration** | DevOps Agent | Supabase |
| **Deployment** | Both | Scripts + monitoring |

---

*This plan ensures coordinated development between all systems while maintaining the luxury glass aesthetic throughout.*
