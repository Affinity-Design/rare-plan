# Rare Coin Design System v1.0

> Comprehensive design system for all Rare Coin applications (rare.fyi, rare.claims, rare.claims)

---

## 🎨 Brand Identity

### Logo System

| Variant | Usage | File |
|---------|-------|------|
| **Primary** | Dark backgrounds | `/brand/rare-logo-light.svg` |
| **Secondary** | Light backgrounds | `/brand/rare-logo-dark.svg` |
| **Icon Only** | Favicons, small spaces | `/brand/rare-icon.svg` |
| **Animated** | Loading states | `/brand/rare-logo-animated.svg` |

### Logo Colors

```
Primary Pink:  #F633FF
Primary Purple: #9432FB
Primary Blue:   #3235FB
Light Blue:     #3299FB
```

### Logo Clear Space

- Minimum padding: 1x logo height on all sides
- Minimum width: 120px for full logo, 32px for icon

---

## 🎨 Color System

### Base Colors (Dark Theme)

| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `void` | `#080B0F` | `8, 11, 15` | Primary background |
| `deep` | `#0D1117` | `13, 17, 23` | Secondary background |
| `surface` | `#131920` | `19, 25, 32` | Cards, panels |
| `panel` | `#1A2332` | `26, 35, 50` | Elevated surfaces |

### Text Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `text` | `#E8EDF2` | Primary text |
| `muted` | `#7A8A99` | Secondary text, labels |
| `text-tertiary` | `#5A6A7A` | Tertiary text, placeholders |

### Brand Gradient (Iridescent)

```
/* Primary gradient - use for CTAs, highlights */
--gradient-iridescent: linear-gradient(135deg, #F633FF, #9432FB, #3235FB, #3299FB);

/* Horizontal gradient */
--gradient-iridescent-h: linear-gradient(90deg, #F633FF, #9432FB, #3235FB, #3299FB);

/* Text gradient */
--gradient-text: linear-gradient(135deg, #F633FF, #9432FB, #3235FB, #3299FB);
```

### Accent Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `rare` | `#9432FB` | Primary accent |
| `rare-pink` | `#F633FF` | Secondary accent |
| `rare-blue` | `#3235FB` | Tertiary accent |
| `rare-light` | `#3299FB` | Highlight accent |
| `green` | `#10B981` | Success, positive |

### Glass Colors

| Token | Value | Usage |
|-------|-------|-------|
| `glass` | `rgba(148, 50, 251, 0.05)` | Glass surfaces |
| `glass-hover` | `rgba(148, 50, 251, 0.1)` | Hover state |
| `border` | `rgba(255, 255, 255, 0.07)` | Subtle borders |
| `border-bright` | `rgba(255, 255, 255, 0.15)` | Emphasized borders |

---

## 🔤 Typography

### Font Families

```css
--font-sans: 'Plus Jakarta Sans', system-ui, sans-serif;
--font-serif: 'Cormorant Garamond', Georgia, serif;
--font-mono: 'Space Mono', 'Courier New', monospace;
```

### Font Weights

| Weight | Value | Usage |
|--------|-------|-------|
| Light | 300 | Subtle text |
| Regular | 400 | Body text |
| Semibold | 600 | Emphasis |
| Bold | 700 | Headings, CTAs |
| Extrabold | 800 | Hero headings |

### Type Scale

| Token | Size | Line Height | Usage |
|-------|------|-------------|-------|
| `text-xs` | 12px | 1.5 | Labels, badges |
| `text-sm` | 14px | 1.5 | Small text |
| `text-base` | 16px | 1.6 | Body text |
| `text-lg` | 18px | 1.5 | Large body |
| `text-xl` | 20px | 1.4 | Subheadings |
| `text-2xl` | 24px | 1.3 | Section headings |
| `text-3xl` | 30px | 1.2 | Large headings |
| `text-4xl` | 36px | 1.1 | Display |
| `text-5xl` | 48px | 1.1 | Hero |
| `text-6xl` | 60px | 1 | Large hero |
| `text-7xl` | 72px | 1 | Giant display |

### Letter Spacing

| Token | Value | Usage |
|-------|-------|-------|
| `tracking-tight` | -0.02em | Large headings |
| `tracking-normal` | 0 | Body text |
| `tracking-wide` | 0.025em | Labels |
| `tracking-widest` | 0.1em | Uppercase labels |

---

## 📐 Spacing System

### Base Unit: 4px

