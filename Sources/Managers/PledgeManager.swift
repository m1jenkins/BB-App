//
//  PledgeManager.swift
//  BetterBet
//
//  Manages pledge lifecycle and synchronizes progress with HealthKit data.
//  This is the bridge between user pledges and health metrics.
//
//  SEMANTIC FIREWALL NOTICE:
//  - Pledges are "fulfilled" or "failed", not "won" or "lost"
//  - Progress is "commitment progress", not "betting odds"
//  - Stakes are "accountability deposits", not "wagers"
//

import Foundation
import SwiftData
import Observation

/// Manages pledge lifecycle, progress tracking, and HealthKit synchronization.
@MainActor
@Observable
final class PledgeManager {

    // MARK: - Properties

    /// Reference to HealthManager for data fetching
    private var healthManager: HealthManager

    /// Current active pledges
    var activePledges: [Pledge] = []

    /// Completed pledges (for history)
    var completedPledges: [Pledge] = []

    /// The primary/featured active pledge (shown on dashboard)
    var featuredPledge: Pledge?

    /// Whether the manager is currently syncing
    var isSyncing: Bool = false

    /// Last sync timestamp
    var lastSyncTime: Date?

    /// Auto-refresh timer interval (in seconds)
    private let refreshInterval: TimeInterval = 300 // 5 minutes

    // MARK: - Computed Properties

    /// Total stakes at risk across all active pledges
    var totalStakesAtRisk: Double {
        activePledges.reduce(0) { $0 + $1.stakeAmount }
    }

    /// Total pot value across all active pledges
    var totalPotValue: Double {
        activePledges.reduce(0) { $0 + $1.potValue }
    }

    /// Number of pledges currently at risk
    var pledgesAtRisk: Int {
        activePledges.filter { $0.challengeStatus == .atRisk }.count
    }

    /// Number of pledges on track
    var pledgesOnTrack: Int {
        activePledges.filter { $0.challengeStatus == .onTrack || $0.challengeStatus == .completed }.count
    }

    // MARK: - Initialization

    init(healthManager: HealthManager) {
        self.healthManager = healthManager
    }

    // MARK: - Pledge Management

    /// Create a new pledge
    func createPledge(
        title: String,
        type: ChallengeType,
        targetValue: Double,
        stakeAmount: Double,
        duration: PledgeDuration = .oneWeek
    ) -> Pledge {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let endDate: Date

        switch duration {
        case .oneDay:
            endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!.addingTimeInterval(-1)
        case .threeDays:
            endDate = calendar.date(byAdding: .day, value: 3, to: startDate)!.addingTimeInterval(-1)
        case .oneWeek:
            endDate = calendar.date(byAdding: .day, value: 7, to: startDate)!.addingTimeInterval(-1)
        case .twoWeeks:
            endDate = calendar.date(byAdding: .day, value: 14, to: startDate)!.addingTimeInterval(-1)
        case .oneMonth:
            endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!.addingTimeInterval(-1)
        }

        let pledge = Pledge(
            title: title,
            type: type,
            targetValue: targetValue,
            stakeAmount: stakeAmount,
            startDate: startDate,
            endDate: endDate,
            status: .active,
            isCurrentUser: true,
            creatorID: "current_user" // Would be actual user ID
        )

        activePledges.append(pledge)

        // Set as featured if it's the first or only pledge
        if featuredPledge == nil {
            featuredPledge = pledge
        }

        return pledge
    }

    /// Add an existing pledge (e.g., from SwiftData or joining a friend's pledge)
    func addPledge(_ pledge: Pledge) {
        if pledge.status == .active {
            activePledges.append(pledge)
            if featuredPledge == nil {
                featuredPledge = pledge
            }
        } else {
            completedPledges.append(pledge)
        }
    }

    /// Remove/cancel a pledge
    func cancelPledge(_ pledge: Pledge) {
        pledge.status = .cancelled
        activePledges.removeAll { $0.id == pledge.id }
        completedPledges.append(pledge)

        if featuredPledge?.id == pledge.id {
            featuredPledge = activePledges.first
        }
    }

