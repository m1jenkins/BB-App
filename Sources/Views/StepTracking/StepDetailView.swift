//
//  StepDetailView.swift
//  BetterBet
//
//  Detailed hourly breakdown and historical analysis for step tracking.
//  Shows granular data to help users understand their activity patterns.
//
//  SEMANTIC FIREWALL NOTICE:
//  - "Activity patterns" not "betting patterns"
//  - "Commitment history" not "betting history"
//

import SwiftUI

/// Detailed step analysis view with hourly breakdown and history.
struct StepDetailView: View {
    var healthManager: HealthManager
    var pledge: Pledge?

    @State private var selectedTimeframe: TimeFrame = .today
    @State private var hourlyData: [HourlyStepData] = []

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Timeframe Selector
                TimeframePicker(selected: $selectedTimeframe)

                // Stats Overview
                StatsOverviewCard(
                    healthManager: healthManager,
                    timeframe: selectedTimeframe
                )

                // Hourly Breakdown (for Today)
                if selectedTimeframe == .today {
                    HourlyBreakdownCard(hourlyData: hourlyData)
                }

                // Activity Timeline
                ActivityTimelineCard(
                    healthManager: healthManager,
                    timeframe: selectedTimeframe
                )

                // Streak & Achievements
                StreakCard(healthManager: healthManager)

                // Tips Section
                ActivityTipsCard(healthManager: healthManager)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .background(DesignSystem.Colors.background)
        .navigationTitle("Step Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            loadHourlyData()
        }
    }

    private func loadHourlyData() {
        // Generate mock hourly data for today
        let calendar = Calendar.current
        let now = Date()
        let currentHour = calendar.component(.hour, from: now)

        hourlyData = (0...currentHour).map { hour in
            let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: now)!
            let steps: Int

            // Simulate realistic hourly step patterns
            switch hour {
            case 0...5: steps = Int.random(in: 0...50)
            case 6...7: steps = Int.random(in: 100...400)
            case 8...9: steps = Int.random(in: 500...1200)
            case 10...11: steps = Int.random(in: 300...800)
            case 12...13: steps = Int.random(in: 400...1000)
            case 14...16: steps = Int.random(in: 200...600)
            case 17...18: steps = Int.random(in: 600...1500)
            case 19...21: steps = Int.random(in: 200...800)
            case 22...23: steps = Int.random(in: 50...200)
            default: steps = Int.random(in: 100...500)
            }

            return HourlyStepData(hour: hour, date: date, steps: steps)
        }
    }
}

// MARK: - Supporting Types

enum TimeFrame: String, CaseIterable, Identifiable {
    case today = "Today"
    case week = "Week"
    case month = "Month"

    var id: String { rawValue }
}

struct HourlyStepData: Identifiable {
    let id = UUID()
    let hour: Int
    let date: Date
    let steps: Int

    var hourLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        return formatter.string(from: date).lowercased()
    }

    var isCurrentHour: Bool {
        Calendar.current.component(.hour, from: Date()) == hour
    }
}

// MARK: - Timeframe Picker

struct TimeframePicker: View {
    @Binding var selected: TimeFrame

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TimeFrame.allCases) { frame in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selected = frame
                    }
                } label: {
                    Text(frame.rawValue)
                        .font(DesignSystem.Typography.body())
                        .fontWeight(selected == frame ? .semibold : .regular)
                        .foregroundColor(selected == frame ? .white : DesignSystem.Colors.inkBlack)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .background(
                            selected == frame
                            ? DesignSystem.Colors.inkBlack
                            : Color.clear
                        )
                }
            }
        }
        .background(DesignSystem.Colors.cardWhite)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusMedium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusMedium)
                .stroke(DesignSystem.Colors.inkBlack, lineWidth: DesignSystem.Borders.thickness)
        )
    }
}

// MARK: - Stats Overview Card

struct StatsOverviewCard: View {
    let healthManager: HealthManager
    let timeframe: TimeFrame

    private var steps: Int {
        switch timeframe {
        case .today: return healthManager.todaySteps
        case .week: return healthManager.weeklySteps
        case .month: return healthManager.weeklySteps * 4 // Mock monthly
        }
    }

    private var distance: Double {
        switch timeframe {
        case .today: return healthManager.todayDistance
        case .week: return healthManager.weeklyDistance
        case .month: return healthManager.weeklyDistance * 4
        }
    }

