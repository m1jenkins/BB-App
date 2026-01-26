//
//  DashboardView.swift
//  BetterBet
//
//  Main dashboard showing active pledges and progress.
//  Phase 2: "Clean Athletic" design with fitness-only focus.
//  Now integrated with PledgeManager for real data binding.
//
//  SEMANTIC FIREWALL NOTICE:
//  - "Pot" = pooled stakes, not gambling pot
//  - "FAILED" = did not fulfill commitment, not "lost"
//  - "Survivors" = those who fulfilled commitments, not "winners"
//

import SwiftUI

/// The main dashboard view showing active pledges and leaderboard.
struct DashboardView: View {
    @Environment(HealthManager.self) private var healthManager
    @State private var pledgeManager: PledgeManager?
    @State private var showCreatePledge = false
    @State private var showEliminationToast = true
    @State private var showStepDetail = false
    @State private var selectedPledge: Pledge?

    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.background
                .ignoresSafeArea()

            if let manager = pledgeManager {
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        // Active Pledge Card
                        if let featuredPledge = manager.featuredPledge {
                            ActivePledgeCard(
                                pledge: featuredPledge,
                                healthManager: healthManager,
                                onTap: {
                                    selectedPledge = featuredPledge
                                    showStepDetail = true
                                }
                            )
                        } else {
                            EmptyStateCard(onCreatePledge: { showCreatePledge = true })
                        }

                        // Leaderboard Section
                        if let featuredPledge = manager.featuredPledge {
                            LeaderboardCard(pledge: featuredPledge)
                        }

                        // Weekly Stats with tap for detail
                        WeeklyStatsCard(
                            healthManager: healthManager,
                            pledge: manager.featuredPledge,
                            onStatTap: { type in
                                showStepDetail = true
                            }
                        )

                        // Additional Active Pledges (if more than one)
                        if manager.activePledges.count > 1 {
                            OtherPledgesCard(
                                pledges: manager.activePledges.filter {
                                    $0.id != manager.featuredPledge?.id
                                },
                                healthManager: healthManager,
                                onPledgeTap: { pledge in
                                    selectedPledge = pledge
                                    showStepDetail = true
                                }
                            )
                        }

                        // Bottom padding for toast
                        Spacer()
                            .frame(height: 80)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.top, DesignSystem.Spacing.sm)
                }
                .refreshable {
                    await manager.syncAllPledges()
                }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }

            // Floating elimination toast
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

            // FAB for creating new pledge
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showCreatePledge = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(DesignSystem.Colors.inkBlack)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(
                                        DesignSystem.Colors.inkBlack,
                                        lineWidth: DesignSystem.Borders.thickness)
                            )
                            .elevatedShadow()
                    }
                    .padding(.trailing, DesignSystem.Spacing.md)
                    .padding(.bottom, showEliminationToast ? 100 : DesignSystem.Spacing.lg)
                }
            }
        }
        .sheet(isPresented: $showCreatePledge) {
            CreatePledgeView()
        }
        .navigationDestination(isPresented: $showStepDetail) {
            if let pledge = selectedPledge ?? pledgeManager?.featuredPledge,
                let manager = pledgeManager
            {
                StepTrackingView(
                    pledge: pledge,
                    healthManager: healthManager,
                    pledgeManager: manager
                )
            }
        }
        .task {
            // Initialize pledge manager with health manager
            if pledgeManager == nil {
                let manager = PledgeManager(healthManager: healthManager)
                manager.loadMockData()  // Load mock data for development
                pledgeManager = manager
            }

            // Sync pledges with health data
            await healthManager.fetchAllMetrics()
            await pledgeManager?.syncAllPledges()
        }
    }
}

// MARK: - Active Pledge Card

struct ActivePledgeCard: View {
    let pledge: Pledge
    let healthManager: HealthManager
    var onTap: (() -> Void)? = nil

