//
//  ChallengeHistoryView.swift
//  BetterBet
//
//  Scrollable list of past pledges showing outcomes and earnings.
//
//  SEMANTIC FIREWALL NOTICE:
//  - "Fulfilled" not "Won"
//  - "Failed" not "Lost"
//  - "Pledges" not "Bets"
//

import SwiftUI

// MARK: - Challenge History View

/// Shows past pledge history grouped by time period.
struct ChallengeHistoryView: View {
    @State private var pastPledges: [PastPledge] = PastPledge.mockHistory

    private var totalFulfilled: Int {
        pastPledges.filter { $0.outcome == .fulfilled }.count
    }

    private var totalEarned: Double {
        pastPledges.filter { $0.outcome == .fulfilled }.reduce(0) { $0 + $1.earned }
    }

    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()

            if pastPledges.isEmpty {
                EmptyHistoryView()
            } else {
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        // Summary header
                        HistorySummaryCard(
                            totalPledges: pastPledges.count,
                            fulfilled: totalFulfilled,
                            totalEarned: totalEarned
                        )

                        // Pledge list
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            ForEach(pastPledges) { pledge in
                                PastPledgeRow(pledge: pledge)
                            }
                        }

                        Spacer()
                            .frame(height: DesignSystem.Spacing.xl)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.top, DesignSystem.Spacing.sm)
                }
            }
        }
        .navigationTitle("Challenge History")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - History Summary Card

/// Top card showing aggregate stats for challenge history.
struct HistorySummaryCard: View {
    let totalPledges: Int
    let fulfilled: Int
    let totalEarned: Double

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            VStack(spacing: DesignSystem.Spacing.xxs) {
                Text("\(totalPledges)")
                    .font(DesignSystem.Typography.data(28))
                    .foregroundColor(DesignSystem.Colors.inkBlack)
                Text("Pledges")
                    .font(DesignSystem.Typography.caption(12))
                    .foregroundColor(DesignSystem.Colors.inkGray)
            }

            Rectangle()
                .fill(DesignSystem.Colors.inkBlack.opacity(0.1))
                .frame(width: 1, height: 40)

            VStack(spacing: DesignSystem.Spacing.xxs) {
                Text("\(fulfilled)")
                    .font(DesignSystem.Typography.data(28))
                    .foregroundColor(DesignSystem.Colors.moneyGreen)
                Text("Fulfilled")
                    .font(DesignSystem.Typography.caption(12))
                    .foregroundColor(DesignSystem.Colors.inkGray)
            }

            Rectangle()
                .fill(DesignSystem.Colors.inkBlack.opacity(0.1))
                .frame(width: 1, height: 40)

            VStack(spacing: DesignSystem.Spacing.xxs) {
                Text(String(format: "$%.0f", totalEarned))
                    .font(DesignSystem.Typography.data(28))
                    .foregroundColor(DesignSystem.Colors.moneyGreen)
                Text("Earned")
                    .font(DesignSystem.Typography.caption(12))
                    .foregroundColor(DesignSystem.Colors.inkGray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.lg)
        .cleanCard()
    }
}

// MARK: - Past Pledge Row

/// Single row displaying a completed pledge.
struct PastPledgeRow: View {
    let pledge: PastPledge

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Game mode icon
            ZStack {
                Circle()
                    .fill(
                        pledge.outcome == .fulfilled
                            ? DesignSystem.Colors.moneyGreen.opacity(0.12)
                            : DesignSystem.Colors.alertRed.opacity(0.1)
                    )
                    .frame(width: 44, height: 44)

                Text(pledge.modeIcon)
                    .font(.system(size: 20))
            }

            // Details
            VStack(alignment: .leading, spacing: 2) {
                Text(pledge.name)
                    .font(DesignSystem.Typography.body())
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                Text(pledge.dateRange)
                    .font(DesignSystem.Typography.caption(12))
                    .foregroundColor(DesignSystem.Colors.inkGray)
            }

            Spacer()

