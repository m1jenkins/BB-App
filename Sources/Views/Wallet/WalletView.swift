//
//  WalletView.swift
//  BetterBet
//
//  Main wallet screen showing balance, actions, and transactions.
//  "Trust beats hype — Money screens must feel calm, legible, and receipt-like"
//
//  SEMANTIC FIREWALL NOTICE:
//  Money terminology: "Deposit", "Withdraw", "Balance", "Stake"
//

import SwiftUI

// MARK: - Main Wallet View

/// Main wallet screen following DESIGN_SYSTEM.md Wallet Summary spec.
struct WalletView: View {
    @State private var walletManager = WalletManager.preview
    @State private var showDepositSheet = false
    @State private var showWithdrawSheet = false
    @State private var selectedTransaction: WalletTransaction?
    @State private var showTransactionDetail = false

    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Balance Card
                    BalanceCard(
                        availableBalance: walletManager.availableBalance,
                        lockedBalance: walletManager.lockedBalance,
                        pendingDeposits: walletManager.wallet?.pendingDeposits ?? 0,
                        pendingWithdrawals: walletManager.wallet?.pendingWithdrawals ?? 0
                    )

                    // Quick Actions
                    ActionButtonRow(
                        onDeposit: { showDepositSheet = true },
                        onWithdraw: { showWithdrawSheet = true },
                        canWithdraw: walletManager.wallet?.status.canWithdraw ?? false
                    )

                    // Linked Payment
                    if let wallet = walletManager.wallet {
                        LinkedPaymentCard(
                            method: wallet.linkedPaymentMethod,
                            last4: wallet.paymentMethodLast4,
                            status: wallet.status
                        )
                    }

                    // Recent Transactions
                    if !walletManager.transactions.isEmpty {
                        RecentTransactionsCard(
                            transactions: walletManager.recentTransactions,
                            onTap: { transaction in
                                selectedTransaction = transaction
                                showTransactionDetail = true
                            }
                        )
                    } else {
                        EmptyTransactionsCard()
                    }

                    Spacer()
                        .frame(height: DesignSystem.Spacing.xl)
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.top, DesignSystem.Spacing.sm)
            }
        }
        .navigationTitle("Wallet")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showDepositSheet) {
            DepositSheet(walletManager: walletManager)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showWithdrawSheet) {
            WithdrawSheet(walletManager: walletManager)
                .presentationDetents([.medium])
        }
        .sheet(item: $selectedTransaction) { transaction in
            TransactionReceiptView(transaction: transaction)
                .presentationDetents([.medium, .large])
        }
        .task {
            await walletManager.fetchWallet()
        }
    }
}

// MARK: - Balance Card

/// Main balance display with available and locked amounts.
struct BalanceCard: View {
    let availableBalance: Double
    let lockedBalance: Double
    let pendingDeposits: Double
    let pendingWithdrawals: Double

    private var hasPending: Bool {
        pendingDeposits > 0 || pendingWithdrawals > 0
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Available Balance (prominent)
            VStack(spacing: DesignSystem.Spacing.xxs) {
                Text("Available Balance")
                    .font(DesignSystem.Typography.caption())
                    .foregroundColor(DesignSystem.Colors.inkGray)
                    .textCase(.uppercase)
                    .tracking(1)

                Text(String(format: "$%.2f", availableBalance))
                    .font(DesignSystem.Typography.mono(42))
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.inkBlack)
            }

            Divider()
                .padding(.horizontal, DesignSystem.Spacing.lg)