    private var progress: Double {
        switch pledge.type {
        case .steps:
            return Double(healthManager.weeklySteps) / pledge.targetValue
        case .distance:
            return healthManager.weeklyDistance / pledge.targetValue
        case .activeMinutes:
            return healthManager.weeklyActiveEnergy / pledge.targetValue
        }
    }

    private var currentValue: String {
        switch pledge.type {
        case .steps:
            return healthManager.weeklySteps.formatted()
        case .distance:
            return String(format: "%.1f", healthManager.weeklyDistance)
        case .activeMinutes:
            return Int(healthManager.weeklyActiveEnergy).formatted()
        }
    }

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(spacing: DesignSystem.Spacing.md) {
                // Header row
                HStack {
                    // Challenge type icon and title
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        ZStack {
                            Circle()
                                .fill(DesignSystem.Colors.background)
                                .frame(width: 40, height: 40)

                            Image(systemName: pledge.type.icon)
                                .font(.system(size: 18))
                                .foregroundColor(DesignSystem.Colors.inkBlack)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(pledge.title)
                                .font(DesignSystem.Typography.title(18))
                                .foregroundColor(DesignSystem.Colors.inkBlack)

                            Text(pledge.timeRemaining)
                                .font(DesignSystem.Typography.caption())
                                .foregroundColor(DesignSystem.Colors.inkGray)
                        }
                    }

                    Spacer()

                    // Pot badge
                    PotBadge(amount: pledge.potValue, size: 64)
                }

                // Progress section
                VStack(spacing: DesignSystem.Spacing.xs) {
                    // Current progress display
                    HStack(alignment: .firstTextBaseline, spacing: DesignSystem.Spacing.xxs) {
                        Text(currentValue)
                            .font(DesignSystem.Typography.data(36))
                            .foregroundColor(DesignSystem.Colors.inkBlack)

                        Text(
                            "/ \(pledge.type.formatValue(pledge.targetValue)) \(pledge.type.unitLabel)"
                        )
                        .font(DesignSystem.Typography.body())
                        .foregroundColor(DesignSystem.Colors.inkGray)
                    }

                    // Progress bar
                    ProgressBar(
                        progress: min(progress, 1.0),
                        fillColor: progressColor,
                        height: 16
                    )

                    // Status row
                    HStack {
                        StatusBadge(status: pledge.challengeStatus, size: .small)

                        Spacer()

                        HStack(spacing: 4) {
                            Text("\(Int(progress * 100))% complete")
                                .font(DesignSystem.Typography.caption())
                                .foregroundColor(DesignSystem.Colors.inkGray)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(DesignSystem.Colors.inkGray)
                        }
                    }
                }
            }
            .padding(DesignSystem.Spacing.md)
            .cleanCard()
        }
        .buttonStyle(.plain)
    }

    private var progressColor: Color {
        if progress >= 1.0 {
            return DesignSystem.Colors.moneyGreen
        } else if progress >= 0.7 {
            return DesignSystem.Colors.mustard
        } else {
            return DesignSystem.Colors.alertRed
        }
    }
}

// MARK: - Empty State Card

struct EmptyStateCard: View {
    let onCreatePledge: () -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "figure.run")
                .font(.system(size: 48))
                .foregroundColor(DesignSystem.Colors.inkGray)

            Text("No Active Pledge")
                .font(DesignSystem.Typography.title())
                .foregroundColor(DesignSystem.Colors.inkBlack)

            // SEMANTIC FIREWALL: "commitment" not "bet"
            Text("Start a fitness commitment to hold yourself accountable")
                .font(DesignSystem.Typography.body())
                .foregroundColor(DesignSystem.Colors.inkGray)
                .multilineTextAlignment(.center)

            Button("Create Pledge") {
                onCreatePledge()
            }
            .buttonStyle(.primary)
            .padding(.top, DesignSystem.Spacing.xs)
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(maxWidth: .infinity)
        .cleanCard()
    }
}

// MARK: - Leaderboard Card

struct LeaderboardCard: View {
    let pledge: Pledge

