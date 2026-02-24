# Website Architecture - Rare Coin Relaunch

## Two-Site Strategy

### 📄 rare.fyi — Marketing Site

**Purpose:** SEO, Content, Hype Building

**Features:**
- Blog system with SEO optimization
- News & announcements section
- Comprehensive FAQs
- Educational content about crypto, Rare Coin, Base Chain
- Roadmap timeline
- Team/About section
- Clear CTAs linking to rare.claims
- Newsletter signup
- Social media links

**Content Types:**
- SEO-optimized articles
- Weekly updates
- Feature reveals
- Community spotlights
- Technical deep-dives
- Educational guides

**Tech Stack:**
- Fresh Next.js build (not building on old rarify-claim)
- Tailwind CSS for styling
- MDX for blog posts (content as Markdown with React components)
- SEO plugins (next-seo or similar)
- Sitemap generation
- Analytics integration

---

### 🎰 rare.claims — Frontend App (dApp)

**Purpose:** Full Functional Experience

**Features (from existing rarify-claim):**
- Claiming engine
- Staking engine
- Lottery engine
- Swap/Buy interface
- Stats dashboard
- Account management
- All 48 API endpoints

**New Features to Add:**
- Bot-proof registration (CAPTCHA, BrightID)
- Modern UI/UX redesign
- Wallet connection (multiple providers)
- Real-time data updates
- Mobile-responsive design
- Accessibility features

**Tech Stack:**
- Fresh Next.js build (separate from marketing site)
- Web3 libraries (wagmi, viem, or ethers.js)
- Wallet connection (RainbowKit, ConnectKit, or Web3Modal)
- Tailwind CSS
- React Query for data fetching
- TypeScript for type safety

---

## Design System (Both Sites)

**Shared Brand Identity:**
- Consistent color palette
- Typography system
- Logo & branding assets
- Component library (reusable across both sites)

**Visual Direction:**
- Modern, clean aesthetic
- Trustworthy, professional yet approachable
- Crypto-native UX patterns
- Dark mode support
- Mobile-first responsive design

---

## Development Phases

### Phase 1: Marketing Site (rare.fyi)
1. Set up fresh Next.js project
2. Design system & branding
3. Build blog/SEO infrastructure
4. Create initial content (5-10 articles)
5. Deploy to domain
6. SEO optimization & indexing

### Phase 2: App Site (rare.claims)
1. Set up fresh Next.js project
2. Migrate & refactor existing engines
3. Add bot-proofing (CAPTCHA, BrightID)
4. Redesign UI/UX
5. Integrate Base chain
6. Deploy to domain
7. Test thoroughly on testnet

### Phase 3: Integration & Launch
1. Link both sites together
2. Final testing
3. Security audit of contracts
4. Deploy to Base mainnet
5. Launch marketing campaign

---

## What I Need

**To Start Development:**
1. ✅ GitHub access — DONE
2. 🟡 Gemini 3.1 Pro Preview API key — PENDING from you
3. 🟡 Base chain RPC URL — PENDING
4. 🟡 Base chain explorer URL — for contract verification
5. 🟡 Brand assets (logo, colors if you have them) — or I can design

**For Deployment:**
1. 🟡 Hosting credentials (Vercel, Netlify, or custom)
2. 🟡 Domain DNS access (or I'll give you DNS records to add)
3. 🟡 SSL certificates (auto on most platforms)

---

## Next Steps

1. **Wait for:** Gemini API key from you
2. **While waiting:** Design system exploration, content outline, technical architecture
3. **Once key received:** Spawn frontend agent, begin marketing site build
4. **When GLM5 rate limit clears:** Spawn backend agent, begin app site build

---
