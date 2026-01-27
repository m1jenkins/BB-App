//
//  OnboardingView.swift
//  BetterBet
//
//  Fast onboarding flow - value prop in <30 seconds.
//  Uses new dark-first design system.
//
//  Flow: Value Hook → Mode Selection → Connect Tracking → Get Started
//
//  SEMANTIC FIREWALL NOTICE:
//  - Approved: Pledge, Stake, Commitment, Pot, Challenge
//  - Forbidden: Bet, Wager, Gamble, Win, Lose
//

import SwiftUI

/// Fast onboarding that shows value, then collects preferences.
struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentStep = 0
    @State private var selectedMode: ChallengeMode = .steps
    @State private var hasRequestedHealth = false

    var body: some View {
        ZStack {
            // Dark background
            BB.Colors.bgPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress indicator
                ProgressIndicator(currentStep: currentStep, totalSteps: 4)
                    .padding(.top, BB.Spacing.md)

                // Content
                TabView(selection: $currentStep) {
                    // Step 0: Value Hook
                    ValueHookStep()
                        .tag(0)

                    // Step 1: How It Works
                    HowItWorksStep()
                        .tag(1)

                    // Step 2: Mode Selection
                    ModeSelectionStep(selectedMode: $selectedMode)
                        .tag(2)

                    // Step 3: Connect Tracking
                    ConnectTrackingStep(hasRequestedHealth: $hasRequestedHealth)
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentStep)

                // Bottom CTA
                VStack(spacing: BB.Spacing.sm) {
                    Button(ctaText) {
                        BB.Haptics.medium()
                        handleCTA()
                    }
                    .buttonStyle(.bbPrimary)
                    .padding(.horizontal, BB.Spacing.lg)

                    // Skip (not on final step)
                    if currentStep < 3 {
                        Button("Skip") {
                            withAnimation {
                                currentStep = 3
                            }
                        }
                        .font(BB.Typography.caption())
                        .foregroundColor(BB.Colors.textSecondary)
                    }
                }
                .padding(.bottom, BB.Spacing.xxl)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var ctaText: String {
        switch currentStep {
        case 0, 1, 2: return "Continue"
        case 3: return hasRequestedHealth ? "Get Started" : "Connect Apple Health"
        default: return "Continue"
        }
    }

    private func handleCTA() {
        if currentStep < 3 {
            withAnimation {
                currentStep += 1
            }
        } else if !hasRequestedHealth {
            // Would trigger HealthKit permission
            hasRequestedHealth = true
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                hasCompletedOnboarding = true
            }
        }
    }
}

// MARK: - Progress Indicator

struct ProgressIndicator: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: BB.Spacing.xs) {
            ForEach(0..<totalSteps, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index <= currentStep ? BB.Colors.accent : BB.Colors.divider)
                    .frame(height: 3)
                    .animation(.easeInOut(duration: 0.2), value: currentStep)
            }
        }
        .padding(.horizontal, BB.Spacing.lg)
    }
}

// MARK: - Step 0: Value Hook

struct ValueHookStep: View {
    var body: some View {
        VStack(spacing: BB.Spacing.lg) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(BB.Colors.accent.opacity(0.15))
                    .frame(width: 120, height: 120)

                Text("💪")
                    .font(.system(size: 56))
            }

            // Headline
            Text("Put Your Money\nWhere Your Health Is")
                .font(BB.Typography.display(32))
                .foregroundColor(BB.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            // Subhead
            Text("Willpower is finite. Incentives are powerful.")
                .font(BB.Typography.body())
                .foregroundColor(BB.Colors.textSecondary)
                .multilineTextAlignment(.center)

            // Value prop
            VStack(spacing: BB.Spacing.sm) {
                ValuePropRow(icon: "dollarsign.circle.fill", text: "Stake real money on your goals")
                ValuePropRow(icon: "person.2.fill", text: "Compete with friends")
                ValuePropRow(icon: "checkmark.shield.fill", text: "Data-verified results")
            }
            .padding(.top, BB.Spacing.md)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, BB.Spacing.lg)
    }
}

struct ValuePropRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: BB.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(BB.Colors.accent)
                .frame(width: 32)

            Text(text)
                .font(BB.Typography.callout())
                .foregroundColor(BB.Colors.textPrimary)

            Spacer()
        }
        .padding(.horizontal, BB.Spacing.lg)
    }
}

// MARK: - Step 1: How It Works

struct HowItWorksStep: View {
    var body: some View {
        VStack(spacing: BB.Spacing.lg) {
            Spacer()

            Text("Here's How It Works")
                .font(BB.Typography.display(28))
                .foregroundColor(BB.Colors.textPrimary)
                .multilineTextAlignment(.center)

            VStack(spacing: BB.Spacing.md) {
                FlowStep(number: "1", title: "Create", description: "Set the challenge & stake")
                FlowStep(number: "2", title: "Invite", description: "Get your squad in the pot")
                FlowStep(number: "3", title: "Sweat", description: "Workouts auto-verified")
                FlowStep(number: "4", title: "Settle", description: "Survivors split the pot")
            }
            .padding(.horizontal, BB.Spacing.md)

            // Consequence callout
            Text("Miss the goal → lose your stake.")
                .font(BB.Typography.callout())
                .fontWeight(.semibold)
                .foregroundColor(BB.Colors.accent)
                .padding(.top, BB.Spacing.md)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, BB.Spacing.lg)
    }
}

