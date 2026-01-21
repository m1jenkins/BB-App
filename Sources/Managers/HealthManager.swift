//
//  HealthManager.swift
//  BetterBet
//
//  The "Oracle" - Manages all HealthKit integrations
//  Phase 2: Supports Steps, Distance, and Active Energy metrics.
//
//  SEMANTIC FIREWALL NOTICE:
//  This manager is the source of truth for challenge verification.
//  It does NOT determine "winners" or "losers" - it determines
//  "Commitment Fulfilled" vs "Commitment Failed" status.
//

import Foundation
import HealthKit
import Observation

/// The Oracle: Single source of truth for health data in Better Bet.
/// Manages HealthKit authorization and data fetching for challenge verification.
@MainActor
@Observable
final class HealthManager {

    // MARK: - Properties

    /// The HealthKit store instance
    private let healthStore: HKHealthStore?

    /// Whether HealthKit is available on this device
    var isHealthKitAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    /// Current authorization status
    var authorizationStatus: AuthorizationStatus = .notDetermined

    // MARK: - Step Data

    /// Weekly step count
    var weeklySteps: Int = 0

    /// Daily step breakdown for the current week
    var dailySteps: [DailyMetricData] = []

    /// Today's step count
    var todaySteps: Int = 0

    // MARK: - Distance Data

    /// Weekly distance in miles
    var weeklyDistance: Double = 0

    /// Daily distance breakdown
    var dailyDistance: [DailyMetricData] = []

    /// Today's distance in miles
    var todayDistance: Double = 0

    // MARK: - Active Energy Data

    /// Weekly active energy in kcal
    var weeklyActiveEnergy: Double = 0

    /// Daily active energy breakdown
    var dailyActiveEnergy: [DailyMetricData] = []

    /// Today's active energy in kcal
    var todayActiveEnergy: Double = 0

    // MARK: - State

    /// Loading state
    var isLoading: Bool = false

    /// Error message if something goes wrong
    var errorMessage: String?

    // MARK: - Types

    enum AuthorizationStatus {
        case notDetermined
        case authorized
        case denied
        case unavailable
    }

    struct DailyMetricData: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double

