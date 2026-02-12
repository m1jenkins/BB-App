//
//  SettingsView.swift
//  BetterBet
//
//  Settings screen with notification preferences, health data,
//  account management, and about/legal sections.
//
//  SEMANTIC FIREWALL NOTICE:
//  - "Pledge reminders" not "bet reminders"
//  - "Commitment alerts" not "gambling alerts"
//

import SwiftUI

// MARK: - Settings View

/// Settings screen presented as a sheet from ProfileView.
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    // Notification preferences
    @AppStorage("notifyPledgeReminders") private var pledgeReminders = true
    @AppStorage("notifyEliminationAlerts") private var eliminationAlerts = true
    @AppStorage("notifyPayoutAlerts") private var payoutAlerts = true
    @AppStorage("notifyWeeklySummary") private var weeklySummary = false

    // App preferences
    @AppStorage("hapticFeedback") private var hapticFeedback = true

    // State
    @State private var showResetOnboardingConfirm = false
    @State private var showDeleteAccountConfirm = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true

    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background
                    .ignoresSafeArea()

                List {
                    // MARK: Notifications
                    Section {
                        SettingsToggle(
                            icon: "bell.badge.fill",
                            iconColor: DesignSystem.Colors.mustard,
                            title: "Pledge Reminders",
                            subtitle: "Daily check-in reminders",
                            isOn: $pledgeReminders
                        )

                        SettingsToggle(
                            icon: "person.fill.xmark",
                            iconColor: DesignSystem.Colors.alertRed,
                            title: "Elimination Alerts",
                            subtitle: "\"Dave is Out\" notifications",
                            isOn: $eliminationAlerts
                        )

                        SettingsToggle(
                            icon: "dollarsign.circle.fill",
                            iconColor: DesignSystem.Colors.moneyGreen,
                            title: "Payout Alerts",
                            subtitle: "When pot splits are processed",
                            isOn: $payoutAlerts
                        )

                        SettingsToggle(
                            icon: "chart.bar.fill",
                            iconColor: DesignSystem.Colors.inkBlack,
                            title: "Weekly Summary",
                            subtitle: "Performance recap every Sunday",
                            isOn: $weeklySummary
                        )
                    } header: {
                        Text("Notifications")
                    }

                    // MARK: Health
                    Section {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            SettingsIcon(
                                systemName: "heart.text.square.fill",
                                color: DesignSystem.Colors.alertRed
                            )

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Apple Health")
                                    .font(DesignSystem.Typography.body())
                                Text("Read-only access for verification")
                                    .font(DesignSystem.Typography.caption(12))
                                    .foregroundColor(DesignSystem.Colors.inkGray)
                            }

                            Spacer()

                            Text("Connected")
                                .font(DesignSystem.Typography.label())
                                .foregroundColor(DesignSystem.Colors.moneyGreen)
                                .padding(.horizontal, DesignSystem.Spacing.xs)
                                .padding(.vertical, 4)
                                .background(DesignSystem.Colors.moneyGreen.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }

                        HStack(spacing: DesignSystem.Spacing.sm) {
                            SettingsIcon(
                                systemName: "checkmark.shield.fill",
                                color: DesignSystem.Colors.moneyGreen
                            )

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Anti-Cheat")
                                    .font(DesignSystem.Typography.body())
                                Text("Manual entries flagged automatically")
                                    .font(DesignSystem.Typography.caption(12))
                                    .foregroundColor(DesignSystem.Colors.inkGray)
                            }

                            Spacer()

                            Text("Active")
                                .font(DesignSystem.Typography.label())
                                .foregroundColor(DesignSystem.Colors.moneyGreen)
                        }
                    } header: {
                        Text("Health & Verification")
                    }

                    // MARK: Preferences
                    Section {
                        SettingsToggle(
                            icon: "hand.tap.fill",
                            iconColor: DesignSystem.Colors.inkBlack,
                            title: "Haptic Feedback",
                            subtitle: "Vibrations on button presses",
                            isOn: $hapticFeedback
                        )
                    } header: {
                        Text("Preferences")
                    }

                    // MARK: About
                    Section {
                        SettingsLinkRow(
                            icon: "doc.text.fill",
                            iconColor: DesignSystem.Colors.inkGray,
                            title: "Terms of Service"
                        )

                        SettingsLinkRow(
                            icon: "hand.raised.fill",
                            iconColor: DesignSystem.Colors.inkGray,
                            title: "Privacy Policy"
                        )

                        HStack(spacing: DesignSystem.Spacing.sm) {
                            SettingsIcon(
                                systemName: "info.circle.fill",
                                color: DesignSystem.Colors.inkGray
                            )

                            Text("Version")
                                .font(DesignSystem.Typography.body())

                            Spacer()

                            Text("1.0.0 (1)")
                                .font(DesignSystem.Typography.caption())
                                .foregroundColor(DesignSystem.Colors.inkGray)
                        }
                    } header: {
                        Text("About")
                    }

                    // MARK: Danger Zone
                    Section {
                        Button {
                            showResetOnboardingConfirm = true
                        } label: {
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                SettingsIcon(
                                    systemName: "arrow.counterclockwise",
                                    color: DesignSystem.Colors.mustard
                                )
                                Text("Reset Onboarding")
                                    .font(DesignSystem.Typography.body())
                                    .foregroundColor(DesignSystem.Colors.inkBlack)
                            }
                        }

                        Button {
                            showDeleteAccountConfirm = true
                        } label: {
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                SettingsIcon(
                                    systemName: "trash.fill",
                                    color: DesignSystem.Colors.alertRed
                                )
                                Text("Delete Account")
                                    .font(DesignSystem.Typography.body())
                                    .foregroundColor(DesignSystem.Colors.alertRed)
                            }
                        }
                    } header: {
                        Text("Danger Zone")
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Reset Onboarding?", isPresented: $showResetOnboardingConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    hasCompletedOnboarding = false
                }
            } message: {
                Text("You'll see the onboarding slides again next time you open the app.")
            }
            .alert("Delete Account?", isPresented: $showDeleteAccountConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    // Placeholder — would call backend in production
                }
            } message: {
                Text(
                    "This action cannot be undone. All your data, pledges, and wallet balance will be permanently deleted."
                )
            }
        }
    }
}

// MARK: - Settings Toggle Row

/// A toggle row with icon, title, and subtitle.
struct SettingsToggle: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                SettingsIcon(systemName: icon, color: iconColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DesignSystem.Typography.body())
                    Text(subtitle)
                        .font(DesignSystem.Typography.caption(12))
                        .foregroundColor(DesignSystem.Colors.inkGray)
                }
            }
        }
        .tint(DesignSystem.Colors.moneyGreen)
    }
}

// MARK: - Settings Link Row

/// A tappable row that looks like it leads somewhere (placeholder).
struct SettingsLinkRow: View {
    let icon: String
    let iconColor: Color
    let title: String

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SettingsIcon(systemName: icon, color: iconColor)

            Text(title)
                .font(DesignSystem.Typography.body())

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(DesignSystem.Colors.lightGray)
        }
    }
}

// MARK: - Settings Icon

/// Small rounded-rect icon for settings rows.
struct SettingsIcon: View {
    let systemName: String
    let color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.12))
                .frame(width: 32, height: 32)

            Image(systemName: systemName)
                .font(.system(size: 15))
                .foregroundColor(color)
        }
    }
}

// MARK: - Previews

#Preview("Settings") {
    SettingsView()
}
