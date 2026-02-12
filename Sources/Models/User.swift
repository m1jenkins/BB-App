//
//  User.swift
//  BetterBet
//
//  Data model for the current user's profile.
//  Tracks identity, stats, and lifetime performance.
//
//  SEMANTIC FIREWALL NOTICE:
//  - "Fulfilled" not "Won"
//  - "Failed" not "Lost"
//  - "Pledges" not "Bets"
//

import Foundation
import SwiftData

// MARK: - User Model

/// Represents the current user's profile and lifetime stats.
@Model
final class User {
    // MARK: - Identity

    /// Unique identifier
    var id: UUID

    /// Display name shown in leaderboards and profile
    var displayName: String

    /// Emoji avatar (rendered in a circle)
    var avatarEmoji: String

    /// Email address (optional, for account recovery)
    var email: String?

    /// Date the user joined Better Bet
    var memberSince: Date

    // MARK: - Lifetime Stats

    /// Total number of pledges entered
    var totalPledges: Int

    /// Number of pledges fulfilled (survived)
    var fulfilledPledges: Int

    /// Total amount staked across all pledges
    var totalStaked: Double

    /// Total earnings from fulfilled pledges (pot splits)
    var totalEarnings: Double

    /// Current active streak (consecutive fulfilled pledges)
    var currentStreak: Int

    // MARK: - Computed Properties

    /// Fulfillment rate as a percentage (0–100)
    var fulfillmentRate: Double {
        guard totalPledges > 0 else { return 0 }
        return (Double(fulfilledPledges) / Double(totalPledges)) * 100
    }

    /// Formatted fulfillment rate
    var formattedFulfillmentRate: String {
        String(format: "%.0f%%", fulfillmentRate)
    }

    /// Formatted total earnings
    var formattedEarnings: String {
        String(format: "$%.2f", totalEarnings)
    }

    /// Formatted total staked
    var formattedStaked: String {
        String(format: "$%.2f", totalStaked)
    }

    /// Member since, formatted for display
    var memberSinceFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return "Member since \(formatter.string(from: memberSince))"
    }

    /// Failed pledges count
    var failedPledges: Int {
        totalPledges - fulfilledPledges
    }

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        displayName: String,
        avatarEmoji: String = "💪",
        email: String? = nil,
        memberSince: Date = Date(),
        totalPledges: Int = 0,
        fulfilledPledges: Int = 0,
        totalStaked: Double = 0,
        totalEarnings: Double = 0,
        currentStreak: Int = 0
    ) {
        self.id = id
        self.displayName = displayName
        self.avatarEmoji = avatarEmoji
        self.email = email
        self.memberSince = memberSince
        self.totalPledges = totalPledges
        self.fulfilledPledges = fulfilledPledges
        self.totalStaked = totalStaked
        self.totalEarnings = totalEarnings
        self.currentStreak = currentStreak
    }
}

// MARK: - Mock Data

extension User {
    /// Mock user with solid track record
    static var mock: User {
        User(
            displayName: "Alex Chen",
            avatarEmoji: "🔥",
            email: "alex@betterbet.app",
            memberSince: Calendar.current.date(byAdding: .month, value: -4, to: Date()) ?? Date(),
            totalPledges: 12,
            fulfilledPledges: 10,
            totalStaked: 480.00,
            totalEarnings: 215.50,
            currentStreak: 3
        )
    }

    /// Brand new user with no history
    static var mockNewUser: User {
        User(
            displayName: "New User",
            avatarEmoji: "👋",
            email: nil,
            memberSince: Date(),
            totalPledges: 0,
            fulfilledPledges: 0,
            totalStaked: 0,
            totalEarnings: 0,
            currentStreak: 0
        )
    }
}
