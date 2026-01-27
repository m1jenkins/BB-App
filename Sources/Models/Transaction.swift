//
//  Transaction.swift
//  BetterBet
//
//  Data model for wallet transactions and money movement.
//  Every transaction is a receipt - transparent and complete.
//
//  SEMANTIC FIREWALL NOTICE:
//  - "Stake" = money committed to a pledge
//  - "Payout" = money received from successful pledge
//  - NO gambling terminology
//

import Foundation
import SwiftData

// MARK: - Transaction Type

/// Types of transactions in the wallet
enum TransactionType: String, Codable, CaseIterable, Identifiable {
    case deposit = "deposit"  // Money in from external source
    case withdrawal = "withdrawal"  // Money out to external source
    case stakeIn = "stakeIn"  // Stake locked for a pledge
    case stakeReturn = "stakeReturn"  // Stake returned (pledge fulfilled)
    case payout = "payout"  // Winnings from others' forfeited stakes
    case forfeit = "forfeit"  // Stake lost due to failed pledge
    case refund = "refund"  // Challenge cancelled, stake returned

    var id: String { rawValue }

    /// Display name for the transaction type
    var displayName: String {
        switch self {
        case .deposit: return "Deposit"
        case .withdrawal: return "Withdrawal"
        case .stakeIn: return "Stake Placed"
        case .stakeReturn: return "Stake Returned"
        case .payout: return "Payout"
        case .forfeit: return "Stake Forfeited"
        case .refund: return "Refund"
        }
    }

    /// SF Symbol icon for the transaction type
    var icon: String {
        switch self {
        case .deposit: return "arrow.down.circle.fill"
        case .withdrawal: return "arrow.up.circle.fill"
        case .stakeIn: return "lock.fill"
        case .stakeReturn: return "lock.open.fill"
        case .payout: return "star.circle.fill"
        case .forfeit: return "xmark.circle.fill"
        case .refund: return "arrow.uturn.backward.circle.fill"
        }
    }

    /// Whether this transaction increases available balance
    var isCredit: Bool {
        switch self {
        case .deposit, .stakeReturn, .payout, .refund: return true
        case .withdrawal, .stakeIn, .forfeit: return false
        }
    }

    /// Short description for context
    var description: String {
        switch self {
        case .deposit: return "Added funds to wallet"
        case .withdrawal: return "Withdrew to payment method"
        case .stakeIn: return "Committed to challenge"
        case .stakeReturn: return "Pledge fulfilled"
        case .payout: return "Earned from survivors' pot"
        case .forfeit: return "Pledge not fulfilled"
        case .refund: return "Challenge cancelled"
        }
    }
}

// MARK: - Transaction Status

/// Status of a transaction
enum TransactionStatus: String, Codable {
    case pending = "pending"
    case processing = "processing"
    case completed = "completed"
    case failed = "failed"
    case cancelled = "cancelled"

    /// Display text for status
    var displayText: String {
        switch self {
        case .pending: return "Pending"
        case .processing: return "Processing"
        case .completed: return "Completed"
        case .failed: return "Failed"
        case .cancelled: return "Cancelled"
        }
    }

    /// Whether the transaction is finalized
    var isFinal: Bool {
        switch self {
        case .completed, .failed, .cancelled: return true
        case .pending, .processing: return false
        }
    }
}

// MARK: - Transaction Model

/// A single transaction in the wallet history.
/// Every money event is a receipt with full transparency.
@Model
final class WalletTransaction {
    // MARK: - Properties

    /// Unique identifier
    var id: UUID

    /// Wallet ID this transaction belongs to
    var walletID: UUID

    /// Type of transaction
    var typeRaw: String

    /// Transaction amount (always positive)
    var amount: Double

    /// Processing fee (if any)
    var fee: Double

    /// Status of the transaction
    var statusRaw: String

    /// When the transaction was created
    var createdAt: Date

    /// When the transaction was completed (if applicable)
    var completedAt: Date?

    /// Associated challenge ID (for stake/payout transactions)
    var challengeID: UUID?

    /// Challenge name for display
    var challengeName: String?

    /// Other party in the transaction (for payouts)
    var counterpartyName: String?

    /// Additional notes or description
    var notes: String?

    // MARK: - Computed Properties

