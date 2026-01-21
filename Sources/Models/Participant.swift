//
//  Participant.swift
//  BetterBet
//
//  Model representing a participant in a commitment challenge.
//
//  SEMANTIC FIREWALL NOTICE:
//  Participants "stake" commitments and either "fulfill" or "fail" them.
//  NO gambling terminology (winner/loser/bet) should be used.
//

import Foundation
import SwiftData

/// Represents a user participating in a challenge.
/// Tracks their progress toward fulfilling their commitment.
@Model
final class Participant {
    // MARK: - Properties

    /// Unique identifier
    var id: UUID

    /// Display name
    var name: String

    /// Avatar emoji (for MVP, using emojis instead of images)
    var avatarEmoji: String

    /// Current step count for the challenge period
    var steps: Int

    /// Whether this is the current user
    var isCurrentUser: Bool

    /// Date when progress was last verified
    var lastVerified: Date

    /// Commitment status
    /// SEMANTIC FIREWALL: "hasFailed" means failed to meet commitment, not "lost a bet"
    var hasFailed: Bool

    /// The stake amount this participant committed
    /// SEMANTIC FIREWALL: "stake" not "bet"
    var stakeAmount: Double

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String,
        avatarEmoji: String,
        steps: Int,
        isCurrentUser: Bool = false,
        lastVerified: Date = Date(),
        hasFailed: Bool = false,
        stakeAmount: Double = 25.00
    ) {
        self.id = id
        self.name = name
        self.avatarEmoji = avatarEmoji
        self.steps = steps
        self.isCurrentUser = isCurrentUser
        self.lastVerified = lastVerified
        self.hasFailed = hasFailed
        self.stakeAmount = stakeAmount
    }
}

// MARK: - Computed Properties

extension Participant {
    /// Progress toward a target as a percentage (0.0 to 1.0)
    func progress(toward target: Int) -> Double {
        guard target > 0 else { return 0 }
        return min(1.0, Double(steps) / Double(target))
    }

    /// Formatted step count
    var formattedSteps: String {
        steps.formatted()
    }
}

// MARK: - Mock Data

extension Participant {
    /// Mock participants for development and previews
    static var mockParticipants: [Participant] {
        [
            Participant(
                name: "You",
                avatarEmoji: "🏃",
                steps: 52847,
                isCurrentUser: true,
                hasFailed: false
            ),
            Participant(
                name: "Sarah",
                avatarEmoji: "💪",
                steps: 71234,
                isCurrentUser: false,
                hasFailed: false
            ),
            Participant(
                name: "Mike",
                avatarEmoji: "🔥",
                steps: 58921,
                isCurrentUser: false,
                hasFailed: false
            ),
            Participant(
                name: "Emma",
                avatarEmoji: "⭐",
                steps: 49876,
                isCurrentUser: false,
                hasFailed: false
            ),
            // SEMANTIC FIREWALL: Dave "failed" his commitment, he didn't "lose"
            Participant(
                name: "Dave",
                avatarEmoji: "😎",
                steps: 23456,
                isCurrentUser: false,
                hasFailed: true // Failed to meet commitment
            ),
            Participant(
                name: "Alex",
                avatarEmoji: "🎯",
                steps: 67890,
                isCurrentUser: false,
                hasFailed: false
            )
        ]
    }

    /// Current user mock
    static var currentUser: Participant {
        mockParticipants.first { $0.isCurrentUser }!
    }
}
