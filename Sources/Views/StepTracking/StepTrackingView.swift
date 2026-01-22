//
//  StepTrackingView.swift
//  BetterBet
//
//  Detailed step tracking view with progress ring, daily breakdown,
//  and pace indicators tied to the user's active pledge.
//
//  SEMANTIC FIREWALL NOTICE:
//  - "Commitment Progress" not "Bet Progress"
//  - "Stake at Risk" not "Money on the Line"
//  - "Fulfill Goal" not "Win Bet"
//

import SwiftUI

/// Detailed step tracking view showing progress toward pledge target.
struct StepTrackingView: View {
    @Bindable var pledge: Pledge
    var healthManager: HealthManager
    var pledgeManager: PledgeManager

    @State private var isRefreshing = false
    @State private var selectedDay: DailyProgress?

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Progress Ring Section
                ProgressRingCard(
                    pledge: pledge,
                    healthManager: healthManager,
                    pledgeManager: pledgeManager
                )

                // Today's Stats
                TodayStatsCard(
                    pledge: pledge,
                    healthManager: healthManager,
                    pledgeManager: pledgeManager
                )

                // Weekly Breakdown
                WeeklyBreakdownCard(
                    pledge: pledge,
                    pledgeManager: pledgeManager,
                    selectedDay: $selectedDay
                )

                // Pace Indicator
                PaceIndicatorCard(
                    pledge: pledge,
                    pledgeManager: pledgeManager
                )

                // Stake Summary
                StakeSummaryCard(pledge: pledge)
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
    let pledgeManager: PledgeManager

    private var currentValue: Double {
        switch pledge.type {
        case .steps: return Double(healthManager.weeklySteps)
        case .distance: return healthManager.weeklyDistance
        case .activeEnergy: return healthManager.weeklyActiveEnergy
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
                        style: StrokeStyle(
                            lineWidth: 20,
                            lineCap: .round
                        )
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)

                // Center content
                VStack(spacing: DesignSystem.Spacing.xxs) {
                    // Icon
                    Image(systemName: pledge.type.icon)
                        .font(.system(size: 24))
                        .foregroundColor(DesignSystem.Colors.inkGray)

                    // Current value
                    Text(pledge.type.formatValue(currentValue))
                        .font(DesignSystem.Typography.data(42))
                        .foregroundColor(DesignSystem.Colors.inkBlack)

                    // Target
                    Text("of \(pledge.type.formatValue(pledge.targetValue))")
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.inkGray)

                    // Percentage
                    Text("\(Int(progress * 100))%")
                        .font(DesignSystem.Typography.mono(16))
                        .fontWeight(.bold)
                        .foregroundColor(progressColor)
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, 4)
                        .background(progressColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.vertical, DesignSystem.Spacing.md)

            // Time remaining
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(DesignSystem.Colors.inkGray)

                Text(pledge.timeRemaining)
                    .font(DesignSystem.Typography.body())
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                Spacer()

                StatusBadge(status: pledge.challengeStatus, size: .medium)
            }
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

// MARK: - Today's Stats Card

struct TodayStatsCard: View {
    let pledge: Pledge
    let healthManager: HealthManager
    let pledgeManager: PledgeManager

    private var todayValue: Double {
        switch pledge.type {
        case .steps: return Double(healthManager.todaySteps)
        case .distance: return healthManager.todayDistance
        case .activeEnergy: return healthManager.todayActiveEnergy
        }
    }

    private var dailyTarget: Double {
        pledgeManager.getDailyTarget(for: pledge)
    }

    private var todayProgress: Double {
        guard dailyTarget > 0 else { return 0 }
        return min(todayValue / dailyTarget, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Text("Today")
                    .font(DesignSystem.Typography.title(18))
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                Spacer()

                // Live indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(DesignSystem.Colors.moneyGreen)
                        .frame(width: 8, height: 8)
                    Text("Live")
                        .font(DesignSystem.Typography.caption(11))
                        .foregroundColor(DesignSystem.Colors.inkGray)
                }
            }