    /// Set the featured pledge (shown prominently on dashboard)
    func setFeaturedPledge(_ pledge: Pledge) {
        guard activePledges.contains(where: { $0.id == pledge.id }) else { return }
        featuredPledge = pledge
    }

    // MARK: - Progress Synchronization

    /// Sync all pledges with current HealthKit data
    func syncAllPledges() async {
        isSyncing = true
        defer {
            isSyncing = false
            lastSyncTime = Date()
        }

        // Fetch all health metrics
        await healthManager.fetchAllMetrics()

        // Update each active pledge with current progress
        for pledge in activePledges {
            await updatePledgeProgress(pledge)
        }

        // Check for any pledges that need status updates
        checkPledgeStatuses()
    }

    /// Sync a single pledge with current health data
    func syncPledge(_ pledge: Pledge) async {
        isSyncing = true
        defer { isSyncing = false }

        // Fetch relevant health data
        _ = await healthManager.fetchProgress(for: pledge.type)

        // Update the pledge progress
        await updatePledgeProgress(pledge)

        // Check status
        checkPledgeStatus(pledge)
    }

    /// Update a pledge's progress based on HealthKit data
    private func updatePledgeProgress(_ pledge: Pledge) async {
        let currentProgress: Double

        switch pledge.type {
        case .steps:
            // For multi-day pledges, use weekly totals
            // For daily pledges, use today's steps
            if pledge.daysRemaining <= 1 && isDailyPledge(pledge) {
                currentProgress = Double(healthManager.todaySteps)
            } else {
                currentProgress = Double(healthManager.weeklySteps)
            }

        case .distance:
            if pledge.daysRemaining <= 1 && isDailyPledge(pledge) {
                currentProgress = healthManager.todayDistance
            } else {
                currentProgress = healthManager.weeklyDistance
            }

        case .activeEnergy:
            if pledge.daysRemaining <= 1 && isDailyPledge(pledge) {
                currentProgress = healthManager.todayActiveEnergy
            } else {
                currentProgress = healthManager.weeklyActiveEnergy
            }
        }

        pledge.currentProgress = currentProgress
    }

