//
//  WalletManager.swift
//  BetterBet
//
//  Manager for wallet operations and transaction history.
//  "Put Your Money Where Your Health Is"
//
//  SEMANTIC FIREWALL NOTICE:
//  Money terminology: "Stake", "Pot", "Deposit", "Withdraw"
//  NOT: "Bet", "Wager", "Win", "Lose"
//

import Foundation
import Observation
import SwiftData

// MARK: - Wallet Manager

/// Manages wallet operations and transaction history.
/// Follows the same @Observable pattern as HealthManager and PledgeManager.
@Observable
final class WalletManager {
    // MARK: - Properties

    /// Current user's wallet
    var wallet: Wallet?

    /// Transaction history
    var transactions: [WalletTransaction] = []

    /// Loading state
    var isLoading: Bool = false

    /// Error message (if any)
    var errorMessage: String?

    /// Model context for persistence
    private var modelContext: ModelContext?

    // MARK: - Computed Properties

    /// Available balance for display
    var availableBalance: Double {
        wallet?.availableBalance ?? 0
    }

    /// Formatted available balance
    var formattedBalance: String {
        String(format: "$%.2f", availableBalance)
    }

    /// Locked balance (in active pledges)
    var lockedBalance: Double {
        wallet?.lockedBalance ?? 0
    }

    /// Total balance (available + locked)
    var totalBalance: Double {
        wallet?.totalBalance ?? 0
    }

    /// Whether the wallet is ready for transactions
    var isReady: Bool {
        wallet?.status == .active
    }

    /// Whether there are pending transactions
    var hasPendingTransactions: Bool {
        (wallet?.pendingDeposits ?? 0) > 0 || (wallet?.pendingWithdrawals ?? 0) > 0
    }

    /// Recent transactions (last 5)
    var recentTransactions: [WalletTransaction] {
        Array(transactions.prefix(5))
    }

    /// Grouped transactions by date
    var groupedTransactions: [(String, [WalletTransaction])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: transactions) { transaction -> String in
            if calendar.isDateInToday(transaction.createdAt) {
                return "Today"
            } else if calendar.isDateInYesterday(transaction.createdAt) {
                return "Yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM d"
                return formatter.string(from: transaction.createdAt)
            }
        }

