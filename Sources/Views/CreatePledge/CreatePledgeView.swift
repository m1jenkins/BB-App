//
//  CreatePledgeView.swift
//  BetterBet
//
//  The "Create Pledge" flow for setting up a new fitness commitment.
//  Phase 2: Fitness-only with HealthKit verification.
//
//  SEMANTIC FIREWALL NOTICE:
//  This is a COMMITMENT creation flow, NOT a betting flow.
//  - "Pledge" = commitment contract
//  - "Stake" = amount committed
//  - "Lock It In" = confirm commitment (NOT "Place Bet")
//

import SwiftUI

/// Main view for creating a new fitness pledge.
struct CreatePledgeView: View {
    @Environment(\.dismiss) private var dismiss

    // Form state
    @State private var selectedType: ChallengeType = .steps
    @State private var selectedStake: Double = 50
    @State private var targetValue: Double = 10000
    @State private var currentStep: CreatePledgeStep = .selectMode

    // Available stake amounts
    private let stakeAmounts: [Double] = [20, 50, 100]

    // Duration is fixed to 7 days for MVP
    private let durationDays = 7

    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Progress indicator
                    StepIndicator(currentStep: currentStep)
                        .padding(.top, DesignSystem.Spacing.md)
                        .padding(.bottom, DesignSystem.Spacing.lg)

                    // Content based on current step
                    switch currentStep {
                    case .selectMode:
                        SelectModeStep(
                            selectedType: $selectedType,
                            onNext: { currentStep = .setTarget }
                        )
                    case .setTarget:
                        SetTargetStep(
                            challengeType: selectedType,
                            targetValue: $targetValue,
                            onNext: { currentStep = .setStake },
                            onBack: { currentStep = .selectMode }
                        )
                    case .setStake:
                        SetStakeStep(
                            selectedStake: $selectedStake,
                            stakeAmounts: stakeAmounts,
                            onNext: { currentStep = .confirm },
                            onBack: { currentStep = .setTarget }
                        )
                    case .confirm:
                        ConfirmStep(
                            challengeType: selectedType,
                            targetValue: targetValue,
                            stakeAmount: selectedStake,
                            durationDays: durationDays,
                            onConfirm: { createPledge() },
                            onBack: { currentStep = .setStake }
                        )
                    }
                }
            }
            .navigationTitle("New Pledge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.inkBlack)
                }
            }
        }
    }

    private func createPledge() {
        // TODO: Create actual pledge and save to SwiftData
        // For now, just dismiss
        dismiss()
    }
}

// MARK: - Step Enum

enum CreatePledgeStep: Int, CaseIterable {
    case selectMode = 0
    case setTarget = 1
    case setStake = 2
    case confirm = 3

    var title: String {
        switch self {
        case .selectMode: return "Challenge"
        case .setTarget: return "Target"
        case .setStake: return "Stake"
        case .confirm: return "Confirm"
        }
    }
}

// MARK: - Step Indicator

struct StepIndicator: View {
    let currentStep: CreatePledgeStep

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(CreatePledgeStep.allCases, id: \.rawValue) { step in
                HStack(spacing: DesignSystem.Spacing.xxs) {
                    // Step circle
                    ZStack {
                        Circle()
                            .fill(step.rawValue <= currentStep.rawValue
                                  ? DesignSystem.Colors.inkBlack
                                  : DesignSystem.Colors.inkBlack.opacity(0.2))
                            .frame(width: 24, height: 24)

                        if step.rawValue < currentStep.rawValue {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Text("\(step.rawValue + 1)")
                                .font(DesignSystem.Typography.label(12))
                                .foregroundColor(step.rawValue <= currentStep.rawValue ? .white : DesignSystem.Colors.inkGray)
                        }
                    }

                    // Step label (only show for current)
                    if step == currentStep {
                        Text(step.title)
                            .font(DesignSystem.Typography.caption())
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.inkBlack)
                    }
                }

                // Connector line
                if step.rawValue < CreatePledgeStep.allCases.count - 1 {
                    Rectangle()
                        .fill(step.rawValue < currentStep.rawValue
                              ? DesignSystem.Colors.inkBlack
                              : DesignSystem.Colors.inkBlack.opacity(0.2))
                        .frame(height: 2)
                        .frame(maxWidth: 24)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
}

// MARK: - Step 1: Select Challenge Mode

struct SelectModeStep: View {
    @Binding var selectedType: ChallengeType
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Header
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("Select Challenge")
                    .font(DesignSystem.Typography.headline(28))
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                Text("Choose your fitness commitment type")
                    .font(DesignSystem.Typography.body())
                    .foregroundColor(DesignSystem.Colors.inkGray)
            }
            .padding(.bottom, DesignSystem.Spacing.sm)

