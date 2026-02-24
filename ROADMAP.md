# Development Timeline - 4 Week Sprint

## Overview

**Goal:** Build and test all new Rare Coin infrastructure before any public announcement.

**Duration:** 4 weeks (28 days)
**Start:** Week 1
**Announce:** After Week 4 (if ready)

---

## 📅 Week-by-Week Plan

### Week 1: Core Contracts

| Day | Task | Deliverable |
|-----|------|-------------|
| **Mon** | Write RareTokenV2.sol | Token contract with airdrop |
| **Tue** | Write RareFountainV2.sol | Distribution with stake-to-claim |
| **Wed** | Write RareStakingV2.sol | Time-weighted staking |
| **Thu** | Write RareLottoV2.sol | Lottery with Chainlink VRF |
| **Fri** | Write AirdropClaim.sol | Merkle drop contract |
| **Sat** | Internal review | Fix issues |
| **Sun** | Deploy to Base Sepolia testnet | Contracts live on testnet |

---

### Week 2: Frontend dApp

| Day | Task | Deliverable |
|-----|------|-------------|
| **Mon** | Set up rare-coin project | Next.js + wagmi + viem |
| **Tue** | Build wallet connection | Connect/disconnect |
| **Wed** | Build claim page | Claim UI + Turnstile |
| **Thu** | Build stake page | Stake/unstake UI |
| **Fri** | Build lottery page | Ticket purchase UI |
| **Sat** | Build swap page | DEX aggregator |
| **Sun** | Deploy to Vercel | rare-claims.vercel.app |

---

### Week 3: Backend & Integration

| Day | Task | Deliverable |
|-----|------|-------------|
| **Mon** | Run Supabase migration | All tables created |
| **Tue** | Build API routes | /api/claims, /api/stakes, etc. |
| **Wed** | Integrate Turnstile | Server-side verification |
| **Thu** | Connect contracts to frontend | wagmi configuration |
| **Fri** | Test all flows | Claim → Stake → Lottery |
| **Sat** | Fix bugs | Address issues |
| **Sun** | Load testing | Simulate 1000 users |

---

### Week 4: Polish & Prep

| Day | Task | Deliverable |
|-----|------|-------------|
| **Mon** | UI polish | Responsive, smooth |
| **Tue** | Security review | Internal audit |
| **Wed** | Documentation | User guides, API docs |
| **Thu** | Marketing prep | Announcements, graphics |
| **Fri** | Final testing | Everything works |
| **Sat** | Backup & monitoring | Error tracking |
| **Sun** | **DECISION DAY** | Ready to announce? |

---

## ✅ End of Week 4 Checklist

Before announcing, verify:

### Contracts
- [ ] All 5 contracts written
- [ ] Deployed to Base testnet
- [ ] All functions tested
- [ ] Reentrancy protected
- [ ] Events emitting correctly

### Frontend
- [ ] Wallet connection works
- [ ] Claim flow works
- [ ] Stake flow works
- [ ] Lottery flow works
- [ ] Mobile responsive

### Backend
- [ ] Supabase tables created
- [ ] API routes working
- [ ] Turnstile verification
- [ ] Error handling

### Infrastructure
- [ ] Deployed to testnet
- [ ] Deployed to Vercel
- [ ] Monitoring set up
- [ ] Backup plan ready

### Documentation
- [ ] User guides written
- [ ] API docs complete
- [ ] FAQ ready

### Marketing
- [ ] Announcement drafted
- [ ] Twitter thread ready
- [ ] Graphics created
- [ ] Video (optional)

---

## 📊 Progress Tracking

### Weekly Reports

**Week 1 Report:**
- Contracts completed: 0/5
- Testnet deployment: ❌
- Issues found: 0

**Week 2 Report:**
- Frontend pages: 0/5
- Wallet connection: ❌
- Mobile responsive: ❌

**Week 3 Report:**
- Backend routes: 0/10
- Supabase tables: 0/10
- Integration: 0%

**Week 4 Report:**
- Polish complete: ❌
- Security review: ❌
- Ready to announce: ❌

---

## 🚫 What We're NOT Doing Yet

| Task | When |
|------|------|
| Public announcement | After Week 4 |
| Snapshot | After announcement |
| Airdrop | After snapshot |
| Mainnet deployment | After airdrop |

---

## ⚠️ Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Contracts have bugs | Week 1-2 testing |
| Frontend issues | Week 2 buffer |
| Integration fails | Week 3 focus |
| Not ready Week 4 | Delay announcement |

---

## 📅 Decision Points

**End of Week 2:**
- Are contracts ready?
- Should we delay frontend?

**End of Week 3:**
- Is integration working?
- Any blockers?

**End of Week 4:**
- **GO/NO-GO for announcement**

---

## 🎯 Success Criteria

**Minimum Viable Launch:**
- Token contract ✅
- Fountain contract ✅
- Claim page ✅
- Wallet connection ✅
- Testnet working ✅

**Full Launch:**
- All 5 contracts ✅
- All 5 frontend pages ✅
- All backend routes ✅
- Mainnet ready ✅

---

## 📝 Daily Standups

Every day, answer:
1. What did I build yesterday?
2. What am I building today?
3. Any blockers?

---

*Development Timeline v1.0*
*Created: 2026-02-24*
*Author: Felix*