    // Mock participants
    private let participants: [LeaderboardEntry] = [
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

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Header
            HStack {
                Text("Leaderboard")
                    .font(DesignSystem.Typography.title(18))
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                Spacer()

                // SEMANTIC FIREWALL: "survivors" not "winners"
                let survivorCount = participants.filter { !$0.hasFailed }.count
                Text("\(survivorCount) survivors")
                    .font(DesignSystem.Typography.caption())
                    .foregroundColor(DesignSystem.Colors.moneyGreen)
            }

            // Participant rows
            VStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(participants.sorted { $0.progress > $1.progress }) { entry in
                    LeaderboardRow(entry: entry)
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cleanCard()
    }
}

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let name: String
    let avatar: String
    let progress: Double
    let isCurrentUser: Bool
    let hasFailed: Bool
}

struct LeaderboardRow: View {
    let entry: LeaderboardEntry

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        entry.hasFailed
                            ? DesignSystem.Colors.alertRed.opacity(0.1)
                            : DesignSystem.Colors.background
                    )
                    .frame(width: 40, height: 40)

                Text(entry.avatar)
                    .font(.system(size: 20))

                if entry.hasFailed {
                    Circle()
                        .fill(DesignSystem.Colors.alertRed.opacity(0.5))
                        .frame(width: 40, height: 40)

                    Text("💀")
                        .font(.system(size: 18))
                }
            }

            // Name
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(entry.name)
                        .font(DesignSystem.Typography.body())
                        .fontWeight(.medium)
                        .foregroundColor(
                            entry.hasFailed
                                ? DesignSystem.Colors.inkGray : DesignSystem.Colors.inkBlack
                        )
                        .strikethrough(entry.hasFailed)

                    if entry.isCurrentUser {
                        Text("(You)")
                            .font(DesignSystem.Typography.caption())
                            .foregroundColor(DesignSystem.Colors.inkGray)
                    }
                }
            }

            Spacer()

            // Progress or Failed
            if entry.hasFailed {
                // SEMANTIC FIREWALL: "FAILED" commitment
                Text("FAILED")
                    .font(DesignSystem.Typography.label(11))
                    .foregroundColor(DesignSystem.Colors.alertRed)
                    .padding(.horizontal, DesignSystem.Spacing.xs)
                    .padding(.vertical, 4)
                    .background(DesignSystem.Colors.alertRed.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                Text("\(Int(entry.progress * 100))%")
                    .font(DesignSystem.Typography.mono(14))
                    .fontWeight(.semibold)
                    .foregroundColor(
                        entry.progress >= 1.0
                            ? DesignSystem.Colors.moneyGreen : DesignSystem.Colors.inkBlack)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
}

// MARK: - Weekly Stats Card

struct WeeklyStatsCard: View {
    let healthManager: HealthManager
    let pledge: Pledge?
    var onStatTap: ((ChallengeType) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("This Week")
                .font(DesignSystem.Typography.title(18))
                .foregroundColor(DesignSystem.Colors.inkBlack)

            // Stats grid
            HStack(spacing: DesignSystem.Spacing.sm) {
                StatBox(
                    icon: "figure.walk",
                    value: healthManager.weeklySteps.formatted(),
                    label: "Steps",
                    isHighlighted: pledge?.type == .steps,
                    onTap: { onStatTap?(.steps) }
                )

                StatBox(
                    icon: "map",
                    value: String(format: "%.1f", healthManager.weeklyDistance),
                    label: "Miles",
                    isHighlighted: pledge?.type == .distance,
                    onTap: { onStatTap?(.distance) }
                )

                StatBox(
                    icon: "timer",
                    value: Int(healthManager.weeklyActiveEnergy).formatted(),
                    label: "Active Min",
                    isHighlighted: pledge?.type == .activeMinutes,
                    onTap: { onStatTap?(.activeMinutes) }
                )
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cleanCard()
    }
}

struct StatBox: View {
    let icon: String
    let value: String
    let label: String
    var isHighlighted: Bool = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(
                        isHighlighted ? DesignSystem.Colors.moneyGreen : DesignSystem.Colors.inkGray
                    )

                Text(value)
                    .font(DesignSystem.Typography.data(20))
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                Text(label)
                    .font(DesignSystem.Typography.caption(12))
                    .foregroundColor(DesignSystem.Colors.inkGray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                isHighlighted
                    ? DesignSystem.Colors.moneyGreen.opacity(0.08) : DesignSystem.Colors.background
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusSmall))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Other Pledges Card

struct OtherPledgesCard: View {
    let pledges: [Pledge]
    let healthManager: HealthManager
    let onPledgeTap: (Pledge) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Other Active Pledges")
                .font(DesignSystem.Typography.title(18))
                .foregroundColor(DesignSystem.Colors.inkBlack)

            ForEach(pledges, id: \.id) { pledge in
                Button {
                    onPledgeTap(pledge)
                } label: {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(DesignSystem.Colors.background)
                                .frame(width: 40, height: 40)

                            Image(systemName: pledge.type.icon)
                                .font(.system(size: 16))
                                .foregroundColor(DesignSystem.Colors.inkBlack)
                        }

                        // Info
                        VStack(alignment: .leading, spacing: 2) {
                            Text(pledge.title)
                                .font(DesignSystem.Typography.body())
                                .fontWeight(.medium)
                                .foregroundColor(DesignSystem.Colors.inkBlack)

                            Text(
                                "\(pledge.type.formatValue(pledge.currentProgress)) / \(pledge.type.formatValue(pledge.targetValue))"
                            )
                            .font(DesignSystem.Typography.caption())
                            .foregroundColor(DesignSystem.Colors.inkGray)
                        }

                        Spacer()

                        // Progress percentage
                        Text("\(Int(pledge.progressPercentage * 100))%")
                            .font(DesignSystem.Typography.mono(14))
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.inkBlack)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(DesignSystem.Colors.inkGray)
                    }
                    .padding(DesignSystem.Spacing.sm)
                    .background(DesignSystem.Colors.background)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusSmall))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cleanCard()
    }
}