        var dayName: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            return formatter.string(from: date)
        }

        var isToday: Bool {
            Calendar.current.isDateInToday(date)
        }
    }

    // MARK: - Initialization

    init() {
        if HKHealthStore.isHealthDataAvailable() {
            self.healthStore = HKHealthStore()
        } else {
            self.healthStore = nil
            self.authorizationStatus = .unavailable
        }
    }

    // MARK: - Authorization

    /// Request authorization for all supported metrics (read-only)
    func requestAuthorization() async {
        guard let healthStore = healthStore else {
            authorizationStatus = .unavailable
            errorMessage = "HealthKit is not available on this device"
            return
        }

        // Define the types we want to read
        // SEMANTIC FIREWALL: We only READ data - we never modify health records
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType(.stepCount),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.activeEnergyBurned),
            HKObjectType.workoutType()
        ]

        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)

            // Check the authorization status for steps (primary metric)
            let stepType = HKQuantityType(.stepCount)
            let status = healthStore.authorizationStatus(for: stepType)

            switch status {
            case .sharingAuthorized:
                authorizationStatus = .authorized
            case .sharingDenied:
                authorizationStatus = .denied
                errorMessage = "Health data access was denied. Please enable in Settings."
            case .notDetermined:
                authorizationStatus = .notDetermined
            @unknown default:
                authorizationStatus = .notDetermined
            }
        } catch {
            authorizationStatus = .denied
            errorMessage = "Failed to request authorization: \(error.localizedDescription)"
        }
    }

    // MARK: - Fetch All Data

    /// Fetch all metrics for the current week
    func fetchAllMetrics() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchWeeklySteps() }
            group.addTask { await self.fetchWeeklyDistance() }
            group.addTask { await self.fetchWeeklyActiveEnergy() }
        }
    }

    // MARK: - Fetch Progress for Challenge Type

    /// Fetch current progress for a specific challenge type
    func fetchProgress(for type: ChallengeType) async -> Double {
        switch type {
        case .steps:
            await fetchWeeklySteps()
            return Double(weeklySteps)
        case .distance:
            await fetchWeeklyDistance()
            return weeklyDistance
        case .activeEnergy:
            await fetchWeeklyActiveEnergy()
            return weeklyActiveEnergy
        }
    }

    // MARK: - Step Data Fetching

    /// Fetch weekly step count for challenge verification
    func fetchWeeklySteps() async {
        #if targetEnvironment(simulator)
        await loadDummyStepData()
        #else
        await loadRealStepData()
        #endif
    }

    private func loadDummyStepData() async {
        isLoading = true
        defer { isLoading = false }

        try? await Task.sleep(nanoseconds: 300_000_000)

        let calendar = Calendar.current
        let today = Date()
        var startOfWeek = today
        while calendar.component(.weekday, from: startOfWeek) != 2 {
            startOfWeek = calendar.date(byAdding: .day, value: -1, to: startOfWeek)!
        }
        startOfWeek = calendar.startOfDay(for: startOfWeek)

        var totalSteps = 0
        var dailyData: [DailyMetricData] = []

        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) else { continue }

            let steps: Int
            if date <= today {
                steps = Int.random(in: 6000...14000)
            } else {
                steps = 0
            }

            dailyData.append(DailyMetricData(date: date, value: Double(steps)))
            totalSteps += steps
        }

        self.dailySteps = dailyData
        self.weeklySteps = totalSteps
        self.todaySteps = Int(dailyData.first(where: { $0.isToday })?.value ?? 8432)
    }

    private func loadRealStepData() async {
        guard let healthStore = healthStore, authorizationStatus == .authorized else { return }

        isLoading = true
        defer { isLoading = false }

        let stepType = HKQuantityType(.stepCount)
        let (startOfWeek, endOfWeek) = getWeekDateRange()

        await fetchStatistics(
            for: stepType,
            unit: .count(),
            from: startOfWeek,
            to: endOfWeek
        ) { dailyData, total in
            self.dailySteps = dailyData
            self.weeklySteps = Int(total)
            self.todaySteps = Int(dailyData.first(where: { $0.isToday })?.value ?? 0)
        }
    }

    // MARK: - Distance Data Fetching

    /// Fetch weekly distance (in miles)
    func fetchWeeklyDistance() async {
        #if targetEnvironment(simulator)
        await loadDummyDistanceData()
        #else
        await loadRealDistanceData()
        #endif
    }

    private func loadDummyDistanceData() async {
        isLoading = true
        defer { isLoading = false }

        try? await Task.sleep(nanoseconds: 200_000_000)

        let calendar = Calendar.current
        let today = Date()
        var startOfWeek = today
        while calendar.component(.weekday, from: startOfWeek) != 2 {
            startOfWeek = calendar.date(byAdding: .day, value: -1, to: startOfWeek)!
        }
        startOfWeek = calendar.startOfDay(for: startOfWeek)

        var totalDistance: Double = 0
        var dailyData: [DailyMetricData] = []

        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) else { continue }

            let distance: Double
            if date <= today {
                distance = Double.random(in: 1.5...4.5)
            } else {
                distance = 0
            }

            dailyData.append(DailyMetricData(date: date, value: distance))
            totalDistance += distance
        }

        self.dailyDistance = dailyData
        self.weeklyDistance = totalDistance
        self.todayDistance = dailyData.first(where: { $0.isToday })?.value ?? 2.3
    }

    private func loadRealDistanceData() async {
        guard let healthStore = healthStore, authorizationStatus == .authorized else { return }

        isLoading = true
        defer { isLoading = false }

        let distanceType = HKQuantityType(.distanceWalkingRunning)
        let (startOfWeek, endOfWeek) = getWeekDateRange()

        // Fetch in meters, convert to miles
        await fetchStatistics(
            for: distanceType,
            unit: .mile(),
            from: startOfWeek,
            to: endOfWeek
        ) { dailyData, total in
            self.dailyDistance = dailyData
            self.weeklyDistance = total
            self.todayDistance = dailyData.first(where: { $0.isToday })?.value ?? 0
        }
    }

    // MARK: - Active Energy Data Fetching

    /// Fetch weekly active energy (in kcal)
    func fetchWeeklyActiveEnergy() async {
        #if targetEnvironment(simulator)
        await loadDummyActiveEnergyData()
        #else
        await loadRealActiveEnergyData()
        #endif
    }

    private func loadDummyActiveEnergyData() async {
        isLoading = true
        defer { isLoading = false }

        try? await Task.sleep(nanoseconds: 200_000_000)

        let calendar = Calendar.current
        let today = Date()
        var startOfWeek = today
        while calendar.component(.weekday, from: startOfWeek) != 2 {
            startOfWeek = calendar.date(byAdding: .day, value: -1, to: startOfWeek)!
        }
        startOfWeek = calendar.startOfDay(for: startOfWeek)

        var totalEnergy: Double = 0
        var dailyData: [DailyMetricData] = []

        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) else { continue }

            let energy: Double
            if date <= today {
                energy = Double.random(in: 300...700)
            } else {
                energy = 0
            }

            dailyData.append(DailyMetricData(date: date, value: energy))
            totalEnergy += energy
        }

        self.dailyActiveEnergy = dailyData
        self.weeklyActiveEnergy = totalEnergy
        self.todayActiveEnergy = dailyData.first(where: { $0.isToday })?.value ?? 450
    }

    private func loadRealActiveEnergyData() async {
        guard let healthStore = healthStore, authorizationStatus == .authorized else { return }

        isLoading = true
        defer { isLoading = false }

        let energyType = HKQuantityType(.activeEnergyBurned)
        let (startOfWeek, endOfWeek) = getWeekDateRange()

        await fetchStatistics(
            for: energyType,
            unit: .kilocalorie(),
            from: startOfWeek,
            to: endOfWeek
        ) { dailyData, total in
            self.dailyActiveEnergy = dailyData
            self.weeklyActiveEnergy = total
            self.todayActiveEnergy = dailyData.first(where: { $0.isToday })?.value ?? 0
        }
    }

    // MARK: - Helper Methods

    private func getWeekDateRange() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let today = Date()
        var startOfWeek = today
        while calendar.component(.weekday, from: startOfWeek) != 2 { // Monday
            startOfWeek = calendar.date(byAdding: .day, value: -1, to: startOfWeek)!
        }
        startOfWeek = calendar.startOfDay(for: startOfWeek)
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
        return (startOfWeek, endOfWeek)
    }

    private func fetchStatistics(
        for quantityType: HKQuantityType,
        unit: HKUnit,
        from startDate: Date,
        to endDate: Date,
        completion: @escaping ([DailyMetricData], Double) -> Void
    ) async {
        guard let healthStore = healthStore else { return }

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startDate,
            intervalComponents: DateComponents(day: 1)
        )

        query.initialResultsHandler = { _, results, error in
            Task { @MainActor in
                guard let results = results, error == nil else {
                    self.errorMessage = "Failed to fetch data: \(error?.localizedDescription ?? "Unknown error")"
                    return
                }

                var total: Double = 0
                var dailyData: [DailyMetricData] = []

                results.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                    let value = statistics.sumQuantity()?.doubleValue(for: unit) ?? 0
                    dailyData.append(DailyMetricData(date: statistics.startDate, value: value))
                    total += value
                }

                completion(dailyData, total)
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Challenge Verification

    /// Verify if a user has met their commitment for any challenge type
    /// SEMANTIC FIREWALL: Returns "fulfilled" or "failed", not "won" or "lost"
    func verifyCommitment(type: ChallengeType, target: Double, current: Double) -> CommitmentResult {
        if current >= target {
            return .fulfilled(current: current, target: target)
        } else {
            return .failed(current: current, target: target, shortfall: target - current)
        }
    }

    enum CommitmentResult {
        case fulfilled(current: Double, target: Double)
        case failed(current: Double, target: Double, shortfall: Double)

        var isFulfilled: Bool {
            if case .fulfilled = self { return true }
            return false
        }

        var progress: Double {
            switch self {
            case .fulfilled(let current, let target):
                return current / target
            case .failed(let current, let target, _):
                return current / target
            }
        }
    }
}

