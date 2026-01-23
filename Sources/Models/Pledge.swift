//
//  Pledge.swift
//  BetterBet
//
//  Core data model for fitness commitment pledges.
//  Phase 2: Fitness-only, HealthKit-verified challenges.
//
//  SEMANTIC FIREWALL NOTICE:
//  A "Pledge" is a commitment contract, NOT a bet.
//  - "Stake" = amount committed
//  - "Pot" = pooled stakes from participants
//  - "Fulfilled" / "Failed" = commitment outcome (NOT win/lose)
//

import Foundation
import SwiftData

// MARK: - Challenge Type

/// Types of fitness challenges supported by HealthKit verification.
/// Phase 2: Exclusively hardware-verified metrics - no manual "Honesty Hour".
enum ChallengeType: String, Codable, CaseIterable, Identifiable {
    case steps          // Daily step count
    case distance       // Total distance (meters)
    case activeEnergy   // Active calories burned (kcal)

    var id: String { rawValue }

    /// Display name for the challenge type
    var displayName: String {
        switch self {
        case .steps: return "Step Survivor"
        case .distance: return "Distance Demon"
        case .activeEnergy: return "Calorie Burner"
        }
    }

    /// Short description of the challenge
    var subtitle: String {
        switch self {
        case .steps: return "Daily step goal"
        case .distance: return "Total weekly distance"
        case .activeEnergy: return "Active energy burned"
        }
    }

    /// SF Symbol icon for the challenge type
    var icon: String {
        switch self {
        case .steps: return "figure.walk"
        case .distance: return "map"
        case .activeEnergy: return "flame.fill"
        }
    }

    /// Unit label for display
    var unitLabel: String {
        switch self {
        case .steps: return "steps"
        case .distance: return "miles"
        case .activeEnergy: return "kcal"
        }
    }

    /// Default target value for new pledges
    var defaultTarget: Double {
        switch self {
        case .steps: return 10000       // 10k steps/day
        case .distance: return 15       // 15 miles/week
        case .activeEnergy: return 500  // 500 kcal/day
        }
    }

    /// Suggested targets for picker
    var suggestedTargets: [Double] {
        switch self {
        case .steps: return [7000, 10000, 12500, 15000]
        case .distance: return [10, 15, 20, 30]
        case .activeEnergy: return [300, 500, 750, 1000]
        }
    }

    /// Format a value for display with proper unit
    func formatValue(_ value: Double) -> String {
        switch self {
        case .steps:
            return "\(Int(value).formatted())"
        case .distance:
            return String(format: "%.1f", value)
        case .activeEnergy:
            return "\(Int(value).formatted())"
        }
    }
}

// MARK: - Pledge Model

/// A fitness commitment pledge with HealthKit-verified metrics.
/// Users stake money and must meet the target to keep their stake.
@Model
final class Pledge {
    // MARK: - Properties

    /// Unique identifier
    var id: UUID

    /// Pledge title (e.g., "Weekly Step Challenge")
    var title: String

    /// Type of fitness metric being tracked
    var type: ChallengeType

    /// Target value to achieve (e.g., 70000 steps, 15.0 miles)
    var targetValue: Double

    /// Current progress toward target
    var currentProgress: Double

    /// Individual stake amount
    /// SEMANTIC FIREWALL: "stake" not "bet"
    var stakeAmount: Double

    /// Total pot value (all participants' stakes)
    /// SEMANTIC FIREWALL: "pot" = pooled commitments
    var potValue: Double

    /// Challenge start date
    var startDate: Date

    /// Challenge end date (deadline)
    var endDate: Date

    /// Pledge status
    var status: PledgeStatus

    /// Whether this is the user's pledge (vs viewing others)
    var isCurrentUser: Bool

    /// Creator's user ID
    var creatorID: String

    /// Participant count
    var participantCount: Int

    // MARK: - Computed Properties

    /// Progress as percentage (0.0 to 1.0)
    var progressPercentage: Double {
        guard targetValue > 0 else { return 0 }
        return min(currentProgress / targetValue, 1.0)
    }

