# Better Bet iOS App - Claude Code Guide

## Project Overview

Better Bet is an iOS-native social accountability app where friends pool money to enforce fitness habits through HealthKit-verified commitment contracts. Users pledge/stake money on fitness goals (weekly steps, distance, calories), and those who fail forfeit their stake to successful participants.

**CRITICAL - Semantic Firewall:**
- **FORBIDDEN terms:** Bet, Wager, Gamble, Win, Lose
- **APPROVED terms:** Pledge, Stake, Commitment, Pot, Challenge, Fulfill, Fail

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
    ├── CreatePledge/             # Challenge creation flow
    └── StepTracking/             # Activity tracking views
```

## Build & Run

1. Open project in Xcode 16+
2. Enable HealthKit capability in Signing & Capabilities
3. Build: `Cmd + B`
4. Run on physical device: `Cmd + R`

**Note:** HealthKit requires a physical device. Simulator uses mock data.

## Design System - "Clean Athletic"

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
    ├── Pledge tab → CreatePledgeView
    └── History tab → PlaceholderView
```

## Key Models

**Pledge** (primary model):
- ChallengeType: `steps`, `distance`, `activeEnergy`
- PledgeStatus: `pending`, `active`, `completed`, `failed`, `cancelled`

**HealthManager** ("The Oracle"):
- Single source of truth for health data
- Handles HealthKit authorization
- Tracks: weekly steps, daily breakdown, distance, active energy

## Development Conventions

1. Always use semantic firewall terminology in UI and code comments
2. Use design system components from `DesignSystem.swift`
3. Provide mock data for all models (e.g., `Pledge.mockStepChallenge`)
4. Portrait orientation only
5. HealthKit access is read-only for verification

## Current Status

**Implemented:**
- Design system with Clean Athletic modifiers
- Onboarding flow (3 slides)
- Dashboard with leaderboard
- Step tracking with HealthKit integration
- Progress bars and status badges

**Not Yet Implemented:**
- CloudKit sync
- Push notifications
- Payment integration
- Complete challenge creation flow