struct FlowStep: View {
    let number: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: BB.Spacing.md) {
            // Number circle
            ZStack {
                Circle()
                    .fill(BB.Colors.surface)
                    .frame(width: 40, height: 40)

                Text(number)
                    .font(BB.Typography.mono(18))
                    .fontWeight(.bold)
                    .foregroundColor(BB.Colors.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(BB.Typography.title3())
                    .foregroundColor(BB.Colors.textPrimary)

                Text(description)
                    .font(BB.Typography.caption())
                    .foregroundColor(BB.Colors.textSecondary)
            }

            Spacer()
        }
        .padding(BB.Spacing.sm)
        .background(BB.Colors.bgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: BB.Radius.md))
    }
}

// MARK: - Step 2: Mode Selection

struct ModeSelectionStep: View {
    @Binding var selectedMode: ChallengeMode

    var body: some View {
        VStack(spacing: BB.Spacing.lg) {
            Spacer()

            Text("Pick Your Battle")
                .font(BB.Typography.display(28))
                .foregroundColor(BB.Colors.textPrimary)

            Text("Choose how you want to compete")
                .font(BB.Typography.body())
                .foregroundColor(BB.Colors.textSecondary)

            VStack(spacing: BB.Spacing.sm) {
                ModeCard(
                    mode: .steps,
                    isSelected: selectedMode == .steps,
                    action: { selectedMode = .steps }
                )

                ModeCard(
                    mode: .distance,
                    isSelected: selectedMode == .distance,
                    action: { selectedMode = .distance }
                )

                ModeCard(
                    mode: .activeMinutes,
                    isSelected: selectedMode == .activeMinutes,
                    action: { selectedMode = .activeMinutes }
                )
            }
            .padding(.horizontal, BB.Spacing.md)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, BB.Spacing.lg)
    }
}

struct ModeCard: View {
    let mode: ChallengeMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            BB.Haptics.light()
            action()
        }) {
            HStack(spacing: BB.Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? BB.Colors.accent : BB.Colors.surface)
                        .frame(width: 48, height: 48)

                    Text(mode.icon)
                        .font(.system(size: 24))
                }

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.displayName)
                        .font(BB.Typography.title3())
                        .foregroundColor(BB.Colors.textPrimary)

                    Text(mode.description)
                        .font(BB.Typography.caption())
                        .foregroundColor(BB.Colors.textSecondary)
                }

                Spacer()

                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(BB.Colors.accent)
                }
            }
            .padding(BB.Spacing.md)
            .background(BB.Colors.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: BB.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: BB.Radius.card)
                    .stroke(isSelected ? BB.Colors.accent : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Step 3: Connect Tracking

struct ConnectTrackingStep: View {
    @Binding var hasRequestedHealth: Bool

    var body: some View {
        VStack(spacing: BB.Spacing.lg) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(BB.Colors.success.opacity(0.15))
                    .frame(width: 120, height: 120)

                Image(systemName: "heart.fill")
                    .font(.system(size: 48))
                    .foregroundColor(BB.Colors.success)
            }

            Text("No Cheating. Period.")
                .font(BB.Typography.display(28))
                .foregroundColor(BB.Colors.textPrimary)

            Text("We sync with Apple Health to verify your workouts automatically.")
                .font(BB.Typography.body())
                .foregroundColor(BB.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BB.Spacing.lg)

            // Verification badge
            VerificationBadge()

            // Trust points
            VStack(alignment: .leading, spacing: BB.Spacing.sm) {
                TrustPoint(icon: "lock.fill", text: "Read-only access")
                TrustPoint(icon: "xmark.circle.fill", text: "No manual entry")
                TrustPoint(icon: "checkmark.circle.fill", text: "Auto-verified results")
            }
            .padding(.top, BB.Spacing.md)

            // Mantra
            Text("If it's not tracked, it didn't happen.")
                .font(BB.Typography.callout())
                .fontWeight(.semibold)
                .foregroundColor(BB.Colors.accent)
                .padding(.top, BB.Spacing.sm)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, BB.Spacing.lg)
    }
}

struct TrustPoint: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: BB.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(BB.Colors.success)
                .frame(width: 24)

            Text(text)
                .font(BB.Typography.body())
                .foregroundColor(BB.Colors.textPrimary)

            Spacer()
        }
        .padding(.horizontal, BB.Spacing.xl)
    }
}

// MARK: - Challenge Mode

enum ChallengeMode: String, CaseIterable {
    case steps
    case distance
    case activeMinutes

    var icon: String {
        switch self {
        case .steps: return "👟"
        case .distance: return "🏃"
        case .activeMinutes: return "⏱️"
        }
    }

    var displayName: String {
        switch self {
        case .steps: return "Step Showdown"
        case .distance: return "Distance Derby"
        case .activeMinutes: return "Active Zone"
        }
    }

    var description: String {
        switch self {
        case .steps: return "Total steps count"
        case .distance: return "Miles covered"
        case .activeMinutes: return "Heart-rate minutes"
        }
    }
}

// MARK: - Previews

#Preview("Onboarding Flow") {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}

#Preview("Value Hook") {
    ZStack {
        BB.Colors.bgPrimary.ignoresSafeArea()
        ValueHookStep()
    }
    .preferredColorScheme(.dark)
}

#Preview("How It Works") {
    ZStack {
        BB.Colors.bgPrimary.ignoresSafeArea()
        HowItWorksStep()
    }
    .preferredColorScheme(.dark)
}

#Preview("Mode Selection") {
    ZStack {
        BB.Colors.bgPrimary.ignoresSafeArea()
        ModeSelectionStep(selectedMode: .constant(.steps))
    }
    .preferredColorScheme(.dark)
}

#Preview("Connect Tracking") {
    ZStack {
        BB.Colors.bgPrimary.ignoresSafeArea()
        ConnectTrackingStep(hasRequestedHealth: .constant(false))
    }
    .preferredColorScheme(.dark)
}
