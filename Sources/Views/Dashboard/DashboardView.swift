//
//  DashboardView.swift
//  BetterBet
//
//  The main "Weekly Challenge" dashboard showing the leaderboard and pot status.
//  This is where users track their progress and see friends' commitment status.
//
//  SEMANTIC FIREWALL NOTICE:
//  - "Pot" = pooled stakes, not gambling pot
//  - "FAILED" = did not fulfill commitment, not "lost"
//  - "Survivors" = those who fulfilled commitments, not "winners"
//  - "Eliminated" = removed from challenge, not "knocked out"
//

import SwiftUI

/// The main dashboard view showing the weekly challenge status.
struct DashboardView: View {
    @State private var healthManager = HealthManager.preview
    @State private var showEliminationToast = true
    @State private var challenge = Challenge.mockWeeklyChallenge

    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Header with title and pot badge
                    challengeHeader

                    // Your progress card
                    yourProgressCard

                    // Leaderboard
                    leaderboardSection

                    // Spacer for floating toast
                    Spacer()
                        .frame(height: 100)
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.top, DesignSystem.Spacing.md)
            }

            // Floating elimination toast (The "Dave is Out" widget)
            if showEliminationToast {
                VStack {
                    Spacer()
                    EliminationToast(
                        playerName: "Dave",
                        addedAmount: 12.50,
                        onDismiss: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showEliminationToast = false
                            }
                        }
                    )
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.lg)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .task {
            await healthManager.fetchWeeklySteps()
        }
    }

    // MARK: - Challenge Header

    private var challengeHeader: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text("Weekly Steps")
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.inkGray)
                        .textCase(.uppercase)
                        .tracking(1)

                    Text("Challenge")
                        .font(DesignSystem.Typography.headline(32))
                        .foregroundColor(DesignSystem.Colors.inkBlack)
                }

                Spacer()

                // Pot Value Starburst Badge
                // SEMANTIC FIREWALL: "Pot" refers to pooled commitments, not gambling
                PotBadge(amount: challenge.potValue)
            }

            // Challenge details bar
            HStack {
                Label("\(challenge.participants.count) Pledgers", systemImage: "person.3.fill")
                Spacer()
                Label(challenge.timeRemaining, systemImage: "clock.fill")
            }
            .font(DesignSystem.Typography.caption())
            .foregroundColor(DesignSystem.Colors.inkGray)
        }
        .padding(DesignSystem.Spacing.md)
        .neoBrutalist()
    }

    // MARK: - Your Progress Card

    private var yourProgressCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Text("Your Progress")
                    .font(DesignSystem.Typography.title(20))
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                Spacer()

                // Status badge
                if challenge.currentUserProgress >= 1.0 {
                    StatusBadge(status: .onTrack)
                } else if challenge.daysRemaining <= 1 && challenge.currentUserProgress < 0.8 {
                    StatusBadge(status: .atRisk)
                } else {
                    StatusBadge(status: .onTrack)
                }
            }

            // Step count display
            HStack(alignment: .firstTextBaseline, spacing: DesignSystem.Spacing.xxs) {
                Text("\(healthManager.weeklySteps.formatted())")
                    .font(DesignSystem.Typography.headline(42))
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                Text("/ \(challenge.targetSteps.formatted()) steps")
                    .font(DesignSystem.Typography.body())
                    .foregroundColor(DesignSystem.Colors.inkGray)
            }

            // Progress bar
            ChunkyProgressBar(
                progress: Double(healthManager.weeklySteps) / Double(challenge.targetSteps),
                fillColor: progressColor
            )

            // Today's contribution
            HStack {
                Text("Today:")
                    .font(DesignSystem.Typography.caption())
                    .foregroundColor(DesignSystem.Colors.inkGray)
                Text("\(healthManager.todaySteps.formatted()) steps")
                    .font(DesignSystem.Typography.caption())
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                Spacer()

                // Daily target indicator
                let dailyTarget = challenge.targetSteps / 7
                if healthManager.todaySteps >= dailyTarget {
                    Label("On pace", systemImage: "checkmark.circle.fill")
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.moneyGreen)
                } else {
                    Label("\(dailyTarget - healthManager.todaySteps) to go", systemImage: "arrow.up.circle")
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.mustard)
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .neoBrutalist(shadowColor: DesignSystem.Colors.mustard)
    }

    private var progressColor: Color {
        let progress = Double(healthManager.weeklySteps) / Double(challenge.targetSteps)
        if progress >= 1.0 {
            return DesignSystem.Colors.moneyGreen
        } else if progress >= 0.7 {
            return DesignSystem.Colors.mustard
        } else {
            return DesignSystem.Colors.alertRed
        }
    }

    // MARK: - Leaderboard Section

    private var leaderboardSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Text("Leaderboard")
                    .font(DesignSystem.Typography.title(20))
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                Spacer()

                // SEMANTIC FIREWALL: "Survivors" not "Winners"
                Text("\(challenge.survivorCount) survivors")
                    .font(DesignSystem.Typography.caption())
                    .foregroundColor(DesignSystem.Colors.moneyGreen)
            }

            VStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(challenge.participants) { participant in
                    LeaderboardRow(participant: participant, targetSteps: challenge.targetSteps)
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .neoBrutalist()
    }
}