    /// Formatted progress display
    var progressDisplay: String {
        "\(type.formatValue(currentProgress)) / \(type.formatValue(targetValue)) \(type.unitLabel)"
    }

    /// Days remaining in the challenge
    var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: endDate)
        return max(0, components.day ?? 0)
    }

    /// Time remaining as formatted string
    var timeRemaining: String {
        if daysRemaining == 0 {
            let hours = Calendar.current.dateComponents([.hour], from: Date(), to: endDate).hour ?? 0
            if hours <= 0 {
                return "Ended"
            }
            return "\(hours)h left"
        } else if daysRemaining == 1 {
            return "1 day left"
        } else {
            return "\(daysRemaining) days"
        }
    }

    /// Whether the deadline has passed
    var hasEnded: Bool {
        Date() > endDate
    }

    /// Challenge status based on progress and time
    var challengeStatus: ChallengeStatus {
        if status == .failed { return .failed }
        if status == .completed { return .completed }

        if progressPercentage >= 1.0 {
            return .completed
        } else if daysRemaining <= 1 && progressPercentage < 0.8 {
            return .atRisk
        } else {
            return .onTrack
        }
    }

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        title: String,
        type: ChallengeType,
        targetValue: Double,
        currentProgress: Double = 0,
        stakeAmount: Double,
        potValue: Double = 0,
        startDate: Date = Date(),
        endDate: Date,
        status: PledgeStatus = .active,
        isCurrentUser: Bool = true,
        creatorID: String = "",
        participantCount: Int = 1
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.targetValue = targetValue
        self.currentProgress = currentProgress
        self.stakeAmount = stakeAmount
        self.potValue = potValue > 0 ? potValue : stakeAmount * Double(participantCount)
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.isCurrentUser = isCurrentUser
        self.creatorID = creatorID
        self.participantCount = participantCount
    }
}

// MARK: - Pledge Status

/// Status of a pledge
/// SEMANTIC FIREWALL: Describes commitment fulfillment, not gambling outcomes
enum PledgeStatus: String, Codable {
    case pending = "pending"        // Not yet started
    case active = "active"          // In progress
    case completed = "completed"    // Successfully fulfilled commitment
    case failed = "failed"          // Did not meet commitment
    case cancelled = "cancelled"    // Cancelled before completion
}

// MARK: - Stake Amounts

/// Predefined stake amounts for pledge creation
enum StakeAmount: Double, CaseIterable {
    case twenty = 20
    case fifty = 50
    case hundred = 100

    var displayString: String {
        "$\(Int(rawValue))"
    }
}

// MARK: - Mock Data

extension Pledge {
    /// Mock active pledge for development
    static var mockStepChallenge: Pledge {
        let calendar = Calendar.current
        let startOfWeek = calendar.startOfDay(for: Date())
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!.addingTimeInterval(86399)

        return Pledge(
            title: "Weekly Steps",
            type: .steps,
            targetValue: 70000,
            currentProgress: 52847,
            stakeAmount: 25,
            potValue: 150,
            startDate: startOfWeek,
            endDate: endOfWeek,
            participantCount: 6
        )
    }

    /// Mock distance challenge
    static var mockDistanceChallenge: Pledge {
        let calendar = Calendar.current
        let startOfWeek = calendar.startOfDay(for: Date())
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!.addingTimeInterval(86399)

        return Pledge(
            title: "Distance Demon",
            type: .distance,
            targetValue: 15.0,
            currentProgress: 8.3,
            stakeAmount: 50,
            potValue: 200,
            startDate: startOfWeek,
            endDate: endOfWeek,
            participantCount: 4
        )
    }

    /// Mock calorie challenge
    static var mockCalorieChallenge: Pledge {
        let calendar = Calendar.current
        let startOfWeek = calendar.startOfDay(for: Date())
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!.addingTimeInterval(86399)

        return Pledge(
            title: "Calorie Burner",
            type: .activeEnergy,
            targetValue: 3500, // 500/day * 7 days
            currentProgress: 2100,
            stakeAmount: 20,
            potValue: 100,
            startDate: startOfWeek,
            endDate: endOfWeek,
            participantCount: 5
        )
    }
}
