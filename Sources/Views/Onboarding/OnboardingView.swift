//
//  OnboardingView.swift
//  BetterBet
//
//  Fast onboarding flow - value prop in <30 seconds.
//  Uses dark-first BB design system.
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
    @Environment(HealthManager.self) private var healthManager
    @State private var currentStep = 0
    @State private var selectedMode: ChallengeMode = .steps
    @State private var hasRequestedHealth = false
    @State private var isRequestingHealth = false

    var body: some View {
        ZStack {
            // Dark background
            BB.Colors.bgPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress indicator
                OnboardingProgressIndicator(currentStep: currentStep, totalSteps: 4)
                    .padding(.top, BB.Spacing.md)
                    .padding(.horizontal, BB.Spacing.lg)

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
            }
        }
        .safeAreaInset(edge: .bottom) {
            // Bottom CTA area
            VStack(spacing: BB.Spacing.sm) {
                // Trust line (only on step 0)
                if currentStep == 0 {
                    Text("Secure payments • Receipts for every transfer")
                        .font(BB.Typography.caption())
                        .foregroundColor(BB.Colors.textSecondary)
                }

                // Primary CTA
                Button {
                    BB.Haptics.medium()
                    handleCTA()
                } label: {
                    if isRequestingHealth {
                        ProgressView()
                            .tint(.black)
                    } else {
                        Text(ctaText)
                    }
                }
                .buttonStyle(.bbPrimary)
                .disabled(isRequestingHealth)
                .padding(.horizontal, BB.Spacing.lg)

                // Skip (not on final step)
                if currentStep < 3 {
                    Button("Skip") {
                        withAnimation {
                            currentStep = 3
                        }
                    }
                    .font(BB.Typography.callout())
                    .foregroundColor(BB.Colors.textSecondary)
                }
            }
            .padding(.bottom, BB.Spacing.lg)
            .padding(.top, BB.Spacing.sm)
            .background(
                BB.Colors.bgPrimary
                    .shadow(color: .black.opacity(0.3), radius: 8, y: -4)
            )
        }
        .preferredColorScheme(.dark)
        .onChange(of: healthManager.authorizationStatus) { _, newStatus in
            // Update UI when authorization status changes
            if newStatus == .authorized || newStatus == .denied {
                hasRequestedHealth = true
                isRequestingHealth = false
            }
        }
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
            // Request HealthKit authorization
            isRequestingHealth = true
            Task {
                await healthManager.requestAuthorization()
                // Note: hasRequestedHealth is set via onChange when status updates
            }
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                hasCompletedOnboarding = true
            }
        }
    }
}

// MARK: - Progress Indicator

struct OnboardingProgressIndicator: View {
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
    }
}

// MARK: - Step 0: Value Hook

struct ValueHookStep: View {
    var body: some View {
        VStack(spacing: BB.Spacing.lg) {
            Spacer()

            // Hero icon - SF Symbol on circular surface
            OnboardingHeroIcon(systemName: "bolt.fill")

            // Headline
            Text("Bet on yourself.")
                .font(BB.Typography.display(32))
                .foregroundColor(BB.Colors.textPrimary)
                .multilineTextAlignment(.center)

            // Subhead
            Text("Real money. Real accountability. Verified by your data.")
                .font(BB.Typography.body())
                .foregroundColor(BB.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BB.Spacing.md)

            // Value props
            VStack(spacing: BB.Spacing.sm) {
                OnboardingValuePropRow(
                    icon: "dollarsign.circle.fill",
                    text: "Stake real money on your goals"
                )
                OnboardingValuePropRow(
                    icon: "person.2.fill",
                    text: "Compete with friends"
                )
                OnboardingValuePropRow(
                    icon: "checkmark.shield.fill",
                    text: "Data-verified results (read-only)"
                )
            }
            .padding(.top, BB.Spacing.md)

            // Trust chip
            VerificationBadge()
                .padding(.top, BB.Spacing.xs)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, BB.Spacing.lg)
    }
}

// MARK: - Onboarding Components

/// Hero icon for onboarding steps - SF Symbol on circular surface
struct OnboardingHeroIcon: View {
    let systemName: String
    var size: CGFloat = 100
    var iconSize: CGFloat = 44