            HStack(spacing: DesignSystem.Spacing.lg) {
                // Today's progress
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text(pledge.type.formatValue(todayValue))
                        .font(DesignSystem.Typography.data(32))
                        .foregroundColor(DesignSystem.Colors.inkBlack)

                    Text("\(pledge.type.unitLabel) today")
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.inkGray)
                }

                Spacer()

                // Daily target needed
                VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xxs) {
                    Text(pledge.type.formatValue(dailyTarget))
                        .font(DesignSystem.Typography.data(24))
                        .foregroundColor(dailyTarget <= todayValue
                                        ? DesignSystem.Colors.moneyGreen
                                        : DesignSystem.Colors.inkBlack)

                    Text("daily target")
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.inkGray)
                }
            }

            // Mini progress bar for today
            VStack(spacing: DesignSystem.Spacing.xxs) {
                ProgressBar(
                    progress: todayProgress,
                    fillColor: todayProgress >= 1.0 ? DesignSystem.Colors.moneyGreen : DesignSystem.Colors.inkBlack,
                    height: 8
                )

                HStack {
                    Text(todayProgress >= 1.0 ? "Daily goal met!" : "\(Int(todayProgress * 100))% of daily goal")
                        .font(DesignSystem.Typography.caption(11))
                        .foregroundColor(todayProgress >= 1.0
                                        ? DesignSystem.Colors.moneyGreen
                                        : DesignSystem.Colors.inkGray)

                    Spacer()

                    if dailyTarget > todayValue {
                        let remaining = dailyTarget - todayValue
                        Text("\(pledge.type.formatValue(remaining)) to go")
                            .font(DesignSystem.Typography.caption(11))
                            .foregroundColor(DesignSystem.Colors.inkGray)
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cleanCard()
    }
}

// MARK: - Weekly Breakdown Card

struct WeeklyBreakdownCard: View {
    let pledge: Pledge
    let pledgeManager: PledgeManager
    @Binding var selectedDay: DailyProgress?

    private var dailyBreakdown: [DailyProgress] {
        pledgeManager.getDailyBreakdown(for: pledge)
    }

    private var maxValue: Double {
        let maxData = dailyBreakdown.map { $0.value }.max() ?? 1
        let target = dailyBreakdown.first?.target ?? 1
        return max(maxData, target) * 1.1 // 10% padding
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Text("This Week")
                    .font(DesignSystem.Typography.title(18))
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                Spacer()

                // Days met target
                let daysMet = dailyBreakdown.filter { $0.metTarget }.count
                Text("\(daysMet)/7 days")
                    .font(DesignSystem.Typography.caption())
                    .foregroundColor(DesignSystem.Colors.inkGray)
            }

            // Bar chart
            HStack(alignment: .bottom, spacing: DesignSystem.Spacing.xs) {
                ForEach(dailyBreakdown) { day in
                    DailyBarView(
                        day: day,
                        maxValue: maxValue,
                        isSelected: selectedDay?.id == day.id,
                        onTap: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedDay = selectedDay?.id == day.id ? nil : day
                            }
                        }
                    )
                }
            }
            .frame(height: 150)

            // Target line label
            HStack {
                Rectangle()
                    .fill(DesignSystem.Colors.mustard)
                    .frame(width: 16, height: 2)

                Text("Daily target: \(pledge.type.formatValue(dailyBreakdown.first?.target ?? 0))")
                    .font(DesignSystem.Typography.caption(11))
                    .foregroundColor(DesignSystem.Colors.inkGray)

                Spacer()
            }

            // Selected day detail
            if let day = selectedDay {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(day.date, format: .dateTime.weekday(.wide).month().day())
                            .font(DesignSystem.Typography.body())
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.inkBlack)

                        Text("\(day.formattedValue) \(pledge.type.unitLabel)")
                            .font(DesignSystem.Typography.caption())
                            .foregroundColor(DesignSystem.Colors.inkGray)
                    }

                    Spacer()

                    if day.metTarget {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(DesignSystem.Colors.moneyGreen)
                            Text("Target met")
                                .font(DesignSystem.Typography.caption())
                                .foregroundColor(DesignSystem.Colors.moneyGreen)
                        }
                    } else {
                        let shortfall = day.target - day.value
                        Text("-\(pledge.type.formatValue(shortfall)) short")
                            .font(DesignSystem.Typography.caption())
                            .foregroundColor(DesignSystem.Colors.alertRed)
                    }
                }
                .padding(DesignSystem.Spacing.sm)
                .background(DesignSystem.Colors.background)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusSmall))
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cleanCard()
    }
}