    /// Transaction type
    var type: TransactionType {
        get { TransactionType(rawValue: typeRaw) ?? .deposit }
        set { typeRaw = newValue.rawValue }
    }

    /// Transaction status
    var status: TransactionStatus {
        get { TransactionStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    /// Net amount (positive for credits, negative for debits)
    var netAmount: Double {
        type.isCredit ? amount : -amount
    }

    /// Formatted amount with sign
    var formattedAmount: String {
        let sign = type.isCredit ? "+" : "-"
        return "\(sign)$\(String(format: "%.2f", amount))"
    }

    /// Formatted net amount for display
    var displayAmount: String {
        String(format: "$%.2f", amount)
    }

    /// Formatted fee
    var formattedFee: String {
        fee > 0 ? String(format: "$%.2f", fee) : "No fee"
    }

    /// Formatted timestamp
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }

    /// Short date for list display
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: createdAt)
    }

    /// Time only for list display
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }

    /// Whether this transaction is related to a challenge
    var isChallengeRelated: Bool {
        challengeID != nil
    }

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        walletID: UUID,
        type: TransactionType,
        amount: Double,
        fee: Double = 0,
        status: TransactionStatus = .completed,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        challengeID: UUID? = nil,
        challengeName: String? = nil,
        counterpartyName: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.walletID = walletID
        self.typeRaw = type.rawValue
        self.amount = amount
        self.fee = fee
        self.statusRaw = status.rawValue
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.challengeID = challengeID
        self.challengeName = challengeName
        self.counterpartyName = counterpartyName
        self.notes = notes
    }
}

// MARK: - Mock Data

extension WalletTransaction {
    /// Mock deposit transaction
    static func mockDeposit(walletID: UUID = UUID()) -> WalletTransaction {
        WalletTransaction(
            walletID: walletID,
            type: .deposit,
            amount: 100.00,
            fee: 0,
            status: .completed,
            createdAt: Date().addingTimeInterval(-86400),  // 1 day ago
            completedAt: Date().addingTimeInterval(-86400)
        )
    }

    /// Mock stake transaction
    static func mockStake(walletID: UUID = UUID()) -> WalletTransaction {
        WalletTransaction(
            walletID: walletID,
            type: .stakeIn,
            amount: 25.00,
            fee: 0,
            status: .completed,
            createdAt: Date().addingTimeInterval(-43200),  // 12 hours ago
            completedAt: Date().addingTimeInterval(-43200),
            challengeID: UUID(),
            challengeName: "Weekend Step Showdown"
        )
    }

    /// Mock payout transaction
    static func mockPayout(walletID: UUID = UUID()) -> WalletTransaction {
        WalletTransaction(
            walletID: walletID,
            type: .payout,
            amount: 50.00,
            fee: 2.50,
            status: .completed,
            createdAt: Date().addingTimeInterval(-172800),  // 2 days ago
            completedAt: Date().addingTimeInterval(-172800),
            challengeID: UUID(),
            challengeName: "Weekly Active Zone",
            counterpartyName: "From pot (4 survivors)"
        )
    }

    /// Mock pending withdrawal
    static func mockPendingWithdrawal(walletID: UUID = UUID()) -> WalletTransaction {
        WalletTransaction(
            walletID: walletID,
            type: .withdrawal,
            amount: 75.00,
            fee: 0,
            status: .pending,
            createdAt: Date().addingTimeInterval(-3600)  // 1 hour ago
        )
    }

    /// Generate mock transaction history
    static func mockHistory(walletID: UUID = UUID()) -> [WalletTransaction] {
        [
            mockDeposit(walletID: walletID),
            mockStake(walletID: walletID),
            mockPayout(walletID: walletID),
            WalletTransaction(
                walletID: walletID,
                type: .stakeReturn,
                amount: 25.00,
                status: .completed,
                createdAt: Date().addingTimeInterval(-259200),  // 3 days ago
                challengeID: UUID(),
                challengeName: "Daily Distance Derby"
            ),
            WalletTransaction(
                walletID: walletID,
                type: .deposit,
                amount: 50.00,
                status: .completed,
                createdAt: Date().addingTimeInterval(-604800)  // 1 week ago
            ),
        ]
    }
}