    var body: some View {
        ZStack {
            Circle()
                .fill(BB.Colors.bgSecondary)
                .frame(width: size, height: size)

            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundColor(BB.Colors.accent)
        }
    }
}

/// Value prop row for onboarding - compact with SF Symbol + label
struct OnboardingValuePropRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: BB.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(BB.Colors.accent)
                .frame(width: 28)

            Text(text)
                .font(BB.Typography.body())
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
                .font(BB.Typography.title(28))
                .foregroundColor(BB.Colors.textPrimary)
                .multilineTextAlignment(.center)

            VStack(spacing: BB.Spacing.sm) {
                OnboardingFlowStep(
                    number: "1", title: "Create", description: "Set the challenge & stake")
                OnboardingFlowStep(
                    number: "2", title: "Invite", description: "Get your squad in the pot")
                OnboardingFlowStep(
                    number: "3", title: "Sweat", description: "Workouts auto-verified")
                OnboardingFlowStep(
                    number: "4", title: "Settle", description: "Survivors split the pot")
            }
            .padding(.horizontal, BB.Spacing.sm)

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

struct OnboardingFlowStep: View {
    let number: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: BB.Spacing.md) {
            // Number circle
            ZStack {
                Circle()
                    .fill(BB.Colors.bgSecondary)
                    .frame(width: 40, height: 40)

                Text(number)
                    .font(BB.Typography.mono(18))
                    .fontWeight(.bold)
                    .foregroundColor(BB.Colors.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(BB.Typography.callout())
                    .fontWeight(.semibold)
                    .foregroundColor(BB.Colors.textPrimary)

                Text(description)
                    .font(BB.Typography.caption())
                    .foregroundColor(BB.Colors.textSecondary)
            }

            Spacer()
        }
        .padding(BB.Spacing.sm)
        .background(BB.Colors.surface)
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
                .font(BB.Typography.title(28))
                .foregroundColor(BB.Colors.textPrimary)

            Text("Choose how you want to compete")
                .font(BB.Typography.body())
                .foregroundColor(BB.Colors.textSecondary)

            VStack(spacing: BB.Spacing.sm) {
                OnboardingModeCard(
                    mode: .steps,
                    isSelected: selectedMode == .steps,
                    action: { selectedMode = .steps }
                )

                OnboardingModeCard(
                    mode: .distance,
                    isSelected: selectedMode == .distance,
                    action: { selectedMode = .distance }
                )

                OnboardingModeCard(
                    mode: .activeMinutes,
                    isSelected: selectedMode == .activeMinutes,
                    action: { selectedMode = .activeMinutes }
                )
            }
            .padding(.horizontal, BB.Spacing.sm)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, BB.Spacing.lg)
    }
}

struct OnboardingModeCard: View {
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
                        .fill(isSelected ? BB.Colors.accent : BB.Colors.bgSecondary)
                        .frame(width: 48, height: 48)

                    Image(systemName: mode.sfSymbol)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .black : BB.Colors.textSecondary)
                }

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.displayName)
                        .font(BB.Typography.callout())
                        .fontWeight(.semibold)
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
            .background(BB.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: BB.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: BB.Radius.card)
                    .stroke(
                        isSelected ? BB.Colors.accent : BB.Colors.divider,
                        lineWidth: isSelected ? 2 : 1)
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
            OnboardingHeroIcon(systemName: "heart.fill", size: 100, iconSize: 44)

            Text("No Cheating. Period.")
                .font(BB.Typography.title(28))
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
                OnboardingTrustPoint(icon: "lock.fill", text: "Read-only access")
                OnboardingTrustPoint(icon: "xmark.circle.fill", text: "No manual entry")
                OnboardingTrustPoint(icon: "checkmark.circle.fill", text: "Auto-verified results")
            }
            .padding(.top, BB.Spacing.sm)

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

struct OnboardingTrustPoint: View {
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

    var sfSymbol: String {
        switch self {
        case .steps: return "figure.walk"
        case .distance: return "figure.run"
        case .activeMinutes: return "heart.circle"
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
