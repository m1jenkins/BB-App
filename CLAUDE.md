# Better Bet iOS App - Claude Code Guide

**"Put Your Money Where Your Health Is"**

## Project Overview

Better Bet is the **premier social commitment platform** that turns fitness goals into competitive, high-stakes fun. By combining behavioral psychology (loss aversion) with social accountability, Better Bet ensures users stick to their workout plans—because nothing motivates quite like the prospect of taking money from your friends.

**Core Philosophy:** Willpower is finite, but incentives are powerful. Better Bet isn't just a fitness tracker; it's an **accountability engine** that replaces "I should work out" with "I can't afford not to work out."

**CRITICAL - Semantic Firewall:**
- **FORBIDDEN terms:** Bet, Wager, Gamble, Win, Lose
- **APPROVED terms:** Pledge, Stake, Commitment, Pot, Challenge, Fulfill, Fail, Survivors

## How It Works

1. **Create the Challenge** - A user acts as the "Commissioner," setting challenge parameters, duration (weekend, week, or month), and wager amount
2. **Invite the Squad** - Friends join the lobby; the pot grows as more people accept
3. **Sweat it Out** - Users perform activities with automatic verification (no manual entry, no honor system)
4. **The Payout** - At the deadline, data syncs; survivors split the pot, and those who missed the mark pay the price

## Launch Game Modes

Better Bet launches with three accessible, verifiable game modes:

| Mode | Display Name | Best For | Metric |
|------|-------------|----------|--------|
| `steps` | 👟 Step Showdown | Everyone (office workers, walkers, casual active users) | Cumulative steps or highest daily average |
| `distance` | 🏃 Distance Derby | Runners, cyclists, hikers | Total miles covered (can filter by activity type) |
| `activeMinutes` | ⏱️ Active Zone | Gym-goers, CrossFitters, yoga practitioners, HIIT enthusiasts | Minutes of elevated heart-rate activity |

## Verification Engine

**"If it's not tracked, it didn't happen."**

| Integration | Description |
|-------------|-------------|
| Apple Health | Seamless integration for iPhone and Apple Watch users |
| Garmin Connect | Deep data integration for serious athletes (planned) |
| Strava | Social fitness community, devices syncing to Strava count (planned) |

**Anti-Cheat:** Utilizes health kit metadata to flag manual entries or overlapping data.

## Tech Stack

| Component | Technology |
|-----------|------------|
| Language | Swift 6.0 |
| UI Framework | SwiftUI |
| Data Storage | SwiftData + CloudKit (planned) |
| Health Integration | HealthKit (read-only) |
| Architecture | MVVM + Manager Layer |
| Build System | Xcode 16+ |
| Target | iOS 17+, physical device for HealthKit |

## Directory Structure

```
Sources/
├── App/
│   └── BetterBetApp.swift        # Main entry point, tab navigation
├── DesignSystem/
│   └── DesignSystem.swift        # "Clean Athletic" design tokens
├── Models/
│   ├── Challenge.swift           # Legacy challenge model
│   ├── Participant.swift         # User participation data
│   └── Pledge.swift              # Core model for fitness commitments
├── Managers/
│   ├── HealthManager.swift       # HealthKit integration ("The Oracle")
│   └── PledgeManager.swift       # Pledge creation/management
└── Views/
    ├── Onboarding/               # 3-slide intro ("The Hook")
    ├── Dashboard/                # Main challenge leaderboard
    ├── CreatePledge/             # Challenge creation flow (Commissioner)
    └── StepTracking/             # Activity tracking views
```

## Build & Run

1. Open project in Xcode 16+
2. Enable HealthKit capability in Signing & Capabilities
3. Build: `Cmd + B`
4. Run on physical device: `Cmd + R`

**Note:** HealthKit requires a physical device. Simulator uses mock data.

## Design Systems

### "Clean Athletic" (Original) - `DesignSystem.swift`

**Colors:**
- Background: `#F9F7F1` (warm cream)
- Ink Black: `#050505` (primary text, borders)
- Mustard: `#F4D03F` (accents, highlights)
- Alert Red: `#FF453A` (failed states)
- Money Green: `#00A86B` (pot values, success)
- Ink Gray: `#6B6B6B` (secondary text)