            // Challenge mode cards
            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(ChallengeType.allCases) { type in
                    ChallengeModeCard(
                        icon: type.icon,
                        title: type.displayName,
                        subtitle: type.subtitle,
                        isSelected: selectedType == type,
                        action: { selectedType = type }
                    )
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)

            Spacer()

            // Next button
            Button("Next") {
                onNext()
            }
            .buttonStyle(.primary)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.lg)
        }
    }
}

// MARK: - Step 2: Set Target

struct SetTargetStep: View {
    let challengeType: ChallengeType
    @Binding var targetValue: Double
    let onNext: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Header
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("Set Your Target")
                    .font(DesignSystem.Typography.headline(28))
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                Text("How much can you commit to?")
                    .font(DesignSystem.Typography.body())
                    .foregroundColor(DesignSystem.Colors.inkGray)
            }

            // Target display
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text(challengeType.formatValue(targetValue))
                    .font(DesignSystem.Typography.data(48))
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                Text(challengeType.unitLabel + " / week")
                    .font(DesignSystem.Typography.body())
                    .foregroundColor(DesignSystem.Colors.inkGray)
            }
            .padding(.vertical, DesignSystem.Spacing.lg)

            // Target selector
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("Suggested targets")
                    .font(DesignSystem.Typography.caption())
                    .foregroundColor(DesignSystem.Colors.inkGray)

                HStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(challengeType.suggestedTargets, id: \.self) { target in
                        TargetPill(
                            value: target,
                            unit: challengeType.unitLabel,
                            isSelected: targetValue == target,
                            action: { targetValue = target }
                        )
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)

            Spacer()

            // Navigation buttons
            HStack(spacing: DesignSystem.Spacing.sm) {
                Button("Back") {
                    onBack()
                }
                .buttonStyle(.secondary)

                Button("Next") {
                    onNext()
                }
                .buttonStyle(.primary)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.lg)
        }
    }
}

struct TargetPill: View {
    let value: Double
    let unit: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(value >= 1000 ? "\(Int(value / 1000))k" : "\(Int(value))")
                    .font(DesignSystem.Typography.button())
                Text(unit)
                    .font(DesignSystem.Typography.caption(10))
            }
            .foregroundColor(isSelected ? .white : DesignSystem.Colors.inkBlack)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(isSelected ? DesignSystem.Colors.inkBlack : DesignSystem.Colors.cardWhite)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusButton))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusButton)
                    .stroke(DesignSystem.Colors.inkBlack, lineWidth: DesignSystem.Borders.thickness)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Step 3: Set Stake

struct SetStakeStep: View {
    @Binding var selectedStake: Double
    let stakeAmounts: [Double]
    let onNext: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Header
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("Set Your Stake")
                    .font(DesignSystem.Typography.headline(28))
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                // SEMANTIC FIREWALL: "Stake" not "Bet"
                Text("How much are you willing to commit?")
                    .font(DesignSystem.Typography.body())
                    .foregroundColor(DesignSystem.Colors.inkGray)
            }

            // Stake display
            Text("$\(Int(selectedStake))")
                .font(DesignSystem.Typography.data(64))
                .foregroundColor(DesignSystem.Colors.inkBlack)
                .padding(.vertical, DesignSystem.Spacing.lg)

            // Stake selector
            StakeSelector(selectedAmount: $selectedStake, amounts: stakeAmounts)
                .padding(.horizontal, DesignSystem.Spacing.md)

            // Info text
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("Your stake goes into the pot")
                    .font(DesignSystem.Typography.caption())
                    .foregroundColor(DesignSystem.Colors.inkGray)

                // SEMANTIC FIREWALL: Explain pot redistribution
                Text("If you fail, your stake is split among survivors")
                    .font(DesignSystem.Typography.caption())
                    .foregroundColor(DesignSystem.Colors.inkGray)
            }
            .padding(.top, DesignSystem.Spacing.md)

            Spacer()

            // Navigation buttons
            HStack(spacing: DesignSystem.Spacing.sm) {
                Button("Back") {
                    onBack()
                }
                .buttonStyle(.secondary)

                Button("Next") {
                    onNext()
                }
                .buttonStyle(.primary)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.lg)
        }
    }
}