            // Secondary amounts
            HStack(spacing: DesignSystem.Spacing.xl) {
                // Locked in pledges
                VStack(spacing: DesignSystem.Spacing.xxs) {
                    Text("In Pledges")
                        .font(DesignSystem.Typography.caption(12))
                        .foregroundColor(DesignSystem.Colors.inkGray)

                    Text(String(format: "$%.2f", lockedBalance))
                        .font(DesignSystem.Typography.mono(18))
                        .foregroundColor(DesignSystem.Colors.inkBlack)
                }

                // Pending (if any)
                if hasPending {
                    VStack(spacing: DesignSystem.Spacing.xxs) {
                        Text("Pending")
                            .font(DesignSystem.Typography.caption(12))
                            .foregroundColor(DesignSystem.Colors.mustard)

                        HStack(spacing: 4) {
                            if pendingDeposits > 0 {
                                Text("+$\(Int(pendingDeposits))")
                                    .font(DesignSystem.Typography.mono(14))
                                    .foregroundColor(DesignSystem.Colors.moneyGreen)
                            }
                            if pendingWithdrawals > 0 {
                                Text("-$\(Int(pendingWithdrawals))")
                                    .font(DesignSystem.Typography.mono(14))
                                    .foregroundColor(DesignSystem.Colors.alertRed)
                            }
                        }
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(maxWidth: .infinity)
        .cleanCard()
    }
}

// MARK: - Action Button Row

/// Deposit and Withdraw action buttons.
struct ActionButtonRow: View {
    let onDeposit: () -> Void
    let onWithdraw: () -> Void
    let canWithdraw: Bool

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Deposit button
            Button(action: onDeposit) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 20))
                    Text("Deposit")
                        .font(DesignSystem.Typography.button())
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.md)
                .background(DesignSystem.Colors.moneyGreen)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusButton))
            }

            // Withdraw button
            Button(action: onWithdraw) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 20))
                    Text("Withdraw")
                        .font(DesignSystem.Typography.button())
                }
                .foregroundColor(
                    canWithdraw ? DesignSystem.Colors.inkBlack : DesignSystem.Colors.inkGray
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.md)
                .background(DesignSystem.Colors.cardWhite)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusButton))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusButton)
                        .stroke(
                            canWithdraw
                                ? DesignSystem.Colors.inkBlack
                                : DesignSystem.Colors.inkGray.opacity(0.3),
                            lineWidth: DesignSystem.Borders.thickness
                        )
                )
            }
            .disabled(!canWithdraw)
        }
    }
}

// MARK: - Linked Payment Card