| Token | Size | Usage |
|-------|------|-------|
| `space-0` | 0 | - |
| `space-1` | 4px | Tight spacing |
| `space-2` | 8px | Small gaps |
| `space-3` | 12px | Medium gaps |
| `space-4` | 16px | Standard padding |
| `space-5` | 20px | Section gaps |
| `space-6` | 24px | Card padding |
| `space-8` | 32px | Large gaps |
| `space-10` | 40px | Section padding |
| `space-12` | 48px | Large sections |
| `space-16` | 64px | Hero spacing |
| `space-20` | 80px | Page sections |
| `space-24` | 96px | Major sections |

---

## 🔲 Border Radius

| Token | Size | Usage |
|-------|------|-------|
| `rounded-none` | 0 | Sharp corners |
| `rounded-sm` | 4px | Subtle rounding |
| `rounded` | 8px | Standard |
| `rounded-md` | 12px | Medium |
| `rounded-lg` | 16px | Cards |
| `rounded-xl` | 20px | Large cards |
| `rounded-2xl` | 24px | Modals |
| `rounded-full` | 9999px | Pills, circles |

---

## 🌊 Shadows & Effects

### Box Shadows

```css
/* Subtle elevation */
--shadow-sm: 0 2px 8px rgba(0, 0, 0, 0.3);

/* Standard card */
--shadow-md: 0 4px 16px rgba(0, 0, 0, 0.4);

/* Elevated card */
--shadow-lg: 0 8px 32px rgba(0, 0, 0, 0.5);

/* Glow effects */
--glow-rare: 0 0 30px rgba(148, 50, 251, 0.35), 0 0 80px rgba(148, 50, 251, 0.1);
--glow-pink: 0 0 30px rgba(246, 51, 255, 0.35), 0 0 80px rgba(246, 51, 255, 0.1);
```

### Glass Effect

```css
.glass-surface {
  background: rgba(148, 50, 251, 0.05);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.07);
}
```

### Noise Overlay

```css
/* Apply to body for texture */
body::before {
  content: "";
  position: fixed;
  inset: 0;
  background-image: url("data:image/svg+xml,...");
  pointer-events: none;
  z-index: 9999;
  opacity: 0.35;
}
```

---

## ⚡ Animations

### Timing Functions

| Token | Value | Usage |
|-------|-------|-------|
| `ease-default` | `cubic-bezier(0.4, 0, 0.2, 1)` | Standard |
| `ease-in` | `cubic-bezier(0.4, 0, 1, 1)` | Enter |
| `ease-out` | `cubic-bezier(0, 0, 0.2, 1)` | Exit |
| `ease-bounce` | `cubic-bezier(0.68, -0.55, 0.265, 1.55)` | Playful |

### Durations

| Token | Value | Usage |
|-------|-------|-------|
| `duration-fast` | 150ms | Quick feedback |
| `duration-normal` | 300ms | Standard |
| `duration-slow` | 500ms | Deliberate |
| `duration-slower` | 700ms | Emphasis |

### Predefined Animations

```css
/* Gradient flow */
@keyframes gradientFlow {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}

/* Float effect */
@keyframes floatY {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-14px); }
}

/* Glow pulse */
@keyframes glowPulse {
  0%, 100% { opacity: 0.35; }
  50% { opacity: 0.85; }
}

/* Coin glow cycle */
@keyframes coinGlow {
  0% { box-shadow: 0 0 60px rgba(246, 51, 255, 0.35), 0 0 120px rgba(148, 50, 251, 0.2); }
  33% { box-shadow: 0 0 60px rgba(148, 50, 251, 0.35), 0 0 120px rgba(50, 53, 251, 0.2); }
  66% { box-shadow: 0 0 60px rgba(50, 53, 251, 0.35), 0 0 120px rgba(50, 153, 251, 0.2); }
  100% { box-shadow: 0 0 60px rgba(246, 51, 255, 0.35), 0 0 120px rgba(148, 50, 251, 0.2); }
}

/* Shimmer */
@keyframes shimmer {
  0% { background-position: -200% center; }
  100% { background-position: 200% center; }
}

/* Pulse dot */
@keyframes pulseDot {
  0%, 100% { transform: scale(1); opacity: 1; }
  50% { transform: scale(1.8); opacity: 0; }
}
```

---

## 🧩 Component Tokens

### Buttons

| Variant | Background | Text | Border |
|---------|------------|------|--------|
| **Primary** | `gradient-iridescent` | `white` | none |
| **Secondary** | `glass` | `text` | `border` |
| **Ghost** | transparent | `text` | none |
| **Danger** | `red-600` | `white` | none |

### Button Sizes

| Size | Padding | Font Size | Border Radius |
|------|---------|-----------|---------------|
| `sm` | `8px 16px` | `12px` | `rounded-full` |
| `md` | `12px 24px` | `14px` | `rounded-full` |
| `lg` | `16px 32px` | `16px` | `rounded-full` |

### Cards

