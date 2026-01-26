//
//  Friend.swift
//  BetterBet
//
//  Model representing a friend in the social network.
//  Used for friend management and pledge invitations.
//
//  SEMANTIC FIREWALL NOTICE:
//  - "Pledge invites" not "bet invites"
//

import Foundation
import SwiftData

/// Represents a friend in the Better Bet social network.
@Model
class Friend {
    var id: UUID
    var name: String
    var avatar: String  // Emoji representation
    var activePledgesCount: Int
    var createdAt: Date

    init(id: UUID = UUID(), name: String, avatar: String, activePledgesCount: Int = 0) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.activePledgesCount = activePledgesCount
        self.createdAt = Date()
    }

    // MARK: - Mock Data

    static let mockFriends: [Friend] = [
        Friend(name: "Sarah", avatar: "💪", activePledgesCount: 2),
        Friend(name: "Mike", avatar: "🔥", activePledgesCount: 1),
        Friend(name: "Emma", avatar: "⭐", activePledgesCount: 3),
        Friend(name: "Dave", avatar: "😎", activePledgesCount: 0),
        Friend(name: "Alex", avatar: "🎯", activePledgesCount: 1),
        Friend(name: "Jordan", avatar: "🏃", activePledgesCount: 2),
        Friend(name: "Taylor", avatar: "💎", activePledgesCount: 0),
        Friend(name: "Casey", avatar: "🚀", activePledgesCount: 1),
    ]
}
