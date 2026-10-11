---
name: Pocket Ledger
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e2e7ff'
  surface-container-highest: '#dae2fd'
  on-surface: '#131b2e'
  on-surface-variant: '#464555'
  inverse-surface: '#283044'
  inverse-on-surface: '#eef0ff'
  outline: '#777587'
  outline-variant: '#c7c4d8'
  surface-tint: '#4d44e3'
  primary: '#3525cd'
  on-primary: '#ffffff'
  primary-container: '#4f46e5'
  on-primary-container: '#dad7ff'
  inverse-primary: '#c3c0ff'
  secondary: '#b90538'
  on-secondary: '#ffffff'
  secondary-container: '#dc2c4f'
  on-secondary-container: '#fffbff'
  tertiary: '#003fac'
  on-tertiary: '#ffffff'
  tertiary-container: '#0555dd'
  on-tertiary-container: '#d1daff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e2dfff'
  primary-fixed-dim: '#c3c0ff'
  on-primary-fixed: '#0f0069'
  on-primary-fixed-variant: '#3323cc'
  secondary-fixed: '#ffdadb'
  secondary-fixed-dim: '#ffb2b7'
  on-secondary-fixed: '#40000d'
  on-secondary-fixed-variant: '#92002a'
  tertiary-fixed: '#dbe1ff'
  tertiary-fixed-dim: '#b4c5ff'
  on-tertiary-fixed: '#00174b'
  on-tertiary-fixed-variant: '#003ea8'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fd'
typography:
  display-currency:
    fontFamily: Inter
    fontSize: 34px
    fontWeight: '700'
    lineHeight: 42px
    letterSpacing: -0.02em
  display-currency-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.015em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 17px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.005em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: -0.005em
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0em
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
    letterSpacing: 0.005em
  amount-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.01em
  amount-md:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-mobile: 0.75rem
  margin: 1rem
  margin-tablet: 1.5rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
  space-2xl: 2rem
---

## Brand & Style

This design system defines an ultra-crisp, disciplined Korean personal finance experience. It bridges the frictionless immediacy of modern fintech super-apps (Toss, BankSalad) with the meticulous ledger precision demanded by traditional household account books (편한가계부).

### Personality & Tone
- **Transparent & Uncluttered:** Data is structured with high clarity, reducing financial anxiety through calm, neutral surfaces and breathing room.
- **Pragmatic Precision:** Financial records demand zero ambiguity. Numbers, status tags, and transaction paths read with instant legibility.
- **Effortless Control:** Interactions feel lightweight, immediate, and tactically responsive, encouraging daily record-keeping without cognitive friction.

### Visual Architecture
The visual style operates on **Elevated Precision Minimalism**. Surfaces rely on clean porcelain and slate foundations, punctuated by distinct functional semantic cues rather than ornamental decoration. Visual noise is eliminated; hierarchy is established through tabular numerical weight, deliberate spatial separation, and targeted color coding for cash flows.

## Colors

The palette balances clinical financial clarity with immediate categorical recognition. Backgrounds stay quiet, allowing monetary amounts and flow classifications to drive user orientation.

### Semantic Transaction Colors
- **Primary Brand / Core Action (`#4F46E5`):** Reserved for high-intent actions, primary confirmations, and key interface anchors.
- **Expense / 지출 (`#F43F5E`):** Energetic rose-coral signaling outgoing capital. Paired with soft tint backgrounds (`#FFF1F2`) for badges and list highlights.
- **Income / 수입 (`#2563EB`):** High-trust primary blue representing inflows. Paired with tint backgrounds (`#EFF6FF`).
- **Transfer / 이체 (`#0D9488`):** Balanced slate-teal indicating capital reallocation between accounts rather than net gain or loss. Paired with tint backgrounds (`#F0FDFA`).

### Canvas & Neutral Hierarchy
- **Canvas Base (`#F8FAFC`):** Soft cool porcelain tone preventing stark screen glare during frequent daily balance checking.
- **Surface Pure (`#FFFFFF`):** Base layer for interactive cards, sheets, and grouped data containers.
- **Text Primary (`#0F172A`):** Deep slate-black providing high-contrast readability for transaction names and primary currency values.
- **Text Secondary (`#64748B`):** Muted slate for metadata, timestamps, account sources, and supporting calculations.
- **Structural Dividers & Outlines (`#E2E8F0` / `#F1F5F9`):** Subtle hairpins separating transactional rows and framing inputs.

## Typography

The type system prioritizes balanced bilingual rendering (Korean Hangul alongside Latin figures) and strict alignment for numeric values.

### Korean & Numeric Pairing Rules
- When Inter is rendered, fallback stacks must map to `Pretendard`, `-apple-system`, `BlinkMacSystemFont`, and `Apple SD Gothic Neo` to guarantee uniform character heights between Hangul glyphs and Latin numerals.
- **Tabular Lining Figures:** All numerical amounts (KRW amounts, dates, percentages) must enforce tabular lining features (`font-feature-settings: "tnum" 1`). This maintains vertical column consistency in transaction histories and daily summaries.
- **Currency Affixes:** The Korean Won symbol (`₩`) or suffix (`원`) must stay visually anchored. For top-level balance cards, the currency unit renders at `headline-md` weight when paired with `display-currency`, preventing visual overpowering of the actual monetary value.

## Layout & Spacing

Pocket Ledger relies on a single-column, touch-optimized fluid layout on mobile devices, transitioning to a maximum content-constrained shell on wider devices.

