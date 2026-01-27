//
//  Wallet.swift
//  BetterBet
//
//  Data model for user wallet and payment management.
//  "Put Your Money Where Your Health Is"
//
//  SEMANTIC FIREWALL NOTICE:
//  This is a COMMITMENT CONTRACT platform, NOT gambling.
//  Money terminology: "Stake", "Pot", "Deposit", "Withdraw"
//

import Foundation
import SwiftData

// MARK: - Payment Method

/// Supported payment methods for deposits and withdrawals
enum PaymentMethod: String, Codable, CaseIterable, Identifiable {
    case applePay = "applePay"
    case card = "card"
    case bank = "bank"

    var id: String { rawValue }

    /// Display name for the payment method
    var displayName: String {
        switch self {
        case .applePay: return "Apple Pay"
        case .card: return "Debit Card"
        case .bank: return "Bank Account"
        }
    }

    /// SF Symbol icon for the payment method
    var icon: String {
        switch self {
        case .applePay: return "apple.logo"
        case .card: return "creditcard.fill"
        case .bank: return "building.columns.fill"
        }
    }

    /// Short description
    var subtitle: String {
        switch self {
        case .applePay: return "Instant"
        case .card: return "1-2 business days"
        case .bank: return "3-5 business days"
        }
    }
}

// MARK: - Wallet Status

/// Current status of the wallet
enum WalletStatus: String, Codable {
    case active = "active"  // Normal operation
    case pending = "pending"  // Awaiting verification
    case suspended = "suspended"  // Temporarily disabled
    case restricted = "restricted"  // Limited functionality

    /// Display text for status
    var displayText: String {
        switch self {
        case .active: return "Active"
        case .pending: return "Pending Verification"
        case .suspended: return "Suspended"
        case .restricted: return "Restricted"
        }
    }

    /// Whether withdrawals are allowed
    var canWithdraw: Bool {
        self == .active
    }

    /// Whether deposits are allowed
    var canDeposit: Bool {
        self == .active || self == .restricted
    }
}

// MARK: - Wallet Model

/// User's wallet containing balance and payment information.
/// This is the money layer for the Better Bet commitment contract platform.
@Model
final class Wallet {
    // MARK: - Properties

    /// Unique identifier
    var id: UUID

    /// User ID this wallet belongs to
    var userID: String

    /// Available balance for stakes
    var availableBalance: Double

    /// Balance locked in active pledges
    var lockedBalance: Double

    /// Pending incoming deposits
    var pendingDeposits: Double

    /// Pending outgoing withdrawals
    var pendingWithdrawals: Double

    /// Linked payment method type
    var linkedPaymentMethodRaw: String?

    /// Last 4 digits of payment method (for display)
    var paymentMethodLast4: String?

    /// Current wallet status
    var statusRaw: String

    /// Account creation date
    var createdAt: Date

    /// Last transaction timestamp
    var lastTransactionAt: Date?

    // MARK: - Computed Properties

    /// Total balance (available + locked)
    var totalBalance: Double {
        availableBalance + lockedBalance
    }

    /// Linked payment method
    var linkedPaymentMethod: PaymentMethod? {
        get {
            guard let raw = linkedPaymentMethodRaw else { return nil }
            return PaymentMethod(rawValue: raw)
        }
        set {
            linkedPaymentMethodRaw = newValue?.rawValue
        }
    }

    /// Wallet status
    var status: WalletStatus {
        get { WalletStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    /// Formatted available balance
    var formattedAvailableBalance: String {
        String(format: "$%.2f", availableBalance)
    }

    /// Formatted total balance
    var formattedTotalBalance: String {
        String(format: "$%.2f", totalBalance)
    }

    /// Whether the wallet has a linked payment method
    var hasLinkedPayment: Bool {
        linkedPaymentMethod != nil
    }

    /// Display string for linked payment
    var linkedPaymentDisplay: String {
        guard let method = linkedPaymentMethod else {
            return "No payment method linked"
        }
        if let last4 = paymentMethodLast4 {
            return "\(method.displayName) •••• \(last4)"
        }
        return method.displayName
    }

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        userID: String,
        availableBalance: Double = 0,
        lockedBalance: Double = 0,
        pendingDeposits: Double = 0,
        pendingWithdrawals: Double = 0,
        linkedPaymentMethod: PaymentMethod? = nil,
        paymentMethodLast4: String? = nil,
        status: WalletStatus = .active,
        createdAt: Date = Date(),
        lastTransactionAt: Date? = nil
    ) {
        self.id = id
        self.userID = userID
        self.availableBalance = availableBalance
        self.lockedBalance = lockedBalance
        self.pendingDeposits = pendingDeposits
        self.pendingWithdrawals = pendingWithdrawals
        self.linkedPaymentMethodRaw = linkedPaymentMethod?.rawValue
        self.paymentMethodLast4 = paymentMethodLast4
        self.statusRaw = status.rawValue
        self.createdAt = createdAt
        self.lastTransactionAt = lastTransactionAt
    }
}

// MARK: - Mock Data

extension Wallet {
    /// Mock wallet for development and previews
    static var mock: Wallet {
        Wallet(
            userID: "user_123",
            availableBalance: 125.00,
            lockedBalance: 50.00,
            pendingDeposits: 0,
            pendingWithdrawals: 0,
            linkedPaymentMethod: .applePay,
            paymentMethodLast4: nil,
            status: .active,
            lastTransactionAt: Date().addingTimeInterval(-3600)
        )
    }

    /// Mock wallet with pending transfers
    static var mockWithPending: Wallet {
        Wallet(
            userID: "user_123",
            availableBalance: 75.50,
            lockedBalance: 100.00,
            pendingDeposits: 50.00,
            pendingWithdrawals: 25.00,
            linkedPaymentMethod: .card,
            paymentMethodLast4: "4242",
            status: .active,
            lastTransactionAt: Date()
        )
    }

    /// Empty wallet for new users
    static var mockEmpty: Wallet {
        Wallet(
            userID: "user_new",
            availableBalance: 0,
            lockedBalance: 0,
            status: .pending
        )
    }
}
