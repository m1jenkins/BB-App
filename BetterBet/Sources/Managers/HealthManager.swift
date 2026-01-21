//
//  HealthManager.swift
//  BetterBet
//
//  The "Oracle" - Manages all HealthKit integrations
//  Provides read-only access to Steps and Workouts for challenge verification.
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

    /// Weekly step count (refreshed on demand)
    var weeklySteps: Int = 0

    /// Daily step breakdown for the current week
    var dailySteps: [DailyStepData] = []

    /// Today's step count
    var todaySteps: Int = 0

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

    struct DailyStepData: Identifiable {
        let id = UUID()
        let date: Date
        let steps: Int

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

    /// Request authorization for Steps and Workouts (read-only)
    /// This is the first step before any data can be accessed.
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
            HKObjectType.workoutType()
        ]

        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)

            // Check the authorization status for steps
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

    // MARK: - Data Fetching

    /// Fetch weekly step count for challenge verification
    /// Returns the total steps for the current week (Monday to Sunday)
    func fetchWeeklySteps() async {
        // For MVP, return dummy data to populate the UI
        // This allows development without a physical device
        #if targetEnvironment(simulator)
        await loadDummyData()
        return
        #else
        await loadRealHealthData()
        #endif
    }

    /// Load dummy data for simulator/development
    private func loadDummyData() async {
        isLoading = true
        defer { isLoading = false }

        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)

        // Generate realistic dummy data for the week
        let calendar = Calendar.current
        let today = Date()

        // Find the start of the week (Monday)
        var startOfWeek = today
        while calendar.component(.weekday, from: startOfWeek) != 2 { // 2 = Monday
            startOfWeek = calendar.date(byAdding: .day, value: -1, to: startOfWeek)!
        }
        startOfWeek = calendar.startOfDay(for: startOfWeek)

        // Generate daily steps
        var totalSteps = 0
        var dailyData: [DailyStepData] = []

        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) else {
                continue
            }

            // Only generate data for past days and today
            let steps: Int
            if date <= today {
                // Random steps between 3,000 and 15,000
                steps = Int.random(in: 3000...15000)
            } else {
                steps = 0
            }

            dailyData.append(DailyStepData(date: date, steps: steps))
            totalSteps += steps
        }

        self.dailySteps = dailyData
        self.weeklySteps = totalSteps
        self.todaySteps = dailyData.first(where: { $0.isToday })?.steps ?? 8432 // Default dummy value

        // Set a consistent dummy value for the UI preview
        if weeklySteps == 0 {
            weeklySteps = 52847
            todaySteps = 8432
        }
    }

    /// Load real health data from HealthKit
    private func loadRealHealthData() async {
        guard let healthStore = healthStore else {
            errorMessage = "HealthKit not available"
            return
        }

        guard authorizationStatus == .authorized else {
            errorMessage = "Health data access not authorized"
            return
        }

        isLoading = true
        defer { isLoading = false }

        let stepType = HKQuantityType(.stepCount)
        let calendar = Calendar.current

        // Calculate date range for current week
        let today = Date()
        var startOfWeek = today
        while calendar.component(.weekday, from: startOfWeek) != 2 { // Monday
            startOfWeek = calendar.date(byAdding: .day, value: -1, to: startOfWeek)!
        }
        startOfWeek = calendar.startOfDay(for: startOfWeek)

        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!

        // Query for daily steps
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfWeek,
            end: endOfWeek,
            options: .strictStartDate
        )

        let query = HKStatisticsCollectionQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startOfWeek,
            intervalComponents: DateComponents(day: 1)
        )

        query.initialResultsHandler = { [weak self] _, results, error in
            Task { @MainActor in
                guard let self = self else { return }

                if let error = error {
                    self.errorMessage = "Failed to fetch steps: \(error.localizedDescription)"
                    return
                }

                guard let results = results else {
                    self.errorMessage = "No step data available"
                    return
                }

                var totalSteps = 0
                var dailyData: [DailyStepData] = []

                results.enumerateStatistics(from: startOfWeek, to: endOfWeek) { statistics, _ in
                    let steps = Int(statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0)
                    dailyData.append(DailyStepData(date: statistics.startDate, steps: steps))
                    totalSteps += steps
                }

                self.dailySteps = dailyData
                self.weeklySteps = totalSteps
                self.todaySteps = dailyData.first(where: { $0.isToday })?.steps ?? 0
            }
        }

        healthStore.execute(query)
    }

    /// Fetch today's step count only (for quick updates)
    func fetchTodaySteps() async {
        guard let healthStore = healthStore, authorizationStatus == .authorized else {
            // Return dummy data in simulator
            #if targetEnvironment(simulator)
            todaySteps = Int.random(in: 5000...12000)
            #endif
            return
        }

        let stepType = HKQuantityType(.stepCount)
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, error in
            Task { @MainActor in
                guard let self = self else { return }

                if let error = error {
                    self.errorMessage = "Failed to fetch today's steps: \(error.localizedDescription)"
                    return
                }

                self.todaySteps = Int(result?.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Challenge Verification

    /// Verify if a user has met their step commitment
    /// SEMANTIC FIREWALL: This returns "fulfilled" or "failed", not "won" or "lost"
    func verifyStepCommitment(targetSteps: Int) -> CommitmentStatus {
        if weeklySteps >= targetSteps {
            return .fulfilled(steps: weeklySteps, target: targetSteps)
        } else {
            return .failed(steps: weeklySteps, target: targetSteps, shortfall: targetSteps - weeklySteps)
        }
    }

    enum CommitmentStatus {
        case fulfilled(steps: Int, target: Int)
        case failed(steps: Int, target: Int, shortfall: Int)

        var isFulfilled: Bool {
            if case .fulfilled = self { return true }
            return false
        }

        /// Progress as a percentage (0.0 to 1.0+)
        var progress: Double {
            switch self {
            case .fulfilled(let steps, let target):
                return Double(steps) / Double(target)
            case .failed(let steps, let target, _):
                return Double(steps) / Double(target)
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
        manager.weeklySteps = 52847
        manager.todaySteps = 8432
        manager.dailySteps = [
            DailyStepData(date: Date().addingTimeInterval(-6 * 86400), steps: 7823),
            DailyStepData(date: Date().addingTimeInterval(-5 * 86400), steps: 9245),
            DailyStepData(date: Date().addingTimeInterval(-4 * 86400), steps: 6891),
            DailyStepData(date: Date().addingTimeInterval(-3 * 86400), steps: 11234),
            DailyStepData(date: Date().addingTimeInterval(-2 * 86400), steps: 8567),
            DailyStepData(date: Date().addingTimeInterval(-1 * 86400), steps: 10655),
            DailyStepData(date: Date(), steps: 8432)
        ]
        return manager
    }
}
