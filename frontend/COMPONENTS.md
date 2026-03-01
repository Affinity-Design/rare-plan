# Frontend Components Phase 1: Core UI

> Comprehensive UI component library for Rare Coin V3 applications

---

## 🎨 Design System

### Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| `void` | `#080B0F` | Primary background |
| `deep` | `#0D1117` | Secondary background |
| `surface` | `#131920` | Cards, panels |
| `panel` | `#1A2332` | Elevated surfaces |
| `rare` | `#9432FB` | Primary accent |
| `rare-pink` | `#F633FF` | Secondary accent |
| `rare-blue` | `#3235FB` | Tertiary accent |
| `rare-light` | `#3299FB` | Highlight |
| `green` | `#10B981` | Success, streaks |
| `text` | `#E8EDF2` | Primary text |
| `muted` | `#7A8A99` | Secondary text |

### Gradients

```css
/* Iridescent - Primary brand gradient */
--gradient-iridescent: linear-gradient(135deg, #F633FF, #9432FB, #3235FB, #3299FB);

/* Text Gradient */
.text-gradient { /* Apply to text for gradient effect */ }
```

### Typography

- **Sans:** Plus Jakarta Sans
- **Serif:** Cormorant Garamond
- **Mono:** Space Mono

---

## 🧩 Components

### Core UI (`/components/ui/`)

| Component | Description |
|-----------|-------------|
| `Button` | Primary, secondary, ghost, danger variants |
| `Card` | Default, glass, gradient variants |
| `Badge` | Default, streak, tier, success, warning, danger |
| `Input` | Text input, address input, amount input |
| `Progress` | Linear, circular, streak progress |
| `FeeDisplay` | USD → ETH conversion display |
| `EligibilityCheck` | 3-tier whitelist status |

### Feature Components (`/components/`)

| Component | Description |
|-----------|-------------|
| `Logo` | Brand logo with variants (full, icon, text) |
| `ClaimCard` | Full claim interface |

---

## 📁 File Structure

```
/src
├── components/
│   ├── ui/
│   │   ├── Button.tsx
│   │   ├── Card.tsx
│   │   ├── Badge.tsx
│   │   ├── Input.tsx
│   │   ├── Progress.tsx
│   │   ├── FeeDisplay.tsx
│   │   ├── EligibilityCheck.tsx
│   │   └── index.ts
│   ├── Logo.tsx
│   ├── ClaimCard.tsx
│   └── index.ts
├── styles/
│   ├── globals.css
│   └── tokens.ts
├── lib/
│   └── i18n.ts
└── locales/
    └── translations.json
```

---

## 🌐 Internationalization

### Supported Languages

| Code | Language | Status |
|------|----------|--------|
| `en` | English | ✅ Complete |
| `es` | Spanish | 🟡 Partial |
| `zh` | Chinese | 🟡 Partial |
| `ja` | Japanese | 🟡 Partial |

### Usage

```tsx
import { t } from '@/lib/i18n';

// Simple translation
<p>{t('claim.title')}</p>

// With parameters
<p>{t('claim.streak.days', { count: 30 })}</p>

// Change locale
import { setLocale } from '@/lib/i18n';
setLocale('es');
```

### Chrome Translation

For MVP launch, Chrome's built-in translation can handle static content. For dynamic content (wallet addresses, balances), use the i18n system.

---

## 🎯 Component Usage Examples

### Button

```tsx
import { Button } from '@/components/ui';

<Button variant="primary" size="lg">
  Claim RARE
</Button>

<Button variant="secondary" icon="🔍">
  Search
</Button>
```

### Card

```tsx
import { Card, CardHeader } from '@/components/ui';

<Card variant="glass" hover>
  <CardHeader
    title="Your Streak"
    subtitle="Daily claim bonus"
    icon="🔥"
  />
  {/* Content */}
</Card>
```

### Badge

```tsx
import { Badge, StreakBadge, HoldingTierBadge } from '@/components/ui';

<Badge variant="streak" icon="🔥">30 Days</Badge>

<StreakBadge days={30} bonus={5} />

<HoldingTierBadge tier={3} balance={5000} bonus={15} />
```

### ClaimCard

```tsx
import { ClaimCard } from '@/components';

<ClaimCard
  address="0x..."
  streak={{ days: 30, tier: 2, bonus: 5, lastClaimDay: '2024-01-15', nextTierAt: 60 }}
  holding={{ balance: '5000000000000000000000', tier: 3, bonus: 15 }}
  eligibility={{ manual: false, holding: true, basename: true, isEligible: true }}
  fee={{ usd: 0.1, ethPrice: 2500, ethAmount: '0.00004' }}
  onClaim={() => handleClaim()}
/>
```

---

## 🚀 Next Steps

### Week 2: Wallet Integration

- [ ] Connect wallet modal
- [ ] Network switcher (Base testnet/mainnet)
- [ ] Transaction status toasts
- [ ] Error handling UI

### Week 3: Feature Components

- [ ] Staking interface
- [ ] Lottery interface
- [ ] Portfolio dashboard
- [ ] Transaction history

### Week 4: Polish

- [ ] Loading skeletons
- [ ] Empty states
- [ ] Error boundaries
- [ ] Animations & transitions

---

*Frontend Components v1.0*
*Created: 2026-03-01*