```css
.card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 16px;
  padding: 24px;
}

.card-glass {
  background: rgba(148, 50, 251, 0.05);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.07);
  border-radius: 16px;
}
```

### Inputs

```css
.input {
  background: var(--color-deep);
  border: 1px solid var(--color-border);
  border-radius: 12px;
  padding: 12px 16px;
  color: var(--color-text);
}

.input:focus {
  border-color: var(--color-rare);
  box-shadow: 0 0 0 3px rgba(148, 50, 251, 0.2);
}
```

---

## 🌐 Internationalization (i18n)

### Chrome Translation

Chrome automatically translates pages, but has limitations:
- ✅ Static text content
- ❌ Dynamic content loaded via JS
- ❌ Crypto-specific terms (may translate incorrectly)
- ❌ User wallet addresses

### Recommended i18n Implementation

For full control, use **next-intl** or **next-i18next**:

```bash
npm install next-intl
```

### Language Files Structure

```
/locales
├── en/
│   ├── common.json
│   ├── claims.json
│   ├── staking.json
│   └── lottery.json
├── es/
│   ├── common.json
│   └── ...
├── zh/
│   └── ...
└── ja/
    └── ...
```

### Translation Keys Example

```json
// locales/en/claims.json
{
  "title": "Claim Your RARE",
  "streak": {
    "title": "Your Streak",
    "days": "{{count}} days",
    "bonus": "+{{bonus}}% bonus",
    "reset": "Streak resets if you miss a day!"
  },
  "eligibility": {
    "title": "Eligibility Check",
    "tier1": "Manual Whitelist",
    "tier2": "Hold {{amount}} RARE",
    "tier3": "Own a Basename"
  }
}
```

### Implementation

```typescript
// app/[locale]/layout.tsx
import { NextIntlClientProvider } from 'next-intl';
import { getMessages } from 'next-intl/server';

export default async function RootLayout({ params: { locale } }) {
  const messages = await getMessages();
  
  return (
    <html lang={locale}>
      <body>
        <NextIntlClientProvider messages={messages}>
          {children}
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
```

```tsx
// components/ClaimCard.tsx
import { useTranslations } from 'next-intl';

export function ClaimCard() {
  const t = useTranslations('claims');
  
  return (
    <div>
      <h2>{t('title')}</h2>
      <p>{t('streak.days', { count: 30 })}</p>
    </div>
  );
}
```

### Supported Languages (Initial)

| Code | Language | Priority |
|------|----------|----------|
| `en` | English | ✅ Default |
| `es` | Spanish | 🟡 Phase 2 |
| `zh` | Chinese | 🟡 Phase 2 |
| `ja` | Japanese | 🟡 Phase 2 |
| `ko` | Korean | 🟢 Phase 3 |
| `pt` | Portuguese | 🟢 Phase 3 |
| `de` | German | 🟢 Phase 3 |

### Static vs Dynamic Translation

| Approach | When to Use |
|----------|-------------|
| **Chrome Translation** | MVP launch, static content |
| **next-intl** | Full i18n control, dynamic content |

**Recommendation:** Launch with Chrome translation, add next-intl in Phase 2 for better UX.

---

## 📱 Responsive Breakpoints

| Breakpoint | Width | Usage |
|------------|-------|-------|
| `sm` | 640px | Mobile landscape |
| `md` | 768px | Tablets |
| `lg` | 1024px | Desktop |
| `xl` | 1280px | Large desktop |
| `2xl` | 1536px | Extra large |

---

## ♿ Accessibility

### Color Contrast

- Text on dark: Minimum 4.5:1 contrast ratio
- Large text: Minimum 3:1 contrast ratio
- Interactive elements: Minimum 3:1 against background

### Focus States

```css
:focus-visible {
  outline: 2px solid var(--color-rare);
  outline-offset: 2px;
}
```

### Motion Preferences

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## 📁 File Structure

```
/src
├── styles/
│   ├── globals.css          ← Tailwind + custom utilities
│   ├── variables.css        ← CSS custom properties
│   └── animations.css       ← Keyframes
├── components/
│   ├── ui/                  ← Base components
│   │   ├── Button.tsx
│   │   ├── Card.tsx
│   │   ├── Input.tsx
│   │   └── Badge.tsx
│   └── layout/              ← Layout components
│       ├── Header.tsx
│       ├── Footer.tsx
│       └── Sidebar.tsx
└── lib/
    └── design-tokens.ts     ← JS/TS tokens
```

---

## 🔗 Resources

- **Figma:** (Link to design file)
- **Storybook:** (Link to component library)
- **Tailwind Config:** `tailwind.config.ts`

---

*Design System v1.0*
*Last Updated: 2026-03-01*
*Created by: Felix - Director of Rare Enterprises*