/// Shows linked payment method status.
struct LinkedPaymentCard: View {
    let method: PaymentMethod?
    let last4: String?
    let status: WalletStatus

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        method != nil
                            ? DesignSystem.Colors.moneyGreen.opacity(0.15)
                            : DesignSystem.Colors.inkGray.opacity(0.1)
                    )
                    .frame(width: 44, height: 44)

                Image(systemName: method?.icon ?? "creditcard")
                    .font(.system(size: 20))
                    .foregroundColor(
                        method != nil ? DesignSystem.Colors.moneyGreen : DesignSystem.Colors.inkGray
                    )
            }

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(method != nil ? "Linked Payment" : "No Payment Method")
                    .font(DesignSystem.Typography.body())
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                if let method = method {
                    HStack(spacing: 4) {
                        Text(method.displayName)
                        if let last4 = last4 {
                            Text("•••• \(last4)")
                        }
                    }
                    .font(DesignSystem.Typography.caption())
                    .foregroundColor(DesignSystem.Colors.inkGray)
                } else {
                    Text("Add a payment method to deposit funds")
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.inkGray)
                }
            }

            Spacer()

            // Status badge
            if status != .active {
                Text(status.displayText)
                    .font(DesignSystem.Typography.label(10))
                    .foregroundColor(DesignSystem.Colors.mustard)
                    .padding(.horizontal, DesignSystem.Spacing.xs)
                    .padding(.vertical, 4)
                    .background(DesignSystem.Colors.mustard.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(DesignSystem.Colors.inkGray)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Colors.cardWhite)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusCard))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusCard)
                .stroke(DesignSystem.Colors.inkBlack.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Recent Transactions Card

/// Shows recent transaction history with navigation to full list.
struct RecentTransactionsCard: View {
    let transactions: [WalletTransaction]
    let onTap: (WalletTransaction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Header
            HStack {
                Text("Recent Activity")
                    .font(DesignSystem.Typography.title(18))
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                Spacer()

                NavigationLink {
                    TransactionListView()
                } label: {
                    Text("See All")
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.moneyGreen)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.sm)

            // Transaction rows
            VStack(spacing: 0) {
                ForEach(transactions, id: \.id) { transaction in
                    Button {
                        onTap(transaction)
                    } label: {
                        TransactionRow(transaction: transaction)
                    }
                    .buttonStyle(.plain)

                    if transaction.id != transactions.last?.id {
                        Divider()
                            .padding(.leading, 60)
                    }
                }
            }
            .padding(.bottom, DesignSystem.Spacing.sm)
        }
        .background(DesignSystem.Colors.cardWhite)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusCard))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusCard)
                .stroke(DesignSystem.Colors.inkBlack.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Transaction Row

/// Single transaction row for lists.
struct TransactionRow: View {
    let transaction: WalletTransaction

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        transaction.type.isCredit
                            ? DesignSystem.Colors.moneyGreen.opacity(0.15)
                            : DesignSystem.Colors.alertRed.opacity(0.1)
                    )
                    .frame(width: 40, height: 40)

                Image(systemName: transaction.type.icon)
                    .font(.system(size: 16))
                    .foregroundColor(
                        transaction.type.isCredit
                            ? DesignSystem.Colors.moneyGreen : DesignSystem.Colors.alertRed)
            }

            // Description
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.type.displayName)
                    .font(DesignSystem.Typography.body())
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                Text(transaction.challengeName ?? transaction.shortDate)
                    .font(DesignSystem.Typography.caption(12))
                    .foregroundColor(DesignSystem.Colors.inkGray)
                    .lineLimit(1)
            }

            Spacer()

            // Amount
            VStack(alignment: .trailing, spacing: 2) {
                Text(transaction.formattedAmount)
                    .font(DesignSystem.Typography.mono(16))
                    .foregroundColor(
                        transaction.type.isCredit
                            ? DesignSystem.Colors.moneyGreen : DesignSystem.Colors.inkBlack)

                if transaction.status != .completed {
                    Text(transaction.status.displayText)
                        .font(DesignSystem.Typography.label(10))
                        .foregroundColor(DesignSystem.Colors.mustard)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

// MARK: - Empty Transactions Card

/// Shown when there are no transactions yet.
struct EmptyTransactionsCard: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 36))
                .foregroundColor(DesignSystem.Colors.inkGray.opacity(0.5))

            Text("No transactions yet")
                .font(DesignSystem.Typography.body())
                .foregroundColor(DesignSystem.Colors.inkGray)

            Text("Deposit funds to get started")
                .font(DesignSystem.Typography.caption())
                .foregroundColor(DesignSystem.Colors.lightGray)
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Colors.cardWhite)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusCard))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusCard)
                .stroke(DesignSystem.Colors.inkBlack.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Deposit Sheet

/// Action sheet for depositing funds.
struct DepositSheet: View {
    var walletManager: WalletManager
    @Environment(\.dismiss) private var dismiss
    @State private var amount: String = ""
    @State private var selectedMethod: PaymentMethod = .applePay
    @State private var isProcessing = false
    @State private var errorMessage: String?

    private let presetAmounts: [Double] = [25, 50, 100, 200]

    var body: some View {
        NavigationStack {
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Amount input
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text("Enter Amount")
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.inkGray)

                    HStack(spacing: 4) {
                        Text("$")
                            .font(DesignSystem.Typography.data(32))
                            .foregroundColor(DesignSystem.Colors.inkGray)

                        TextField("0", text: $amount)
                            .font(DesignSystem.Typography.mono(42))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .foregroundColor(DesignSystem.Colors.inkBlack)
                    }
                    .frame(maxWidth: .infinity)
                }

                // Preset amounts
                HStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(presetAmounts, id: \.self) { preset in
                        Button {
                            amount = String(Int(preset))
                        } label: {
                            Text("$\(Int(preset))")
                                .font(DesignSystem.Typography.button())
                                .foregroundColor(
                                    amount == String(Int(preset))
                                        ? .white : DesignSystem.Colors.inkBlack
                                )
                                .padding(.horizontal, DesignSystem.Spacing.md)
                                .padding(.vertical, DesignSystem.Spacing.sm)
                                .background(
                                    amount == String(Int(preset))
                                        ? DesignSystem.Colors.inkBlack
                                        : DesignSystem.Colors.background
                                )
                                .clipShape(
                                    RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusSmall)
                                )
                        }
                    }
                }

                // Error message
                if let error = errorMessage {
                    Text(error)
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.alertRed)
                }

                Spacer()

                // Deposit button
                Button {
                    Task {
                        await performDeposit()
                    }
                } label: {
                    if isProcessing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Deposit with \(selectedMethod.displayName)")
                    }
                }
                .buttonStyle(PrimaryButtonStyle(isEnabled: !amount.isEmpty && !isProcessing))
                .disabled(amount.isEmpty || isProcessing)
            }
            .padding(DesignSystem.Spacing.lg)
            .navigationTitle("Deposit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func performDeposit() async {
        guard let amountValue = Double(amount), amountValue >= 5 else {
            errorMessage = "Minimum deposit is $5"
            return
        }

        isProcessing = true
        errorMessage = nil

        do {
            try await walletManager.deposit(amount: amountValue, method: selectedMethod)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isProcessing = false
    }
}