### Mobile Grid & Safety
- **Canvas Boundaries:** Default horizontal margins are fixed at `1rem` (16px) on mobile viewports to preserve edge-to-edge space for complex financial rows.
- **Touch Target Integrity:** Every interactive ledger element—including transaction edit buttons, date pickers, and filter chips—enforces an absolute minimum hit-target size of 44x44px, padded internally using `space-xs` and `space-sm`.
- **Vertical Ledger Rhythm:** List items enforce a compact 8px vertical grid. Daily summary section headers use `space-xl` top margin separation to group expenditures naturally without requiring heavy container nesting.
- **Sheet Overlays & Modals:** Transaction quick-entry views trigger as bottom-up bottom sheets capped at a maximum width of 480px, centered horizontally on tablet resolutions.

## Elevation & Depth

This design system avoids exaggerated drop shadows and deep perspective blurs, utilizing flat tonal layering and whisper-soft ambient contacts.

### Tiers of Depth
- **Level 0 (Canvas Base):** Plain `#F8FAFC`. Houses background groupings, timeline spines, and empty ledger regions.
- **Level 1 (Card & Group Container):** Pure `#FFFFFF` surfaces sitting directly on the canvas, outlined with a 1px boundary of `#E2E8F0` or `#F1F5F9`. No shadow required; separation is purely tonal.
- **Level 2 (Floating Action & Overlays):** Used for bottom transaction input triggers, quick numeric keypads, and dropdown category menus:
  - `box-shadow: 0px 4px 16px -2px rgba(15, 23, 42, 0.06), 0px 2px 4px -1px rgba(15, 23, 42, 0.04);`
- **Level 3 (Modal Bottom Sheets):** Full bottom sheets for transaction editing, accompanied by a 40% `#0F172A` scrim overlay:
  - `box-shadow: 0px -8px 24px -4px rgba(15, 23, 42, 0.08);`

### Inset & Micro Depth
Input fields and segment rails utilize a subtle inner surface wash (`#F1F5F9`) with no inner shadow, ensuring an uncluttered, modern matte finish.

## Shapes

The geometric framework establishes soft, human-friendly corners while maintaining crisp data boundaries.

### Border Radius Application
- **Surfaces & Cards (`12px` - `16px`):** Primary overview balance cards, monthly spend cards, and daily ledger containers use `16px` radii (`rounded-lg`). Nested summary blocks inside cards use `12px`.
- **Interactive Controls (`8px` - `10px`):** Numeric keypad keys, standard form inputs, and segment pill items use `8px` (`rounded`).
- **Tags, Chips & Indicators (`9999px`):** Transaction type badges ([지출], [수입], [이체]), project filters, and bottom action triggers employ full pill geometry to contrast distinctly against rectangular content rows.
- **Divider Lines:** 1px width with no corner smoothing, terminating with horizontal inset matching component internal margins.

## Components

### Segmented Flow Control (`[지출 | 수입 | 이체]`)
- **Structure:** 3-way toggle container with `#F1F5F9` background, 4px internal padding, and an 8px border radius.
- **Selected State:** Pure `#FFFFFF` pill with a micro ambient shadow (`0 1px 3px rgba(0,0,0,0.08)`).
- **Text & Accent:** Active text transitions to the target semantic token (Rose for 지출, Blue for 수입, Teal for 이체) in `headline-sm` weight; inactive states stay in `Text Secondary` (`#64748B`).

### Transaction List Items & Date Group Headers
- **Date Group Header:** Sticky bar rendering Day + Day of Week on the left (`headline-sm`, `#0F172A`), and Net Daily Total on the right (`amount-md`, colored dynamically by net balance: red for net negative, blue for net positive).
- **Item Row:**
  - Left: 36x36px rounded-full icon container tinted with category color.
  - Center: Vertical stack containing transaction title (`body-lg`, `#0F172A`) and payment asset/memo (`body-sm`, `#64748B`).
  - Right: Tabular amount (`amount-lg`) with sign prefix (`-` or `+`) colored strictly via semantic tokens.
  - Border: 1px `#F1F5F9` hairline bottom divider, inset by 56px to preserve icon gutter continuity.

### Buttons & Keypads
- **Primary Action Button:** 52px height, full-width or pill-shaped, `#4F46E5` background, `#FFFFFF` text, `headline-sm`. Hover/pressed states dim background by 8%.
- **Keypad Entry Panel:** 3x4 grid for currency input. Keys are borderless flat tiles with `#0F172A` numbers in `display-currency-mobile` scale, emitting subtle haptic feedback and instant touch highlighting (`#E2E8F0`).

### Chips & Filter Tags
- **Filter Chips:** 32px height, pill-shaped (`rounded-full`), `#FFFFFF` background with 1px `#E2E8F0` border.
- **Selected Filter Chip:** `#1E293B` background with `#FFFFFF` text and no border.
- **Category Icon Badges:** Small 24px pill tags displaying category names alongside micro icons with 10% opacity semantic fills.

### Form Inputs
- **Amount Input Display:** Single-line, right-aligned or center-aligned, borderless input with bold zero-state placeholder (`#CBD5E1`). Includes dynamic `원` suffix that scales alongside type size.
- **Standard Input Fields:** 48px height, 1px `#E2E8F0` outline, 8px radius, white surface. Focus shifts border to `#4F46E5` with zero outer glow.

### Bottom Navigation Bar
- **Configuration:** 5 pinned destinations: 홈 (Home), 내역 (Transactions), 분석 (Analytics), 프로젝트 (Projects), 설정 (Settings).
- **Dimensions:** 56px height + dynamic bottom safe-area padding.
- **Styling:** Frosted white container (`#FFFFFF` with 95% opacity and `backdrop-filter: blur(12px)`), separated by a 1px top border of `#E2E8F0`.
- **Active State:** Icon and label in `#0F172A` with a micro 4px indigo dot indicator underneath; inactive items render in `#94A3B8`.