    private var calories: Double {
        switch timeframe {
        case .today: return healthManager.todayActiveEnergy
        case .week: return healthManager.weeklyActiveEnergy
        case .month: return healthManager.weeklyActiveEnergy * 4
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Overview")
                .font(DesignSystem.Typography.title(18))
                .foregroundColor(DesignSystem.Colors.inkBlack)

            // Main stat
            HStack(alignment: .firstTextBaseline, spacing: DesignSystem.Spacing.xs) {
                Text(steps.formatted())
                    .font(DesignSystem.Typography.data(48))
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                Text("steps")
                    .font(DesignSystem.Typography.body())
                    .foregroundColor(DesignSystem.Colors.inkGray)
            }

            // Secondary stats
            HStack(spacing: DesignSystem.Spacing.md) {
                SecondaryStatItem(
                    icon: "map",
                    value: String(format: "%.1f", distance),
                    unit: "mi"
                )

                SecondaryStatItem(
                    icon: "flame.fill",
                    value: "\(Int(calories))",
                    unit: "kcal"
                )

                SecondaryStatItem(
                    icon: "clock",
                    value: "\(Int(Double(steps) / 100))",
                    unit: "min active"
                )
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cleanCard()
    }
}

struct SecondaryStatItem: View {
    let icon: String
    let value: String
    let unit: String

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(DesignSystem.Colors.inkGray)

            Text(value)
                .font(DesignSystem.Typography.mono(14))
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.inkBlack)

            Text(unit)
                .font(DesignSystem.Typography.caption(11))
                .foregroundColor(DesignSystem.Colors.inkGray)
        }
    }
}

// MARK: - Hourly Breakdown Card

struct HourlyBreakdownCard: View {
    let hourlyData: [HourlyStepData]

    private var maxSteps: Int {
        hourlyData.map { $0.steps }.max() ?? 1
    }

    private var totalSteps: Int {
        hourlyData.reduce(0) { $0 + $1.steps }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Text("Hourly Breakdown")
                    .font(DesignSystem.Typography.title(18))
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                Spacer()

                Text("\(totalSteps.formatted()) total")
                    .font(DesignSystem.Typography.caption())
                    .foregroundColor(DesignSystem.Colors.inkGray)
            }

            // Hourly bar chart
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(hourlyData) { data in
                        VStack(spacing: 4) {
                            // Steps label (shown for peak hours)
                            if data.steps == maxSteps || data.isCurrentHour {
                                Text("\(data.steps)")
                                    .font(DesignSystem.Typography.caption(9))
                                    .foregroundColor(DesignSystem.Colors.inkGray)
                            } else {
                                Text(" ")
                                    .font(DesignSystem.Typography.caption(9))
                            }

                            // Bar
                            RoundedRectangle(cornerRadius: 2)
                                .fill(barColor(for: data))
                                .frame(
                                    width: 14,
                                    height: max(4, CGFloat(data.steps) / CGFloat(maxSteps) * 80)
                                )

                            // Hour label
                            Text(data.hourLabel)
                                .font(DesignSystem.Typography.caption(8))
                                .foregroundColor(
                                    data.isCurrentHour
                                    ? DesignSystem.Colors.inkBlack
                                    : DesignSystem.Colors.inkGray
                                )
                        }
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.xs)
            }

            // Activity insights
            HStack(spacing: DesignSystem.Spacing.md) {
                if let peakHour = hourlyData.max(by: { $0.steps < $1.steps }) {
                    InsightChip(
                        icon: "arrow.up",
                        text: "Peak at \(peakHour.hourLabel)"
                    )
                }

                let activeHours = hourlyData.filter { $0.steps > 500 }.count
                InsightChip(
                    icon: "clock",
                    text: "\(activeHours)h active"
                )
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cleanCard()
    }

    private func barColor(for data: HourlyStepData) -> Color {
        if data.isCurrentHour {
            return DesignSystem.Colors.moneyGreen
        } else if data.steps > 1000 {
            return DesignSystem.Colors.inkBlack
        } else if data.steps > 500 {
            return DesignSystem.Colors.inkBlack.opacity(0.7)
        } else if data.steps > 100 {
            return DesignSystem.Colors.inkGray.opacity(0.5)
        } else {
            return DesignSystem.Colors.inkGray.opacity(0.2)
        }
    }
}