// MARK: - Step 4: Confirm

struct ConfirmStep: View {
    let challengeType: ChallengeType
    let targetValue: Double
    let stakeAmount: Double
    let durationDays: Int
    let onConfirm: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Header
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("Confirm Pledge")
                    .font(DesignSystem.Typography.headline(28))
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                Text("Review your commitment")
                    .font(DesignSystem.Typography.body())
                    .foregroundColor(DesignSystem.Colors.inkGray)
            }

            // Summary card
            VStack(spacing: DesignSystem.Spacing.md) {
                // Challenge type
                SummaryRow(
                    icon: challengeType.icon,
                    label: "Challenge",
                    value: challengeType.displayName
                )

                Divider()

                // Target
                SummaryRow(
                    icon: "target",
                    label: "Target",
                    value: "\(challengeType.formatValue(targetValue)) \(challengeType.unitLabel)"
                )

                Divider()

                // Duration
                SummaryRow(
                    icon: "calendar",
                    label: "Duration",
                    value: "\(durationDays) days"
                )

                Divider()

                // Stake
                // SEMANTIC FIREWALL: "Stake" not "Bet"
                SummaryRow(
                    icon: "dollarsign.circle",
                    label: "Your Stake",
                    value: "$\(Int(stakeAmount))",
                    valueColor: DesignSystem.Colors.moneyGreen
                )
            }
            .padding(DesignSystem.Spacing.md)
            .cleanCard()
            .padding(.horizontal, DesignSystem.Spacing.md)

            // Terms reminder
            VStack(spacing: DesignSystem.Spacing.xs) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14))
                    Text("Progress verified via Apple Health")
                        .font(DesignSystem.Typography.caption())
                }
                .foregroundColor(DesignSystem.Colors.inkGray)

                // SEMANTIC FIREWALL: Explain commitment terms
                Text("Fail to meet your target and your stake joins the pot")
                    .font(DesignSystem.Typography.caption())
                    .foregroundColor(DesignSystem.Colors.inkGray)
            }
            .padding(.top, DesignSystem.Spacing.sm)

            Spacer()

            // Navigation buttons
            VStack(spacing: DesignSystem.Spacing.sm) {
                // SEMANTIC FIREWALL: "Lock It In" not "Place Bet"
                Button("Lock It In") {
                    onConfirm()
                }
                .buttonStyle(.primary)

                Button("Back") {
                    onBack()
                }
                .buttonStyle(.secondary)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.lg)
        }
    }
}

struct SummaryRow: View {
    let icon: String
    let label: String
    let value: String
    var valueColor: Color = DesignSystem.Colors.inkBlack

    var body: some View {
        HStack {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(DesignSystem.Colors.inkGray)
                .frame(width: 24)

            // Label
            Text(label)
                .font(DesignSystem.Typography.body())
                .foregroundColor(DesignSystem.Colors.inkGray)

            Spacer()

            // Value
            Text(value)
                .font(DesignSystem.Typography.body())
                .fontWeight(.semibold)
                .foregroundColor(valueColor)
        }
    }
}

// MARK: - Previews

#Preview("Create Pledge - Mode") {
    CreatePledgeView()
}

#Preview("Select Mode Step") {
    SelectModeStep(selectedType: .constant(.steps), onNext: {})
        .background(DesignSystem.Colors.background)
}

#Preview("Set Target Step") {
    SetTargetStep(
        challengeType: .steps,
        targetValue: .constant(10000),
        onNext: {},
        onBack: {}
    )
    .background(DesignSystem.Colors.background)
}

#Preview("Set Stake Step") {
    SetStakeStep(
        selectedStake: .constant(50),
        stakeAmounts: [20, 50, 100],
        onNext: {},
        onBack: {}
    )
    .background(DesignSystem.Colors.background)
}

#Preview("Confirm Step") {
    ConfirmStep(
        challengeType: .steps,
        targetValue: 10000,
        stakeAmount: 50,
        durationDays: 7,
        onConfirm: {},
        onBack: {}
    )
    .background(DesignSystem.Colors.background)
}