            // Outcome
            VStack(alignment: .trailing, spacing: 2) {
                if pledge.outcome == .fulfilled {
                    Text("+\(String(format: "$%.0f", pledge.earned))")
                        .font(DesignSystem.Typography.mono(16))
                        .foregroundColor(DesignSystem.Colors.moneyGreen)
                } else {
                    Text("-\(String(format: "$%.0f", pledge.stakeAmount))")
                        .font(DesignSystem.Typography.mono(16))
                        .foregroundColor(DesignSystem.Colors.alertRed)
                }

                Text(pledge.outcome.displayText)
                    .font(DesignSystem.Typography.label(10))
                    .foregroundColor(
                        pledge.outcome == .fulfilled
                            ? DesignSystem.Colors.moneyGreen
                            : DesignSystem.Colors.alertRed)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardWhite)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusCard))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusCard)
                .stroke(DesignSystem.Colors.inkBlack.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Empty History

/// Shown when there's no challenge history.
struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "flag.slash")
                .font(.system(size: 48))
                .foregroundColor(DesignSystem.Colors.lightGray)

            Text("No Pledges Yet")
                .font(DesignSystem.Typography.title(20))
                .foregroundColor(DesignSystem.Colors.inkBlack)

            Text(
                "Your completed challenges will appear here.\nCreate your first pledge to get started!"
            )
            .font(DesignSystem.Typography.caption())
            .foregroundColor(DesignSystem.Colors.inkGray)
            .multilineTextAlignment(.center)
            .padding(.horizontal, DesignSystem.Spacing.xl)
        }
    }
}

// MARK: - Past Pledge Model

/// Lightweight model for displaying past pledge history.
/// Not a @Model — this is a view-layer struct for display purposes.
struct PastPledge: Identifiable {
    let id = UUID()
    let name: String
    let modeIcon: String
    let dateRange: String
    let stakeAmount: Double
    let earned: Double
    let outcome: PledgeOutcome
    let participants: Int

    enum PledgeOutcome {
        case fulfilled
        case failed

        var displayText: String {
            switch self {
            case .fulfilled: return "FULFILLED"
            case .failed: return "FAILED"
            }
        }
    }
}

// MARK: - Mock Data

extension PastPledge {
    static let mockHistory: [PastPledge] = [
        PastPledge(
            name: "Step Showdown",
            modeIcon: "👟",
            dateRange: "Jan 27 – Feb 2",
            stakeAmount: 25.00,
            earned: 37.50,
            outcome: .fulfilled,
            participants: 6
        ),
        PastPledge(
            name: "Distance Derby",
            modeIcon: "🏃",
            dateRange: "Jan 20 – Jan 26",
            stakeAmount: 50.00,
            earned: 0,
            outcome: .failed,
            participants: 4
        ),
        PastPledge(
            name: "Active Zone",
            modeIcon: "⏱️",
            dateRange: "Jan 13 – Jan 19",
            stakeAmount: 25.00,
            earned: 43.75,
            outcome: .fulfilled,
            participants: 8
        ),
        PastPledge(
            name: "Step Showdown",
            modeIcon: "👟",
            dateRange: "Jan 6 – Jan 12",
            stakeAmount: 30.00,
            earned: 52.50,
            outcome: .fulfilled,
            participants: 5
        ),
        PastPledge(
            name: "Step Showdown",
            modeIcon: "👟",
            dateRange: "Dec 30 – Jan 5",
            stakeAmount: 25.00,
            earned: 25.00,
            outcome: .fulfilled,
            participants: 4
        ),
        PastPledge(
            name: "Active Zone",
            modeIcon: "⏱️",
            dateRange: "Dec 23 – Dec 29",
            stakeAmount: 40.00,
            earned: 0,
            outcome: .failed,
            participants: 6
        ),
        PastPledge(
            name: "Distance Derby",
            modeIcon: "🏃",
            dateRange: "Dec 16 – Dec 22",
            stakeAmount: 25.00,
            earned: 56.25,
            outcome: .fulfilled,
            participants: 10
        ),
    ]
}

// MARK: - Previews

#Preview("Challenge History") {
    NavigationStack {
        ChallengeHistoryView()
    }
}

#Preview("Challenge History - Empty") {
    NavigationStack {
        ChallengeHistoryView()
    }
}

#Preview("Past Pledge Row") {
    VStack {
        PastPledgeRow(pledge: PastPledge.mockHistory[0])
        PastPledgeRow(pledge: PastPledge.mockHistory[1])
    }
    .padding()
    .background(DesignSystem.Colors.background)
}