**Pre-built Components:**
- `cleanCard()` modifier - 2px border, subtle shadow
- `PrimaryButtonStyle` - black fill, white text
- `SecondaryButtonStyle` - outline style
- `ChunkyButtonStyle` - brutalist with hard shadow (onboarding)
- `ProgressBar` - clean progress visualization
- `PotBadge` - circular green badge for pot amounts
- `StatusBadge` - ON TRACK, AT RISK, FAILED, COMPLETE

**Typography:**
- Headlines: System Serif (black weight)
- Body: System Sans (medium weight)

**Spacing:** xxs: 4, xs: 8, sm: 12, md: 16, lg: 24, xl: 32, xxl: 48

---

### "Industrial Pop" (Neo-Brutalist) - `IndustrialPopDesignSystem.swift`

**Design Philosophy:** Stark, high-stakes, utilitarian - like financial contracts and physical receipts.

**Semantic Color Tokens:**
- `IndustrialPop.Colors.surfaceMain` - #F2F2F2 (Ghost White)
- `IndustrialPop.Colors.surfaceCard` - #FFFFFF (Pure White)
- `IndustrialPop.Colors.textStrong` - #000000 (Jet Black)
- `IndustrialPop.Colors.brandAccent` - #D6FF00 (Safety Yellow)

**Anti-Design Rules:**
- Border radius: 0px EVERYWHERE
- Borders: 3px solid black (thick), 2px (standard)
- Shadows: Hard offset only (4px 4px 0px #000) - NO BLUR

**Typography:**
- ALL fonts: Monospace (system `.monospaced`)
- Headlines: Massive, uppercase, extra heavy weight (800-900)
- Body: Uppercase preferred for machine-like feel

**Pre-built Components:**
- `IndustrialLayoutWrapper` - Wrapper enforcing Industrial Pop styling
- `IndustrialNav` - Monospaced navigation header
- `.industrial` / `.industrialSecondary` - Button styles with hard shadows
- `.receiptCard()` modifier - Thick border + hard shadow
- `.hardShadow()` modifier - 4px offset black shadow
- `.thickBorder()` modifier - 3px solid black border
- `ZigzagEdge` - Shape for torn receipt effect
- `DitheredAvatarView` - B&W halftone-style avatars

**PlaceBet Screen Components:**
- `CollateralInputSection` - Massive currency input with yellow underline
- `TermsReceiptCard` - Contract terms with zigzag bottom edge
- `PeerPressureSection` - Grid of dithered B&W avatars

## Architecture Patterns

- **MVVM with Manager Layer** - Views → Managers → Models
- **@Observable** macro for manager reactivity
- **@AppStorage** for persistent flags (e.g., `hasCompletedOnboarding`)
- **SwiftData** models decorated with `@Model` macro
- **Preview-driven development** using `#Preview` macros

**Navigation Structure:**
```
OnboardingView (if !hasCompletedOnboarding)
└── MainTabView (4 tabs)
    ├── Challenge tab → DashboardView
    ├── Activity tab → StepDetailView
    ├── Pledge tab → CreatePledgeView (Commissioner flow)
    └── History tab → PlaceholderView
```

## Key Models

**Pledge** (primary model):
- ChallengeType: `steps`, `distance`, `activeMinutes`
- PledgeStatus: `pending`, `active`, `completed`, `failed`, `cancelled`
- Each type has `gameModeName` (Step Showdown, Distance Derby, Active Zone)

**HealthManager** ("The Oracle"):
- Single source of truth for health data
- Handles HealthKit authorization
- Tracks: weekly steps, daily breakdown, distance, active minutes

## Development Conventions

1. Always use semantic firewall terminology in UI and code comments
2. Use design system components from `DesignSystem.swift`
3. Provide mock data for all models (e.g., `Pledge.mockStepChallenge`)
4. Portrait orientation only
5. HealthKit access is read-only for verification
6. Use game mode display names in UI (Step Showdown, Distance Derby, Active Zone)

## Current Status

**Implemented:**
- Design system with Clean Athletic modifiers
- Onboarding flow (3 slides) with new messaging
- Dashboard with leaderboard showing game modes
- Step tracking with HealthKit integration
- Progress bars and status badges
- Three launch game modes (Steps, Distance, Active Minutes)

**Not Yet Implemented:**
- CloudKit sync
- Push notifications
- Payment integration
- Complete Commissioner challenge creation flow
- Garmin Connect integration
- Strava integration
