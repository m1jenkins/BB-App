//
//  PledgeDetailView.swift
//  BetterBet
//
//  Unified detail view for ANY pledge type (steps, distance, active minutes).
//  Replaces the previous StepTrackingView and StepDetailView with a single,
//  pledge-agnostic view that adapts to the challenge type.
//
//  SEMANTIC FIREWALL NOTICE:
//  - "Commitment Progress" not "Bet Progress"
//  - "Stake at Risk" not "Money on the Line"
//  - "Fulfill Goal" not "Win Bet"
//

import SwiftUI

/// Unified detail view for tracking progress on any pledge type.
struct PledgeDetailView: View {
    @Bindable var pledge: Pledge
    var healthManager: HealthManager
    var pledgeManager: PledgeManager

    @State private var isRefreshing = false

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Progress Ring Section
                ProgressRingCard(
                    pledge: pledge,
                    healthManager: healthManager
                )

                // Leaderboard Position
                LeaderboardPositionCard(pledge: pledge)

                // Daily Breakdown
                DailyBreakdownCard(
                    pledge: pledge,
                    healthManager: healthManager
                )

                // Stake Info
                StakeCard(pledge: pledge)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .background(DesignSystem.Colors.background)
        .refreshable {
            isRefreshing = true
            await pledgeManager.syncPledge(pledge)
            isRefreshing = false
        }
        .navigationTitle(pledge.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Progress Ring Card

struct ProgressRingCard: View {
    let pledge: Pledge
    let healthManager: HealthManager

    private var currentValue: Double {
        switch pledge.type {
        case .steps: return Double(healthManager.weeklySteps)
        case .distance: return healthManager.weeklyDistance
        case .activeMinutes: return healthManager.weeklyActiveEnergy
        }
    }

    private var progress: Double {
        guard pledge.targetValue > 0 else { return 0 }
        return min(currentValue / pledge.targetValue, 1.0)
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Main progress ring
            ZStack {
                // Background ring
                Circle()
                    .stroke(
                        DesignSystem.Colors.inkBlack.opacity(0.1),
                        lineWidth: 20
                    )
                    .frame(width: 200, height: 200)

                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        progressGradient,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)

                // Center content
                VStack(spacing: DesignSystem.Spacing.xxs) {
                    // Icon
                    Image(systemName: pledge.type.icon)
                        .font(.system(size: 24))
                        .foregroundColor(DesignSystem.Colors.inkBlack)

                    // Current value
                    Text(pledge.type.formatValue(currentValue))
                        .font(DesignSystem.Typography.data(32))
                        .foregroundColor(DesignSystem.Colors.inkBlack)

                    // Unit label
                    Text(pledge.type.unitLabel)
                        .font(DesignSystem.Typography.caption(12))
                        .foregroundColor(DesignSystem.Colors.inkGray)

                    // Percentage badge
                    Text("\(Int(progress * 100))%")
                        .font(DesignSystem.Typography.mono(14))
                        .fontWeight(.bold)
                        .foregroundColor(progressColor)
                        .padding(.horizontal, DesignSystem.Spacing.xs)
                        .padding(.vertical, 4)
                        .background(progressColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.vertical, DesignSystem.Spacing.md)

            // Target and time remaining
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Target")
                        .font(DesignSystem.Typography.caption(11))
                        .foregroundColor(DesignSystem.Colors.inkGray)
                        .textCase(.uppercase)

                    Text("\(pledge.type.formatValue(pledge.targetValue)) \(pledge.type.unitLabel)")
                        .font(DesignSystem.Typography.body())
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.inkBlack)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Time Left")
                        .font(DesignSystem.Typography.caption(11))
                        .foregroundColor(DesignSystem.Colors.inkGray)
                        .textCase(.uppercase)

                    Text(pledge.timeRemaining)
                        .font(DesignSystem.Typography.body())
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.inkBlack)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.sm)

            // Status badge
            StatusBadge(status: pledge.challengeStatus, size: .medium)
        }
        .padding(DesignSystem.Spacing.lg)
        .cleanCard()
    }

    private var progressGradient: LinearGradient {
        LinearGradient(
            colors: [progressColor, progressColor.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var progressColor: Color {
        if progress >= 1.0 {
            return DesignSystem.Colors.moneyGreen
        } else if progress >= 0.7 {
            return DesignSystem.Colors.mustard
        } else if progress >= 0.4 {
            return Color.orange
        } else {
            return DesignSystem.Colors.alertRed
        }
    }
}

// MARK: - Leaderboard Position Card

struct LeaderboardPositionCard: View {
    let pledge: Pledge

    // Mock leaderboard data - in production, this would come from PledgeManager
    private let mockParticipants: [LeaderboardEntry] = [
        LeaderboardEntry(
            name: "You", avatar: "🏃", progress: 0.76, isCurrentUser: true, hasFailed: false),
        LeaderboardEntry(
            name: "Sarah", avatar: "💪", progress: 1.02, isCurrentUser: false, hasFailed: false),
        LeaderboardEntry(
            name: "Mike", avatar: "🔥", progress: 0.84, isCurrentUser: false, hasFailed: false),
        LeaderboardEntry(
            name: "Emma", avatar: "⭐", progress: 0.71, isCurrentUser: false, hasFailed: false),
        LeaderboardEntry(
            name: "Dave", avatar: "😎", progress: 0.33, isCurrentUser: false, hasFailed: true),
        LeaderboardEntry(
            name: "Alex", avatar: "🎯", progress: 0.97, isCurrentUser: false, hasFailed: false),
    ]

    private var sortedParticipants: [LeaderboardEntry] {
        mockParticipants.sorted { $0.progress > $1.progress }
    }

    private var userPosition: Int? {
        sortedParticipants.firstIndex(where: { $0.isCurrentUser }).map { $0 + 1 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Text("Your Position")
                    .font(DesignSystem.Typography.title(18))
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                Spacer()

                if let position = userPosition {
                    HStack(spacing: 4) {
                        Text("#\(position)")
                            .font(DesignSystem.Typography.data(20))
                            .foregroundColor(DesignSystem.Colors.inkBlack)

                        Text("of \(sortedParticipants.count)")
                            .font(DesignSystem.Typography.caption())
                            .foregroundColor(DesignSystem.Colors.inkGray)
                    }
                }
            }

            // Top 3 participants
            VStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(Array(sortedParticipants.prefix(3).enumerated()), id: \.element.id) {
                    index, entry in
                    CompactLeaderboardRow(entry: entry, position: index + 1)
                }
            }

            if sortedParticipants.count > 3 {
                Button {
                    // Navigate to full leaderboard
                } label: {
                    HStack {
                        Text("View Full Leaderboard")
                            .font(DesignSystem.Typography.body())
                            .foregroundColor(DesignSystem.Colors.inkBlack)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(DesignSystem.Colors.inkGray)
                    }
                    .padding(.vertical, DesignSystem.Spacing.xs)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cleanCard()
    }
}

struct CompactLeaderboardRow: View {
    let entry: LeaderboardEntry
    let position: Int

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Position
            Text("\(position)")
                .font(DesignSystem.Typography.mono(16))
                .fontWeight(.bold)
                .foregroundColor(positionColor)
                .frame(width: 24)

            // Avatar
            Text(entry.avatar)
                .font(.system(size: 20))

            // Name
            Text(entry.name)
                .font(DesignSystem.Typography.body())
                .fontWeight(entry.isCurrentUser ? .semibold : .regular)
                .foregroundColor(DesignSystem.Colors.inkBlack)

            Spacer()

            // Progress
            Text("\(Int(entry.progress * 100))%")
                .font(DesignSystem.Typography.mono(14))
                .fontWeight(.semibold)
                .foregroundColor(
                    entry.progress >= 1.0
                        ? DesignSystem.Colors.moneyGreen
                        : DesignSystem.Colors.inkBlack
                )
        }
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(entry.isCurrentUser ? DesignSystem.Colors.mustard.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private var positionColor: Color {
        switch position {
        case 1: return Color.yellow.opacity(0.8)
        case 2: return Color.gray.opacity(0.6)
        case 3: return Color.orange.opacity(0.6)
        default: return DesignSystem.Colors.inkGray
        }
    }
}

// MARK: - Daily Breakdown Card

struct DailyBreakdownCard: View {
    let pledge: Pledge
    let healthManager: HealthManager

    private var dailyData: [DailyProgressData] {
        // Generate mock daily data based on pledge type
        healthManager.last7Days.map { date in
            let calendar = Calendar.current
            let dayOfWeek = calendar.component(.weekday, from: date)

            // Mock value based on day
            let mockValue: Double = {
                switch dayOfWeek {
                case 1, 7: return Double.random(in: 0.6...0.9)  // Weekend
                default: return Double.random(in: 0.7...1.2)  // Weekday
                }
            }()

            let dailyTarget = pledge.targetValue / 7.0
            let value = dailyTarget * mockValue

            return DailyProgressData(date: date, value: value, target: dailyTarget)
        }
    }

    private var maxValue: Double {
        dailyData.map { max($0.value, $0.target) }.max() ?? 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Daily Breakdown")
                .font(DesignSystem.Typography.title(18))
                .foregroundColor(DesignSystem.Colors.inkBlack)

            // Bar chart
            HStack(alignment: .bottom, spacing: DesignSystem.Spacing.xs) {
                ForEach(dailyData, id: \.date) { data in
                    DailyBar(
                        data: data,
                        maxValue: maxValue,
                        unit: pledge.type.unitLabel
                    )
                }
            }
            .frame(height: 160)
        }
        .padding(DesignSystem.Spacing.md)
        .cleanCard()
    }
}

struct DailyProgressData {
    let date: Date
    let value: Double
    let target: Double

    var dayAbbreviation: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var progress: Double {
        guard target > 0 else { return 0 }
        return value / target
    }
}

struct DailyBar: View {
    let data: DailyProgressData
    let maxValue: Double
    let unit: String

    private var normalizedHeight: Double {
        guard maxValue > 0 else { return 0 }
        return data.value / maxValue
    }

    var body: some View {
        VStack(spacing: 4) {
            // Bar
            ZStack(alignment: .bottom) {
                // Background (target line)
                Rectangle()
                    .fill(DesignSystem.Colors.inkBlack.opacity(0.05))
                    .frame(height: CGFloat(data.target / maxValue) * 160)

                // Actual value
                Rectangle()
                    .fill(barColor)
                    .frame(height: CGFloat(normalizedHeight) * 160)
            }
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(
                        data.isToday ? DesignSystem.Colors.inkBlack : Color.clear,
                        lineWidth: 2
                    )
            )

            // Day label
            Text(data.dayAbbreviation)
                .font(DesignSystem.Typography.caption(10))
                .foregroundColor(
                    data.isToday ? DesignSystem.Colors.inkBlack : DesignSystem.Colors.inkGray
                )
                .fontWeight(data.isToday ? .bold : .regular)
        }
    }

    private var barColor: Color {
        if data.progress >= 1.0 {
            return DesignSystem.Colors.moneyGreen
        } else if data.progress >= 0.7 {
            return DesignSystem.Colors.mustard
        } else {
            return DesignSystem.Colors.alertRed
        }
    }
}

// MARK: - Stake Card

struct StakeCard: View {
    let pledge: Pledge

    // Mock survivor count
    private let survivorCount = 4
    private let totalParticipants = 6

    private var potentialPayout: Double {
        guard survivorCount > 0 else { return 0 }
        return pledge.potValue / Double(survivorCount)
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("The Stakes")
                    .font(DesignSystem.Typography.title(18))
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                Spacer()
            }

            // Pot value
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Pot")
                        .font(DesignSystem.Typography.caption(11))
                        .foregroundColor(DesignSystem.Colors.inkGray)
                        .textCase(.uppercase)

                    Text("$\(String(format: "%.2f", pledge.potValue))")
                        .font(DesignSystem.Typography.data(28))
                        .foregroundColor(DesignSystem.Colors.moneyGreen)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    // SEMANTIC FIREWALL: "Survivors" not "Winners"
                    Text("\(survivorCount) Survivors")
                        .font(DesignSystem.Typography.caption(11))
                        .foregroundColor(DesignSystem.Colors.inkGray)
                        .textCase(.uppercase)

                    Text("$\(String(format: "%.2f", potentialPayout))")
                        .font(DesignSystem.Typography.data(28))
                        .foregroundColor(DesignSystem.Colors.inkBlack)
                }
            }

            Divider()
                .background(DesignSystem.Colors.inkBlack.opacity(0.2))

            // Your stake
            HStack {
                Text("Your Stake")
                    .font(DesignSystem.Typography.body())
                    .foregroundColor(DesignSystem.Colors.inkGray)

                Spacer()

                Text("$\(String(format: "%.2f", pledge.potValue / Double(totalParticipants)))")
                    .font(DesignSystem.Typography.mono(16))
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.inkBlack)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cleanCard()
    }
}

// MARK: - Previews

#Preview("Pledge Detail - Steps") {
    NavigationStack {
        PledgeDetailView(
            pledge: Pledge.mockStepChallenge,
            healthManager: HealthManager.preview,
            pledgeManager: PledgeManager(healthManager: HealthManager.preview)
        )
    }
}

#Preview("Progress Ring") {
    ProgressRingCard(
        pledge: Pledge.mockStepChallenge,
        healthManager: HealthManager.preview
    )
    .padding()
    .background(DesignSystem.Colors.background)
}

#Preview("Daily Breakdown") {
    DailyBreakdownCard(
        pledge: Pledge.mockStepChallenge,
        healthManager: HealthManager.preview
    )
    .padding()
    .background(DesignSystem.Colors.background)
}