        // Sort by date (most recent first)
        return grouped.sorted { first, second in
            if first.key == "Today" { return true }
            if second.key == "Today" { return false }
            if first.key == "Yesterday" { return true }
            if second.key == "Yesterday" { return false }

            guard let firstDate = first.value.first?.createdAt,
                let secondDate = second.value.first?.createdAt
            else {
                return false
            }
            return firstDate > secondDate
        }
    }

    // MARK: - Initialization

    init() {}

    /// Initialize with model context
    func configure(with context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Wallet Operations

    /// Fetch or create wallet for current user
    @MainActor
    func fetchWallet() async {
        isLoading = true
        defer { isLoading = false }

        // In production, this would fetch from CloudKit
        // For now, create a mock wallet if none exists
        if wallet == nil {
            wallet = Wallet.mock
        }

        await fetchTransactions()
    }

    /// Fetch transaction history
    @MainActor
    func fetchTransactions() async {
        guard let wallet = wallet else { return }

        // In production, this would fetch from CloudKit
        // For now, use mock data
        transactions = WalletTransaction.mockHistory(walletID: wallet.id)
            .sorted { $0.createdAt > $1.createdAt }
    }

    /// Request a deposit
    @MainActor
    func deposit(amount: Double, method: PaymentMethod) async throws {
        guard let wallet = wallet, wallet.status.canDeposit else {
            throw WalletError.depositNotAllowed
        }

        guard amount >= 5 else {
            throw WalletError.minimumAmountNotMet
        }

        isLoading = true
        defer { isLoading = false }

        // Create pending transaction
        let transaction = WalletTransaction(
            walletID: wallet.id,
            type: .deposit,
            amount: amount,
            status: method == .applePay ? .completed : .pending
        )

        // Update wallet balance
        if method == .applePay {
            // Instant for Apple Pay
            wallet.availableBalance += amount
            wallet.lastTransactionAt = Date()
        } else {
            // Pending for other methods
            wallet.pendingDeposits += amount
        }

        // Add to transactions
        transactions.insert(transaction, at: 0)

        // In production, save to persistence
        if let context = modelContext {
            context.insert(transaction)
            try? context.save()
        }
    }

    /// Request a withdrawal
    @MainActor
    func withdraw(amount: Double) async throws {
        guard let wallet = wallet, wallet.status.canWithdraw else {
            throw WalletError.withdrawalNotAllowed
        }

        guard amount <= wallet.availableBalance else {
            throw WalletError.insufficientFunds
        }

        guard amount >= 10 else {
            throw WalletError.minimumWithdrawalNotMet
        }

        isLoading = true
        defer { isLoading = false }

        // Create pending withdrawal transaction
        let transaction = WalletTransaction(
            walletID: wallet.id,
            type: .withdrawal,
            amount: amount,
            status: .pending
        )

        // Update wallet
        wallet.availableBalance -= amount
        wallet.pendingWithdrawals += amount
        wallet.lastTransactionAt = Date()

        // Add to transactions
        transactions.insert(transaction, at: 0)

        // In production, save to persistence
        if let context = modelContext {
            context.insert(transaction)
            try? context.save()
        }
    }

    /// Lock stake for a pledge
    @MainActor
    func lockStake(amount: Double, pledgeID: UUID, pledgeName: String) async throws {
        guard let wallet = wallet else {
            throw WalletError.walletNotFound
        }

        guard amount <= wallet.availableBalance else {
            throw WalletError.insufficientFunds
        }

        // Create stake transaction
        let transaction = WalletTransaction(
            walletID: wallet.id,
            type: .stakeIn,
            amount: amount,
            status: .completed,
            challengeID: pledgeID,
            challengeName: pledgeName
        )

        // Update wallet
        wallet.availableBalance -= amount
        wallet.lockedBalance += amount
        wallet.lastTransactionAt = Date()

        // Add to transactions
        transactions.insert(transaction, at: 0)
    }

    /// Return stake when pledge is fulfilled
    @MainActor
    func returnStake(amount: Double, pledgeID: UUID, pledgeName: String) async {
        guard let wallet = wallet else { return }

        // Create stake return transaction
        let transaction = WalletTransaction(
            walletID: wallet.id,
            type: .stakeReturn,
            amount: amount,
            status: .completed,
            challengeID: pledgeID,
            challengeName: pledgeName
        )

        // Update wallet
        wallet.lockedBalance -= amount
        wallet.availableBalance += amount
        wallet.lastTransactionAt = Date()

        // Add to transactions
        transactions.insert(transaction, at: 0)
    }

    /// Process payout from pot
    @MainActor
    func processPayout(
        amount: Double, fee: Double, pledgeID: UUID, pledgeName: String, survivors: Int
    ) async {
        guard let wallet = wallet else { return }

        // Create payout transaction
        let transaction = WalletTransaction(
            walletID: wallet.id,
            type: .payout,
            amount: amount,
            fee: fee,
            status: .completed,
            challengeID: pledgeID,
            challengeName: pledgeName,
            counterpartyName: "From pot (\(survivors) survivors)"
        )

        // Update wallet (payout is net of fee)
        wallet.availableBalance += (amount - fee)
        wallet.lastTransactionAt = Date()

        // Add to transactions
        transactions.insert(transaction, at: 0)
    }

    /// Process forfeit when pledge fails
    @MainActor
    func processForfeit(amount: Double, pledgeID: UUID, pledgeName: String) async {
        guard let wallet = wallet else { return }

        // Create forfeit transaction
        let transaction = WalletTransaction(
            walletID: wallet.id,
            type: .forfeit,
            amount: amount,
            status: .completed,
            challengeID: pledgeID,
            challengeName: pledgeName
        )

        // Update wallet (locked stake is forfeited)
        wallet.lockedBalance -= amount
        wallet.lastTransactionAt = Date()

        // Add to transactions
        transactions.insert(transaction, at: 0)
    }

    /// Link a payment method
    @MainActor
    func linkPaymentMethod(_ method: PaymentMethod, last4: String? = nil) {
        wallet?.linkedPaymentMethod = method
        wallet?.paymentMethodLast4 = last4
    }

    /// Remove linked payment method
    @MainActor
    func unlinkPaymentMethod() {
        wallet?.linkedPaymentMethod = nil
        wallet?.paymentMethodLast4 = nil
    }
}

// MARK: - Wallet Errors

enum WalletError: Error, LocalizedError {
    case walletNotFound
    case insufficientFunds
    case depositNotAllowed
    case withdrawalNotAllowed
    case minimumAmountNotMet
    case minimumWithdrawalNotMet
    case paymentMethodRequired

    var errorDescription: String? {
        switch self {
        case .walletNotFound:
            return "Wallet not found. Please try again."
        case .insufficientFunds:
            return "Insufficient funds for this transaction."
        case .depositNotAllowed:
            return "Deposits are not allowed at this time."
        case .withdrawalNotAllowed:
            return "Withdrawals are not allowed at this time."
        case .minimumAmountNotMet:
            return "Minimum deposit is $5."
        case .minimumWithdrawalNotMet:
            return "Minimum withdrawal is $10."
        case .paymentMethodRequired:
            return "Please link a payment method first."
        }
    }
}

// MARK: - Preview Support

extension WalletManager {
    /// Preview instance with mock data
    static var preview: WalletManager {
        let manager = WalletManager()
        manager.wallet = Wallet.mock
        manager.transactions = WalletTransaction.mockHistory(walletID: manager.wallet!.id)
            .sorted { $0.createdAt > $1.createdAt }
        return manager
    }

    /// Preview instance with pending transactions
    static var previewWithPending: WalletManager {
        let manager = WalletManager()
        manager.wallet = Wallet.mockWithPending
        manager.transactions =
            [
                WalletTransaction.mockPendingWithdrawal(walletID: manager.wallet!.id)
            ] + WalletTransaction.mockHistory(walletID: manager.wallet!.id)
        return manager
    }

    /// Empty wallet preview
    static var previewEmpty: WalletManager {
        let manager = WalletManager()
        manager.wallet = Wallet.mockEmpty
        manager.transactions = []
        return manager
    }
}
