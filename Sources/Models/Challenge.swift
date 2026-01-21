//
//  Challenge.swift
//  BetterBet
//
//  Model representing a commitment challenge (e.g., Weekly Steps Challenge).
//
//  SEMANTIC FIREWALL NOTICE:
//  A "Challenge" is a commitment contract, NOT a bet.
//  - "Pot" = pooled stakes from participants
//  - "Stake" = individual commitment amount
//  - "Survivors" = those who fulfilled their commitment
//  - "Failed" = did not meet commitment requirements
//

import Foundation
import SwiftData

/// Represents a commitment challenge that users participate in.
/// Users "stake" money and must meet the challenge requirements to keep their stake.
@Model
final class Challenge {
    // MARK: - Properties

    /// Unique identifier
    var id: UUID

    /// Challenge title (e.g., "Weekly Steps Challenge")
    var title: String

    /// Challenge description
    var challengeDescription: String

    /// The target to achieve (e.g., 70,000 steps)
    var targetSteps: Int

    /// Individual stake amount per participant
    /// SEMANTIC FIREWALL: "stake" not "bet amount"
    var stakeAmount: Double

    /// Challenge start date
    var startDate: Date

    /// Challenge end date (deadline)
    var endDate: Date

    /// List of participant IDs
    var participantIDs: [UUID]

    /// Challenge status
    var status: ChallengeState

    // MARK: - Computed Properties

    /// Total pot value (sum of all stakes)
    /// SEMANTIC FIREWALL: "pot" refers to pooled commitments
    var potValue: Double {
        Double(participantIDs.count) * stakeAmount
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
            return "\(daysRemaining) days left"
        }
    }

    /// Whether the challenge deadline has passed
    var hasEnded: Bool {
        Date() > endDate
    }

    /// Current user's progress (placeholder - would be fetched from HealthManager)
    var currentUserProgress: Double {
        // This would be calculated from actual health data
        0.76 // 76% progress for mock
    }

    /// Number of participants who have met their commitment
    /// SEMANTIC FIREWALL: "survivors" not "winners"
    var survivorCount: Int {
        participants.filter { !$0.hasFailed }.count
    }

    // MARK: - Mock Participants (for MVP)

    /// Participants with their progress (would be fetched from CloudKit in production)
    var participants: [Participant] {
        Participant.mockParticipants
    }

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        targetSteps: Int,
        stakeAmount: Double,
        startDate: Date,
        endDate: Date,
        participantIDs: [UUID] = [],
        status: ChallengeState = .active
    ) {
        self.id = id
        self.title = title
        self.challengeDescription = description
        self.targetSteps = targetSteps
        self.stakeAmount = stakeAmount
        self.startDate = startDate
        self.endDate = endDate
        self.participantIDs = participantIDs
        self.status = status
    }
}

// MARK: - Challenge State

/// State of a challenge
/// SEMANTIC FIREWALL: States describe commitment status, not gambling outcomes
enum ChallengeState: String, Codable {
    case pending = "pending"        // Not yet started
    case active = "active"          // In progress
    case completed = "completed"    // Ended, results finalized
    case cancelled = "cancelled"    // Cancelled before completion
}

// MARK: - Mock Data

extension Challenge {
    /// Mock weekly steps challenge for development
    static var mockWeeklyChallenge: Challenge {
        let calendar = Calendar.current

        // Start of current week (Monday)
        var startOfWeek = Date()
        while calendar.component(.weekday, from: startOfWeek) != 2 {
            startOfWeek = calendar.date(byAdding: .day, value: -1, to: startOfWeek)!
        }
        startOfWeek = calendar.startOfDay(for: startOfWeek)

        // End of week (Sunday 11:59 PM)
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
            .addingTimeInterval(86399) // 23:59:59

        return Challenge(
            title: "Weekly Steps Challenge",
            description: "Hit 70,000 steps this week or lose your stake. Survivors split the pot from those who fail.",
            targetSteps: 70000,
            stakeAmount: 25.00, // SEMANTIC FIREWALL: "stake" not "bet"
            startDate: startOfWeek,
            endDate: endOfWeek,
            participantIDs: Participant.mockParticipants.map { $0.id },
            status: .active
        )
    }
}