    /// Check if a pledge is a daily pledge (1 day duration)
    private func isDailyPledge(_ pledge: Pledge) -> Bool {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: pledge.startDate, to: pledge.endDate).day ?? 0
        return days <= 1
    }

    /// Check and update statuses for all active pledges
    private func checkPledgeStatuses() {
        for pledge in activePledges {
            checkPledgeStatus(pledge)
        }

        // Move completed/failed pledges to history
        let endedPledges = activePledges.filter { $0.status == .completed || $0.status == .failed }
        for pledge in endedPledges {
            activePledges.removeAll { $0.id == pledge.id }
            completedPledges.append(pledge)
        }

        // Update featured pledge if needed
        if let featured = featuredPledge, !activePledges.contains(where: { $0.id == featured.id }) {
            featuredPledge = activePledges.first
        }
    }

    /// Check and update status for a single pledge
    private func checkPledgeStatus(_ pledge: Pledge) {
        guard pledge.status == .active else { return }

        // Check if deadline has passed
        if pledge.hasEnded {
            // SEMANTIC FIREWALL: "fulfilled" not "won", "failed" not "lost"
            if pledge.progressPercentage >= 1.0 {
                pledge.status = .completed
            } else {
                pledge.status = .failed
            }
        }
    }

    // MARK: - Progress Calculations

    /// Get the daily target for a pledge based on remaining time
    func getDailyTarget(for pledge: Pledge) -> Double {
        guard pledge.daysRemaining > 0 else { return pledge.targetValue - pledge.currentProgress }

        let remaining = pledge.targetValue - pledge.currentProgress
        return max(0, remaining / Double(pledge.daysRemaining))
    }

    /// Get pace indicator - how far ahead/behind the user is
    func getPaceIndicator(for pledge: Pledge) -> PaceStatus {
        let expectedProgress = getExpectedProgress(for: pledge)
        let actualProgress = pledge.progressPercentage
        let difference = actualProgress - expectedProgress

        if difference >= 0.1 {
            return .aheadOfPace(by: difference)
        } else if difference >= -0.1 {
            return .onPace
        } else {
            return .behindPace(by: abs(difference))
        }
    }

    /// Calculate expected progress based on elapsed time
    func getExpectedProgress(for pledge: Pledge) -> Double {
        let calendar = Calendar.current
        let totalDuration = calendar.dateComponents([.second], from: pledge.startDate, to: pledge.endDate).second ?? 1
        let elapsed = calendar.dateComponents([.second], from: pledge.startDate, to: Date()).second ?? 0

        guard totalDuration > 0 else { return 1.0 }
        return Double(elapsed) / Double(totalDuration)
    }

    /// Get daily breakdown of progress for a pledge
    func getDailyBreakdown(for pledge: Pledge) -> [DailyProgress] {
        switch pledge.type {
        case .steps:
            return healthManager.dailySteps.map { data in
                DailyProgress(
                    date: data.date,
                    value: data.value,
                    target: pledge.targetValue / 7, // Daily target for weekly pledge
                    type: pledge.type
                )
            }
        case .distance:
            return healthManager.dailyDistance.map { data in
                DailyProgress(
                    date: data.date,
                    value: data.value,
                    target: pledge.targetValue / 7,
                    type: pledge.type
                )
            }
        case .activeEnergy:
            return healthManager.dailyActiveEnergy.map { data in
                DailyProgress(
                    date: data.date,
                    value: data.value,
                    target: pledge.targetValue / 7,
                    type: pledge.type
                )
            }
        }
    }

    // MARK: - Mock Data (for development)

    /// Load mock pledges for testing
    func loadMockData() {
        activePledges = [
            Pledge.mockStepChallenge,
            Pledge.mockDistanceChallenge
        ]
        completedPledges = []
        featuredPledge = activePledges.first
    }
}

// MARK: - Supporting Types

/// Duration options for pledges
enum PledgeDuration: String, CaseIterable, Identifiable {
    case oneDay = "1 Day"
    case threeDays = "3 Days"
    case oneWeek = "1 Week"
    case twoWeeks = "2 Weeks"
    case oneMonth = "1 Month"

    var id: String { rawValue }

    var days: Int {
        switch self {
        case .oneDay: return 1
        case .threeDays: return 3
        case .oneWeek: return 7
        case .twoWeeks: return 14
        case .oneMonth: return 30
        }
    }
}

/// Pace status for pledge progress
enum PaceStatus {
    case aheadOfPace(by: Double)
    case onPace
    case behindPace(by: Double)

    var displayText: String {
        switch self {
        case .aheadOfPace(let amount):
            return "+\(Int(amount * 100))% ahead"
        case .onPace:
            return "On pace"
        case .behindPace(let amount):
            return "\(Int(amount * 100))% behind"
        }
    }

    var color: String {
        switch self {
        case .aheadOfPace: return "moneyGreen"
        case .onPace: return "inkBlack"
        case .behindPace: return "alertRed"
        }
    }
}

// Note: ChallengeStatus is defined in DesignSystem.swift

/// Daily progress data point
struct DailyProgress: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let target: Double
    let type: ChallengeType

    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var progressPercentage: Double {
        guard target > 0 else { return 0 }
        return min(value / target, 1.5) // Cap at 150% for display
    }

    var metTarget: Bool {
        value >= target
    }

    var formattedValue: String {
        type.formatValue(value)
    }
}

// MARK: - Preview Helper

extension PledgeManager {
    /// Create a preview instance with mock data
    static var preview: PledgeManager {
        let healthManager = HealthManager.preview
        let manager = PledgeManager(healthManager: healthManager)
        manager.loadMockData()
        return manager
    }
}