struct DailyBarView: View {
    let day: DailyProgress
    let maxValue: Double
    let isSelected: Bool
    let onTap: () -> Void

    private var barHeight: CGFloat {
        guard maxValue > 0 else { return 0 }
        return CGFloat(day.value / maxValue) * 120
    }

    private var targetHeight: CGFloat {
        guard maxValue > 0 else { return 0 }
        return CGFloat(day.target / maxValue) * 120
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            // Bar container
            ZStack(alignment: .bottom) {
                // Background
                RoundedRectangle(cornerRadius: 4)
                    .fill(DesignSystem.Colors.background)
                    .frame(height: 120)

                // Target line
                Rectangle()
                    .fill(DesignSystem.Colors.mustard)
                    .frame(height: 2)
                    .offset(y: -targetHeight + 1)

                // Value bar
                RoundedRectangle(cornerRadius: 4)
                    .fill(barColor)
                    .frame(height: max(4, barHeight))
            }
            .frame(maxWidth: .infinity)

            // Day label
            Text(day.dayName)
                .font(DesignSystem.Typography.caption(11))
                .fontWeight(day.isToday ? .bold : .regular)
                .foregroundColor(day.isToday ? DesignSystem.Colors.inkBlack : DesignSystem.Colors.inkGray)
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .onTapGesture { onTap() }
    }

    private var barColor: Color {
        if day.value == 0 {
            return DesignSystem.Colors.inkGray.opacity(0.2)
        } else if day.metTarget {
            return DesignSystem.Colors.moneyGreen
        } else if day.progressPercentage >= 0.7 {
            return DesignSystem.Colors.mustard
        } else {
            return DesignSystem.Colors.alertRed.opacity(0.7)
        }
    }
}

// MARK: - Pace Indicator Card

struct PaceIndicatorCard: View {
    let pledge: Pledge
    let pledgeManager: PledgeManager

    private var paceStatus: PaceStatus {
        pledgeManager.getPaceIndicator(for: pledge)
    }