// MARK: - Pot Badge (Starburst)

struct PotBadge: View {
    let amount: Double

    var body: some View {
        ZStack {
            // Starburst shape with hard shadow
            StarburstShape(points: 16, innerRadiusRatio: 0.75)
                .fill(DesignSystem.Colors.inkBlack)
                .frame(width: 100, height: 100)
                .offset(x: 3, y: 3)

            StarburstShape(points: 16, innerRadiusRatio: 0.75)
                .fill(DesignSystem.Colors.mustard)
                .frame(width: 100, height: 100)

            StarburstShape(points: 16, innerRadiusRatio: 0.75)
                .stroke(DesignSystem.Colors.inkBlack, lineWidth: 2)
                .frame(width: 100, height: 100)

            // Amount display
            VStack(spacing: -2) {
                Text("POT")
                    .font(DesignSystem.Typography.caption(10))
                    .fontWeight(.bold)
                    .tracking(2)

                Text("$\(Int(amount))")
                    .font(DesignSystem.Typography.headline(24))
            }
            .foregroundColor(DesignSystem.Colors.inkBlack)
        }
    }
}

// MARK: - Status Badge

enum ChallengeStatus {
    case onTrack
    case atRisk
    case failed
    case completed

    var text: String {
        switch self {
        case .onTrack: return "ON TRACK"
        case .atRisk: return "AT RISK"
        // SEMANTIC FIREWALL: "FAILED" commitment, not "LOST"
        case .failed: return "FAILED"
        case .completed: return "COMPLETE"
        }
    }

    var color: Color {
        switch self {
        case .onTrack: return DesignSystem.Colors.moneyGreen
        case .atRisk: return DesignSystem.Colors.mustard
        case .failed: return DesignSystem.Colors.alertRed
        case .completed: return DesignSystem.Colors.moneyGreen
        }
    }
}

struct StatusBadge: View {
    let status: ChallengeStatus

    var body: some View {
        Text(status.text)
            .font(DesignSystem.Typography.caption(12))
            .fontWeight(.bold)
            .tracking(1)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xxs)
            .background(status.color)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusSmall))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusSmall)
                    .stroke(DesignSystem.Colors.inkBlack, lineWidth: 2)
            )
    }
}

// MARK: - Leaderboard Row

struct LeaderboardRow: View {
    let participant: Participant
    let targetSteps: Int

    private var progress: Double {
        Double(participant.steps) / Double(targetSteps)
    }

