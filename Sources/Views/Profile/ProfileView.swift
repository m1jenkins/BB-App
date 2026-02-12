//
//  ProfileView.swift
//  BetterBet
//
//  Main profile screen showing user identity, lifetime stats,
//  and quick links to settings, history, and health data.
//
//  SEMANTIC FIREWALL NOTICE:
//  - "Fulfilled" not "Won"
//  - "Failed" not "Lost"
//  - "Pledges" not "Bets"
//

import SwiftUI

// MARK: - Profile View

/// Main profile screen — Tab 4 in the app.
struct ProfileView: View {
    @AppStorage("isSignedIn") private var isSignedIn = true
    @State private var user: User = User.mock
    @State private var showSettings = false
    @State private var showChallengeHistory = false
    @State private var showSignOutConfirmation = false

    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Profile Header
                    ProfileHeaderCard(user: user)

                    // Stats Grid
                    StatsGridCard(user: user)

                    // Quick Links
                    QuickLinksSection(
                        onHistory: { showChallengeHistory = true },
                        onSettings: { showSettings = true }
                    )

                    // Sign Out
                    Button {
                        showSignOutConfirmation = true
                    } label: {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                    }
                    .buttonStyle(DestructiveButtonStyle())
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.top, DesignSystem.Spacing.sm)

                    // App version footer
                    Text("Better Bet v1.0.0")
                        .font(DesignSystem.Typography.caption(12))
                        .foregroundColor(DesignSystem.Colors.lightGray)
                        .padding(.bottom, DesignSystem.Spacing.xl)
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.top, DesignSystem.Spacing.sm)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .navigationDestination(isPresented: $showChallengeHistory) {
            ChallengeHistoryView()
        }
        .alert("Sign Out?", isPresented: $showSignOutConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                isSignedIn = false
            }
        } message: {
            Text("You'll need to sign in again to access your pledges and wallet.")
        }
    }
}

// MARK: - Profile Header Card

/// Large card showing avatar, name, member-since, and fulfillment badge.
struct ProfileHeaderCard: View {
    let user: User

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Avatar
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.mustard.opacity(0.2))
                    .frame(width: 88, height: 88)

                Circle()
                    .stroke(DesignSystem.Colors.inkBlack, lineWidth: DesignSystem.Borders.thickness)
                    .frame(width: 88, height: 88)

                Text(user.avatarEmoji)
                    .font(.system(size: 40))
            }

            // Name
            Text(user.displayName)
                .font(DesignSystem.Typography.title(24))
                .foregroundColor(DesignSystem.Colors.inkBlack)

            // Member since
            Text(user.memberSinceFormatted)
                .font(DesignSystem.Typography.caption())
                .foregroundColor(DesignSystem.Colors.inkGray)

            // Fulfillment badge
            if user.totalPledges > 0 {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 14))
                        .foregroundColor(fulfillmentColor)

                    Text("\(user.formattedFulfillmentRate) Fulfillment Rate")
                        .font(DesignSystem.Typography.label())
                        .foregroundColor(fulfillmentColor)
                }
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xxs + 2)
                .background(fulfillmentColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusSmall))
            }

            // Streak
            if user.currentStreak > 0 {
                HStack(spacing: 4) {
                    Text("🔥")
                        .font(.system(size: 14))
                    Text("\(user.currentStreak) pledge streak")
                        .font(DesignSystem.Typography.caption(13))
                        .foregroundColor(DesignSystem.Colors.inkBlack)
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(maxWidth: .infinity)
        .cleanCard()
    }

    private var fulfillmentColor: Color {
        if user.fulfillmentRate >= 80 {
            return DesignSystem.Colors.moneyGreen
        } else if user.fulfillmentRate >= 50 {
            return DesignSystem.Colors.mustard
        } else {
            return DesignSystem.Colors.alertRed
        }
    }
}

// MARK: - Stats Grid Card

/// 2x2 grid of lifetime stats.
struct StatsGridCard: View {
    let user: User

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("LIFETIME STATS")
                .font(DesignSystem.Typography.label())
                .foregroundColor(DesignSystem.Colors.inkGray)
                .tracking(1.5)
                .padding(.horizontal, DesignSystem.Spacing.md)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                    GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                ], spacing: DesignSystem.Spacing.sm
            ) {
                StatCell(
                    value: "\(user.totalPledges)",
                    label: "Total Pledges",
                    icon: "flag.fill",
                    accentColor: DesignSystem.Colors.inkBlack
                )

                StatCell(
                    value: "\(user.fulfilledPledges)",
                    label: "Fulfilled",
                    icon: "checkmark.circle.fill",
                    accentColor: DesignSystem.Colors.moneyGreen
                )

                StatCell(
                    value: user.formattedStaked,
                    label: "Total Staked",
                    icon: "dollarsign.circle.fill",
                    accentColor: DesignSystem.Colors.mustard
                )

                StatCell(
                    value: user.formattedEarnings,
                    label: "Earnings",
                    icon: "arrow.up.circle.fill",
                    accentColor: DesignSystem.Colors.moneyGreen
                )
            }
        }
    }
}

/// Single stat cell in the grid.
struct StatCell: View {
    let value: String
    let label: String
    let icon: String
    let accentColor: Color

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(accentColor)

            Text(value)
                .font(DesignSystem.Typography.data(22))
                .foregroundColor(DesignSystem.Colors.inkBlack)

            Text(label)
                .font(DesignSystem.Typography.caption(12))
                .foregroundColor(DesignSystem.Colors.inkGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardWhite)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusCard))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusCard)
                .stroke(DesignSystem.Colors.inkBlack.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Quick Links Section

/// Navigation cards for History, HealthKit, and Settings.
struct QuickLinksSection: View {
    let onHistory: () -> Void
    let onSettings: () -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            QuickLinkRow(
                icon: "clock.arrow.circlepath",
                iconColor: DesignSystem.Colors.inkBlack,
                title: "Challenge History",
                subtitle: "View past pledges and outcomes",
                action: onHistory
            )

            QuickLinkRow(
                icon: "heart.text.square.fill",
                iconColor: DesignSystem.Colors.alertRed,
                title: "HealthKit Data",
                subtitle: "Steps, distance, active minutes",
                action: {}  // Placeholder — navigates to existing StepDetail
            )

            QuickLinkRow(
                icon: "gearshape.fill",
                iconColor: DesignSystem.Colors.inkGray,
                title: "Settings",
                subtitle: "Notifications, account, preferences",
                action: onSettings
            )
        }
    }
}

/// Single quick-link row.
struct QuickLinkRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusMedium)
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(iconColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DesignSystem.Typography.body())
                        .foregroundColor(DesignSystem.Colors.inkBlack)

                    Text(subtitle)
                        .font(DesignSystem.Typography.caption(12))
                        .foregroundColor(DesignSystem.Colors.inkGray)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(DesignSystem.Colors.inkGray)
            }
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.cardWhite)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusCard))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusCard)
                    .stroke(DesignSystem.Colors.inkBlack.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Profile View") {
    NavigationStack {
        ProfileView()
    }
}

#Preview("Profile Header") {
    ProfileHeaderCard(user: .mock)
        .padding()
        .background(DesignSystem.Colors.background)
}

#Preview("Stats Grid") {
    StatsGridCard(user: .mock)
        .padding()
        .background(DesignSystem.Colors.background)
}

#Preview("Profile - New User") {
    NavigationStack {
        ProfileView()
    }
}