    private var expectedProgress: Double {
        pledgeManager.getExpectedProgress(for: pledge)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Text("Pace Check")
                    .font(DesignSystem.Typography.title(18))
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                Spacer()

                // Pace badge
                HStack(spacing: 4) {
                    Image(systemName: paceIcon)
                        .foregroundColor(paceColor)

                    Text(paceStatus.displayText)
                        .font(DesignSystem.Typography.caption())
                        .fontWeight(.semibold)
                        .foregroundColor(paceColor)
                }
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, 6)
                .background(paceColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Pace visualization
            VStack(spacing: DesignSystem.Spacing.xs) {
                // Progress bars comparison
                HStack(spacing: DesignSystem.Spacing.md) {
                    // Expected progress
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Expected")
                            .font(DesignSystem.Typography.caption(11))
                            .foregroundColor(DesignSystem.Colors.inkGray)

                        ProgressBar(
                            progress: expectedProgress,
                            fillColor: DesignSystem.Colors.inkGray,
                            height: 8
                        )

                        Text("\(Int(expectedProgress * 100))%")
                            .font(DesignSystem.Typography.mono(12))
                            .foregroundColor(DesignSystem.Colors.inkGray)
                    }

                    // Actual progress
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Actual")
                            .font(DesignSystem.Typography.caption(11))
                            .foregroundColor(DesignSystem.Colors.inkBlack)

                        ProgressBar(
                            progress: pledge.progressPercentage,
                            fillColor: paceColor,
                            height: 8
                        )

                        Text("\(Int(pledge.progressPercentage * 100))%")
                            .font(DesignSystem.Typography.mono(12))
                            .fontWeight(.semibold)
                            .foregroundColor(paceColor)
                    }
                }
            }

            // Pace message
            Text(paceMessage)
                .font(DesignSystem.Typography.body())
                .foregroundColor(DesignSystem.Colors.inkGray)
                .padding(.top, DesignSystem.Spacing.xxs)
        }
        .padding(DesignSystem.Spacing.md)
        .cleanCard()
    }

    private var paceIcon: String {
        switch paceStatus {
        case .aheadOfPace: return "arrow.up.right.circle.fill"
        case .onPace: return "equal.circle.fill"
        case .behindPace: return "arrow.down.right.circle.fill"
        }
    }

    private var paceColor: Color {
        switch paceStatus {
        case .aheadOfPace: return DesignSystem.Colors.moneyGreen
        case .onPace: return DesignSystem.Colors.inkBlack
        case .behindPace: return DesignSystem.Colors.alertRed
        }
    }

    private var paceMessage: String {
        switch paceStatus {
        case .aheadOfPace:
            return "Great work! Keep this pace and you'll easily fulfill your commitment."
        case .onPace:
            return "You're right on track. Maintain your current effort to meet your goal."
        case .behindPace:
            return "You're falling behind. Pick up the pace to protect your stake!"
        }
    }
}

// MARK: - Stake Summary Card

struct StakeSummaryCard: View {
    let pledge: Pledge

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Your Stake")
                .font(DesignSystem.Typography.title(18))
                .foregroundColor(DesignSystem.Colors.inkBlack)

            HStack(spacing: DesignSystem.Spacing.lg) {
                // Your stake
                VStack(alignment: .leading, spacing: 4) {
                    Text("At Risk")
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.inkGray)

                    Text("$\(Int(pledge.stakeAmount))")
                        .font(DesignSystem.Typography.data(28))
                        .foregroundColor(DesignSystem.Colors.inkBlack)
                }

                Spacer()

                // Potential reward (if others fail)
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total Pot")
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.inkGray)

                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(DesignSystem.Colors.moneyGreen)

                        Text("$\(Int(pledge.potValue))")
                            .font(DesignSystem.Typography.data(28))
                            .foregroundColor(DesignSystem.Colors.moneyGreen)
                    }
                }
            }

            // Participants
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundColor(DesignSystem.Colors.inkGray)

                Text("\(pledge.participantCount) participants")
                    .font(DesignSystem.Typography.caption())
                    .foregroundColor(DesignSystem.Colors.inkGray)

                Spacer()

                // SEMANTIC FIREWALL: "fulfill" not "win"
                Text("Fulfill to split the pot")
                    .font(DesignSystem.Typography.caption(11))
                    .foregroundColor(DesignSystem.Colors.inkGray)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cleanCard()
    }
}

// MARK: - Previews

#Preview("Step Tracking View") {
    NavigationStack {
        StepTrackingView(
            pledge: Pledge.mockStepChallenge,
            healthManager: HealthManager.preview,
            pledgeManager: PledgeManager.preview
        )
    }
}

#Preview("Progress Ring Card") {
    ProgressRingCard(
        pledge: Pledge.mockStepChallenge,
        healthManager: HealthManager.preview,
        pledgeManager: PledgeManager.preview
    )
    .padding()
    .background(DesignSystem.Colors.background)
}

#Preview("Weekly Breakdown") {
    WeeklyBreakdownCard(
        pledge: Pledge.mockStepChallenge,
        pledgeManager: PledgeManager.preview,
        selectedDay: .constant(nil)
    )
    .padding()
    .background(DesignSystem.Colors.background)
}
