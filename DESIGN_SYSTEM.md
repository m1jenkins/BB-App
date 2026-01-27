# Better Bet — Design System

> **"Put your money where your health is."**

## Design Pillars

1. **Trust beats hype** — Money screens must feel calm, legible, and receipt-like
2. **Competition is entertainment** — Leaderboards, deltas, and "pace to win" everywhere
3. **Verification is integrity** — Always show data source + read-only status
4. **Dark-first, high contrast** — Design primarily for dark mode, ~7:1 contrast ratio
5. **Minimal UI, loud attitude** — "Liquid Death" energy in headlines/badges, not clutter

---

## Color Tokens (Semantic)

Use iOS system colors for automatic adaptation. Never hardcode.

| Token | Purpose | Dark Mode |
|-------|---------|-----------|
| `bgPrimary` | Main background | Near-black (OLED) |
| `bgSecondary` | Secondary panels | Deep charcoal |
| `surface` | Cards, sheets | Charcoal |
| `textPrimary` | Main text | Off-white |
| `textSecondary` | Secondary text | Gray |
| `divider` | Separators | Subtle gray |
| `accent` | CTAs, highlights | Money Lime (#BFFF00) |
| `danger` | Failed, insufficient | System red |
| `success` | Complete, verified | System green |

### Rules
- ONE accent color per screen maximum
- Money/security UI never relies on color alone — pair with labels/icons
- Use `accent` for: "Join", "Deposit", "Cash out", positive deltas, progress

---

## Typography

**Font:** SF Pro (system default) with Dynamic Type support

| Style | Usage |
|-------|-------|
| Large Title | Premium screen titles (rare) |
| Title | Section headers |
| Body | Primary copy |
| Caption | Metadata, timestamps |
| Monospaced | Money, countdowns, deltas |

### Rules
- ONE display headline per screen max
- All numbers in money/leaderboard contexts use monospaced digits

---

## Spacing & Layout

- **Grid:** 8pt
- **Card padding:** 12–16pt
- **Screen margins:** 16–20pt
- **Corner radius:**
  - Chips/pills: 10–12
  - Cards: 16
  - Primary buttons: 14–16
- **Shadows:** Minimal — rely on tonal separation

---

## Components

### Challenge Card
Answers: "What's the challenge? What's the pot? Where do I stand?"
- Challenge name (poster-style)
- Mode pill: Steps / Distance / Active Minutes
- Pot amount (big, monospaced)
- Time remaining (countdown)
- Progress bar + "pace to win"
- Rank chip (#2 of 8)
- Primary CTA

### Leaderboard Row
- Rank + Avatar + Name
- Metric value (monospaced)
- Delta to next rank (±)
- Today status: "Logged" / "No activity"

### Pace to Win Module
- "You need X/day"
- Status: On track / Behind / Ahead
- One-tap action: "Start workout"

### Wallet Summary
- Available balance
- Linked payment
- Pending transfers
- Deposit / Withdraw CTAs
- Always show status labels + timestamps

### Transaction Receipt
Every money event shows:
- Amount + Status
- From/To usernames
- Challenge reference
- Timestamp + Fee disclosure
- Support link

### Verification Panel
- Connected sources (Apple Health)
- Read-only badge
- Last sync time
- Flags for manual entries

---

## Voice & Tone

**Confident, witty, slightly ruthless.** Never unclear on money/security.

| Context | Example |
|---------|---------|
| Empty state | "No challenges yet. Start one and make it hurt (a little)." |
| Behind pace | "You're behind. Earn it back today." |
| Verification | "Read-only data. No manual entry. No excuses." |
| CTA | "Deposit $25" not "Continue" |

---

## Accessibility

- All text respects Dynamic Type
- Test with Increase Contrast enabled
- No truncated money amounts
- ~7:1 contrast for small text in dark mode

---

## Navigation (5 Tabs)

1. **Home** — Challenge feed
2. **Challenges** — Browse/filter
3. **Create (+)** — Commissioner flow
4. **Wallet** — Money layer
5. **Profile** — Settings, history

---

## Do / Don't

| ✅ DO | ❌ DON'T |
|-------|---------|
| Use cards/chips/receipts for structure | Use playful visuals on money confirmations |
| Keep money UI calm and consistent | Hide rules behind extra taps |
| Show "pace to win" above the fold | Imply manual workouts count |
| Show verification status with results | Use more than one accent per screen |
