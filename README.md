# Better Bet

**Social accountability app where friends pool money to enforce habits.**

*"Liquid Death meets Strava" - Irreverent, high-stakes, brutally honest.*

## The Concept

Better Bet is a **commitment contract platform**, NOT a gambling app. Users pledge money on their fitness goals (like weekly step targets). If they fail to meet their commitment, their stake goes into the pot. Survivors split the proceeds.

**The Mechanism:** "Profit from Friends' Failure"
- Users pledge/stake money on a challenge
- HealthKit verifies goal completion automatically
- Those who fail forfeit their stake
- Survivors split the pot

## Semantic Firewall

This app strictly avoids gambling terminology for compliance:

| Approved Terms | Forbidden Terms |
|---------------|-----------------|
| Pledge, Stake | Bet, Wager |
| Commitment | Gamble |
| Pot (pooled stakes) | Winnings |
| Fulfill / Fail | Win / Lose |
| Survivors | Winners |

## Tech Stack

- **Language:** Swift 6.0
- **Framework:** SwiftUI
- **Data/Storage:** SwiftData + CloudKit
- **Integrations:** HealthKit (Read-only: Steps, Workouts)
- **Architecture:** MVVM with Manager layer

## Design System - "Chunky Retro" / Neo-Brutalist

### Colors
| Name | Hex | Usage |
|------|-----|-------|
| Background | `#F9F7F1` | Primary app background (cream) |
| Ink Black | `#050505` | Borders, text, icons |
| Mustard | `#F4D03F` | Accents, hard shadows |
| Alert Red | `#FF453A` | Failed states |
| Money Green | `#00A86B` | Pot values, success |

### Typography
- **Headlines:** System Serif (Black weight) - Cooper Black vibe
- **Body:** System Rounded (Medium weight) - DM Sans vibe

### UI Components
- **Borders:** 3px solid ink black
- **Shadows:** Hard drop shadow (4, 4, 0 blur) in ink black or mustard
- **Corner Radius:** Minimal (4-8px) or sharp (0px)

## Project Structure

```
BetterBet/
├── Sources/
│   ├── App/
│   │   └── BetterBetApp.swift       # App entry point
│   ├── DesignSystem/
│   │   └── DesignSystem.swift       # Colors, typography, modifiers
│   ├── Views/
│   │   ├── Onboarding/
│   │   │   └── OnboardingView.swift # "The Hook" - 3-slide intro
│   │   ├── Dashboard/
│   │   │   └── DashboardView.swift  # Weekly challenge view
│   │   └── Components/              # Reusable UI components
│   ├── Managers/
│   │   └── HealthManager.swift      # "The Oracle" - HealthKit integration
│   └── Models/
│       ├── Challenge.swift          # Challenge data model
│       └── Participant.swift        # Participant data model
└── Info.plist                       # HealthKit permissions
```

## Phase 1 Features (MVP)

- [x] Design System with Neo-Brutalist modifiers
- [x] Onboarding flow ("The Hook")
- [x] Dashboard view with leaderboard
- [x] Pot value starburst badge
- [x] Progress bars with chunky style
- [x] "Dave is Out" elimination toast
- [x] HealthManager with mock data
- [ ] CloudKit sync
- [ ] Push notifications
- [ ] Challenge creation flow
- [ ] Payment integration

## Setup

1. Open the project in Xcode 16+
2. Enable HealthKit capability in Signing & Capabilities
3. Build and run on device (HealthKit requires physical device)

## Usage Notes

The app uses dummy data in the simulator. On a physical device, it will request HealthKit authorization and fetch real step data.

## License

Proprietary - All rights reserved.