// MARK: - Elimination Toast

struct EliminationToast: View {
    let playerName: String
    let addedAmount: Double
    var onDismiss: () -> Void

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Skull emoji
            Text("💀")
                .font(.system(size: 24))

            VStack(alignment: .leading, spacing: 2) {
                // SEMANTIC FIREWALL: "is Out" = failed commitment
                Text("\(playerName) is Out")
                    .font(DesignSystem.Typography.body())
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                // SEMANTIC FIREWALL: "added to pot" = stake redistribution
                HStack(spacing: 4) {
                    Text("+$\(String(format: "%.2f", addedAmount))")
                        .font(DesignSystem.Typography.mono(14))
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.moneyGreen)

                    Text("added to pot")
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
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.inkGray)
                    .padding(DesignSystem.Spacing.xs)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardWhite)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusCard))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusCard)
                .stroke(
                    DesignSystem.Colors.alertRed.opacity(0.3),
                    lineWidth: DesignSystem.Borders.thickness)
        )
        .elevatedShadow()
    }
}

// MARK: - Previews

#Preview("Dashboard") {
    NavigationStack {
        DashboardView()
            .environment(HealthManager.preview)
            .navigationTitle("Better Bet")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Active Pledge Card") {
    ActivePledgeCard(
        pledge: Pledge.mockStepChallenge,
        healthManager: HealthManager.preview
    )
    .padding()
    .background(DesignSystem.Colors.background)
}

#Preview("Leaderboard Card") {
    LeaderboardCard(pledge: Pledge.mockStepChallenge)
        .padding()
        .background(DesignSystem.Colors.background)
}

#Preview("Elimination Toast") {
    EliminationToast(playerName: "Dave", addedAmount: 12.50, onDismiss: {})
        .padding()
        .background(DesignSystem.Colors.background)
}