// MARK: - Withdraw Sheet

/// Action sheet for withdrawing funds.
struct WithdrawSheet: View {
    var walletManager: WalletManager
    @Environment(\.dismiss) private var dismiss
    @State private var amount: String = ""
    @State private var isProcessing = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Available balance reminder
                HStack {
                    Text("Available:")
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.inkGray)

                    Text(walletManager.formattedBalance)
                        .font(DesignSystem.Typography.mono(16))
                        .foregroundColor(DesignSystem.Colors.moneyGreen)
                }

                // Amount input
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text("Withdraw Amount")
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.inkGray)

                    HStack(spacing: 4) {
                        Text("$")
                            .font(DesignSystem.Typography.data(32))
                            .foregroundColor(DesignSystem.Colors.inkGray)

                        TextField("0", text: $amount)
                            .font(DesignSystem.Typography.mono(42))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .foregroundColor(DesignSystem.Colors.inkBlack)
                    }
                    .frame(maxWidth: .infinity)
                }

                // Max button
                Button {
                    amount = String(Int(walletManager.availableBalance))
                } label: {
                    Text("Withdraw Max")
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.moneyGreen)
                }

                // Error message
                if let error = errorMessage {
                    Text(error)
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.alertRed)
                }

                Spacer()

                // Processing time note
                Text("Withdrawals typically take 1-3 business days")
                    .font(DesignSystem.Typography.caption(12))
                    .foregroundColor(DesignSystem.Colors.inkGray)

                // Withdraw button
                Button {
                    Task {
                        await performWithdraw()
                    }
                } label: {
                    if isProcessing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Request Withdrawal")
                    }
                }
                .buttonStyle(PrimaryButtonStyle(isEnabled: !amount.isEmpty && !isProcessing))
                .disabled(amount.isEmpty || isProcessing)
            }
            .padding(DesignSystem.Spacing.lg)
            .navigationTitle("Withdraw")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func performWithdraw() async {
        guard let amountValue = Double(amount), amountValue >= 10 else {
            errorMessage = "Minimum withdrawal is $10"
            return
        }

        isProcessing = true
        errorMessage = nil

        do {
            try await walletManager.withdraw(amount: amountValue)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isProcessing = false
    }
}

// Note: WalletTransaction is already Identifiable via @Model

// MARK: - Previews

#Preview("Wallet View") {
    NavigationStack {
        WalletView()
    }
}

#Preview("Balance Card") {
    BalanceCard(
        availableBalance: 125.00,
        lockedBalance: 50.00,
        pendingDeposits: 0,
        pendingWithdrawals: 0
    )
    .padding()
    .background(DesignSystem.Colors.background)
}

#Preview("Balance Card - Pending") {
    BalanceCard(
        availableBalance: 75.50,
        lockedBalance: 100.00,
        pendingDeposits: 50.00,
        pendingWithdrawals: 25.00
    )
    .padding()
    .background(DesignSystem.Colors.background)
}

#Preview("Transaction Row") {
    VStack {
        TransactionRow(transaction: WalletTransaction.mockDeposit())
        Divider()
        TransactionRow(transaction: WalletTransaction.mockStake())
        Divider()
        TransactionRow(transaction: WalletTransaction.mockPayout())
    }
    .background(DesignSystem.Colors.cardWhite)
}