struct InsightChip: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))

            Text(text)
                .font(DesignSystem.Typography.caption(11))
        }
        .foregroundColor(DesignSystem.Colors.inkGray)
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, 6)
        .background(DesignSystem.Colors.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Activity Timeline Card

struct ActivityTimelineCard: View {
    let healthManager: HealthManager
    let timeframe: TimeFrame

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Activity Timeline")
                .font(DesignSystem.Typography.title(18))
                .foregroundColor(DesignSystem.Colors.inkBlack)

            // Timeline entries
            VStack(spacing: 0) {
                TimelineEntry(
                    time: "8:30 AM",
                    title: "Morning Walk",
                    detail: "2,340 steps",
                    icon: "sun.max.fill",
                    iconColor: .orange,
                    isLast: false
                )

                TimelineEntry(
                    time: "12:15 PM",
                    title: "Lunch Break",
                    detail: "1,120 steps",
                    icon: "fork.knife",
                    iconColor: DesignSystem.Colors.inkGray,
                    isLast: false
                )

                TimelineEntry(
                    time: "5:45 PM",
                    title: "Evening Run",
                    detail: "4,892 steps",
                    icon: "figure.run",
                    iconColor: DesignSystem.Colors.moneyGreen,
                    isLast: true
                )
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cleanCard()
    }
}

struct TimelineEntry: View {
    let time: String
    let title: String
    let detail: String
    let icon: String
    let iconColor: Color
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
            // Timeline indicator
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(iconColor)
                }

                if !isLast {
                    Rectangle()
                        .fill(DesignSystem.Colors.inkGray.opacity(0.2))
                        .frame(width: 2, height: 30)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .font(DesignSystem.Typography.body())
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.inkBlack)

                    Spacer()

                    Text(time)
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.inkGray)
                }

                Text(detail)
                    .font(DesignSystem.Typography.caption())
                    .foregroundColor(DesignSystem.Colors.inkGray)
            }
            .padding(.bottom, isLast ? 0 : DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Streak Card

struct StreakCard: View {
    let healthManager: HealthManager

    // Mock streak data
    private let currentStreak = 5
    private let longestStreak = 12
    private let dailyGoal = 10000

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Streaks")
                .font(DesignSystem.Typography.title(18))
                .foregroundColor(DesignSystem.Colors.inkBlack)

            HStack(spacing: DesignSystem.Spacing.md) {
                // Current streak
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)

                        Text("\(currentStreak)")
                            .font(DesignSystem.Typography.data(32))
                            .foregroundColor(DesignSystem.Colors.inkBlack)
                    }

                    Text("day streak")
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.inkGray)
                }

                Spacer()

                // Best streak
                VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xxs) {
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(DesignSystem.Colors.mustard)

                        Text("\(longestStreak)")
                            .font(DesignSystem.Typography.data(24))
                            .foregroundColor(DesignSystem.Colors.inkBlack)
                    }

                    Text("best streak")
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.inkGray)
                }
            }

            // Weekly streak visualization
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(0..<7, id: \.self) { day in
                    let isCompleted = day < currentStreak
                    let isToday = day == currentStreak

                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(
                                    isCompleted
                                    ? DesignSystem.Colors.moneyGreen
                                    : (isToday ? DesignSystem.Colors.mustard.opacity(0.3) : DesignSystem.Colors.background)
                                )
                                .frame(width: 36, height: 36)

                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            } else if isToday {
                                Text("?")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(DesignSystem.Colors.mustard)
                            }
                        }

                        Text(dayLabel(for: day))
                            .font(DesignSystem.Typography.caption(10))
                            .foregroundColor(
                                isToday
                                ? DesignSystem.Colors.inkBlack
                                : DesignSystem.Colors.inkGray
                            )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cleanCard()
    }

    private func dayLabel(for offset: Int) -> String {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: offset - currentStreak, to: Date())!
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

// MARK: - Activity Tips Card

struct ActivityTipsCard: View {
    let healthManager: HealthManager

    // Generate contextual tips based on activity
    private var tips: [ActivityTip] {
        var result: [ActivityTip] = []

        if healthManager.todaySteps < 5000 {
            result.append(ActivityTip(
                icon: "lightbulb.fill",
                title: "Get Moving",
                description: "Take a 10-minute walk to boost your step count",
                color: DesignSystem.Colors.mustard
            ))
        }

        if healthManager.todaySteps > 8000 {
            result.append(ActivityTip(
                icon: "star.fill",
                title: "Great Progress",
                description: "You're on track to meet your daily goal!",
                color: DesignSystem.Colors.moneyGreen
            ))
        }

        result.append(ActivityTip(
            icon: "clock.badge.checkmark",
            title: "Consistency Matters",
            description: "Regular activity throughout the day is better than one long session",
            color: DesignSystem.Colors.inkGray
        ))

        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Tips")
                .font(DesignSystem.Typography.title(18))
                .foregroundColor(DesignSystem.Colors.inkBlack)

            ForEach(tips) { tip in
                HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                    ZStack {
                        Circle()
                            .fill(tip.color.opacity(0.1))
                            .frame(width: 36, height: 36)

                        Image(systemName: tip.icon)
                            .font(.system(size: 14))
                            .foregroundColor(tip.color)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(tip.title)
                            .font(DesignSystem.Typography.body())
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.inkBlack)

                        Text(tip.description)
                            .font(DesignSystem.Typography.caption())
                            .foregroundColor(DesignSystem.Colors.inkGray)
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cleanCard()
    }
}

struct ActivityTip: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Previews

#Preview("Step Detail View") {
    NavigationStack {
        StepDetailView(
            healthManager: HealthManager.preview,
            pledge: Pledge.mockStepChallenge
        )
    }
}

#Preview("Hourly Breakdown") {
    HourlyBreakdownCard(hourlyData: [
        HourlyStepData(hour: 6, date: Date(), steps: 150),
        HourlyStepData(hour: 7, date: Date(), steps: 320),
        HourlyStepData(hour: 8, date: Date(), steps: 890),
        HourlyStepData(hour: 9, date: Date(), steps: 1240),
        HourlyStepData(hour: 10, date: Date(), steps: 560),
        HourlyStepData(hour: 11, date: Date(), steps: 480),
        HourlyStepData(hour: 12, date: Date(), steps: 720),
    ])
    .padding()
    .background(DesignSystem.Colors.background)
}

#Preview("Streak Card") {
    StreakCard(healthManager: HealthManager.preview)
        .padding()
        .background(DesignSystem.Colors.background)
}