    // SEMANTIC FIREWALL: Determine if commitment was FAILED (not "lost")
    private var hasFailed: Bool {
        participant.hasFailed
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Avatar
            ZStack {
                Circle()
                    .fill(hasFailed ? DesignSystem.Colors.alertRed.opacity(0.2) : DesignSystem.Colors.mustard.opacity(0.3))
                    .frame(width: 44, height: 44)

                Circle()
                    .stroke(DesignSystem.Colors.inkBlack, lineWidth: 2)
                    .frame(width: 44, height: 44)

                Text(participant.avatarEmoji)
                    .font(.system(size: 22))

                // Failed overlay
                if hasFailed {
                    Circle()
                        .fill(DesignSystem.Colors.alertRed.opacity(0.6))
                        .frame(width: 44, height: 44)

                    Text("💀")
                        .font(.system(size: 22))
                }
            }

            // Name and steps
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(participant.name)
                        .font(DesignSystem.Typography.body())
                        .fontWeight(.medium)
                        .foregroundColor(hasFailed ? DesignSystem.Colors.inkGray : DesignSystem.Colors.inkBlack)
                        .strikethrough(hasFailed)

                    if participant.isCurrentUser {
                        Text("(You)")
                            .font(DesignSystem.Typography.caption())
                            .foregroundColor(DesignSystem.Colors.inkGray)
                    }
                }

                Text("\(participant.steps.formatted()) steps")
                    .font(DesignSystem.Typography.caption())
                    .foregroundColor(DesignSystem.Colors.inkGray)
            }

            Spacer()

            // Progress or Failed stamp
            if hasFailed {
                // SEMANTIC FIREWALL: "FAILED" stamp, not "LOST" or "ELIMINATED"
                FailedStamp()
            } else {
                // Progress indicator
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(progress * 100))%")
                        .font(DesignSystem.Typography.mono(14))
                        .fontWeight(.bold)
                        .foregroundColor(progress >= 1.0 ? DesignSystem.Colors.moneyGreen : DesignSystem.Colors.inkBlack)

                    // Mini progress bar
                    ChunkyProgressBar(
                        progress: progress,
                        fillColor: progress >= 1.0 ? DesignSystem.Colors.moneyGreen : DesignSystem.Colors.mustard,
                        height: 8
                    )
                    .frame(width: 60)
                }
            }
        }
        .padding(DesignSystem.Spacing.sm)
        .background(hasFailed ? DesignSystem.Colors.alertRed.opacity(0.05) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusSmall))
    }
}

// MARK: - Failed Stamp

struct FailedStamp: View {
    var body: some View {
        // SEMANTIC FIREWALL: This displays "FAILED" for commitment failure
        Text("FAILED")
            .font(DesignSystem.Typography.caption(12))
            .fontWeight(.black)
            .tracking(1)
            .foregroundColor(DesignSystem.Colors.alertRed)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xxs)
            .background(DesignSystem.Colors.alertRed.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(DesignSystem.Colors.alertRed, lineWidth: 2)
            )
            .rotationEffect(.degrees(-5))
    }
}

// MARK: - Elimination Toast (The "Dave is Out" Widget)

struct EliminationToast: View {
    let playerName: String
    let addedAmount: Double
    var onDismiss: () -> Void

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Skull emoji
            Text("💀")
                .font(.system(size: 28))

            VStack(alignment: .leading, spacing: 2) {
                // SEMANTIC FIREWALL: "is Out" = failed commitment, not "eliminated" in gambling sense
                Text("\(playerName) is Out.")
                    .font(DesignSystem.Typography.body())
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                // SEMANTIC FIREWALL: "added to your pot" = stake redistribution
                HStack(spacing: 4) {
                    Text("+$\(String(format: "%.2f", addedAmount))")
                        .font(DesignSystem.Typography.mono(14))
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.moneyGreen)

                    Text("added to your pot")
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.inkGray)
                }
            }

            Spacer()

            // Dismiss button
            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.inkGray)
                    .padding(DesignSystem.Spacing.xs)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .neoBrutalist(
            backgroundColor: DesignSystem.Colors.cardWhite,
            shadowColor: DesignSystem.Colors.alertRed
        )
    }
}

// MARK: - Preview

#Preview("Dashboard") {
    DashboardView()
}

#Preview("Pot Badge") {
    ZStack {
        DesignSystem.Colors.background
        PotBadge(amount: 150)
    }
}

#Preview("Elimination Toast") {
    ZStack {
        DesignSystem.Colors.background
        EliminationToast(playerName: "Dave", addedAmount: 12.50, onDismiss: {})
            .padding()
    }
}

#Preview("Failed Stamp") {
    FailedStamp()
        .padding()
}