// MARK: - Preview Helper

extension HealthManager {
    /// Create a preview instance with mock data
    static var preview: HealthManager {
        let manager = HealthManager()
        manager.authorizationStatus = .authorized

        // Steps
        manager.weeklySteps = 52847
        manager.todaySteps = 8432
        manager.dailySteps = [
            DailyMetricData(date: Date().addingTimeInterval(-6 * 86400), value: 7823),
            DailyMetricData(date: Date().addingTimeInterval(-5 * 86400), value: 9245),
            DailyMetricData(date: Date().addingTimeInterval(-4 * 86400), value: 6891),
            DailyMetricData(date: Date().addingTimeInterval(-3 * 86400), value: 11234),
            DailyMetricData(date: Date().addingTimeInterval(-2 * 86400), value: 8567),
            DailyMetricData(date: Date().addingTimeInterval(-1 * 86400), value: 10655),
            DailyMetricData(date: Date(), value: 8432)
        ]

        // Distance
        manager.weeklyDistance = 18.3
        manager.todayDistance = 2.8
        manager.dailyDistance = [
            DailyMetricData(date: Date().addingTimeInterval(-6 * 86400), value: 2.1),
            DailyMetricData(date: Date().addingTimeInterval(-5 * 86400), value: 3.2),
            DailyMetricData(date: Date().addingTimeInterval(-4 * 86400), value: 1.8),
            DailyMetricData(date: Date().addingTimeInterval(-3 * 86400), value: 4.1),
            DailyMetricData(date: Date().addingTimeInterval(-2 * 86400), value: 2.5),
            DailyMetricData(date: Date().addingTimeInterval(-1 * 86400), value: 3.8),
            DailyMetricData(date: Date(), value: 2.8)
        ]

        // Active Energy
        manager.weeklyActiveEnergy = 3150
        manager.todayActiveEnergy = 480
        manager.dailyActiveEnergy = [
            DailyMetricData(date: Date().addingTimeInterval(-6 * 86400), value: 420),
            DailyMetricData(date: Date().addingTimeInterval(-5 * 86400), value: 510),
            DailyMetricData(date: Date().addingTimeInterval(-4 * 86400), value: 380),
            DailyMetricData(date: Date().addingTimeInterval(-3 * 86400), value: 560),
            DailyMetricData(date: Date().addingTimeInterval(-2 * 86400), value: 450),
            DailyMetricData(date: Date().addingTimeInterval(-1 * 86400), value: 530),
            DailyMetricData(date: Date(), value: 480)
        ]

        return manager
    }
}
