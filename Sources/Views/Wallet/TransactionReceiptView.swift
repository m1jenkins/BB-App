//
//  TransactionReceiptView.swift
//  BetterBet
//
//  Receipt-style detail view for a single transaction.
//  "Every money event shows: Amount + Status, From/To, Challenge reference,
//   Timestamp + Fee disclosure, Support link"
//

import SwiftUI

// MARK: - Transaction Receipt View

/// Receipt-style detail view following DESIGN_SYSTEM.md spec.
struct TransactionReceiptView: View {
    let transaction: WalletTransaction
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // Receipt Card
                        ReceiptCard(transaction: transaction)

                        // Details Section
                        DetailsSection(transaction: transaction)

                        // Support Link
                        SupportButton()

                        Spacer()
                            .frame(height: DesignSystem.Spacing.xl)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.top, DesignSystem.Spacing.md)
                }
            }
            .navigationTitle("Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Receipt Card

/// Main receipt display with amount and status.
struct ReceiptCard: View {
    let transaction: WalletTransaction

    var statusColor: Color {
        switch transaction.status {
        case .completed: return DesignSystem.Colors.moneyGreen
        case .pending, .processing: return DesignSystem.Colors.mustard
        case .failed, .cancelled: return DesignSystem.Colors.alertRed
        }
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        transaction.type.isCredit
                            ? DesignSystem.Colors.moneyGreen.opacity(0.15)
                            : DesignSystem.Colors.alertRed.opacity(0.1)
                    )
                    .frame(width: 64, height: 64)

                Image(systemName: transaction.type.icon)
                    .font(.system(size: 28))
                    .foregroundColor(
                        transaction.type.isCredit
                            ? DesignSystem.Colors.moneyGreen : DesignSystem.Colors.alertRed)
            }

            // Type label
            Text(transaction.type.displayName)
                .font(DesignSystem.Typography.caption())
                .foregroundColor(DesignSystem.Colors.inkGray)
                .textCase(.uppercase)
                .tracking(1)

            // Amount
            Text(transaction.formattedAmount)
                .font(DesignSystem.Typography.mono(48))
                .fontWeight(.bold)
                .foregroundColor(
                    transaction.type.isCredit
                        ? DesignSystem.Colors.moneyGreen : DesignSystem.Colors.inkBlack)

            // Status badge
            HStack(spacing: 6) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)

                Text(transaction.status.displayText)
                    .font(DesignSystem.Typography.label())
                    .foregroundColor(statusColor)
            }
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xxs)
            .background(statusColor.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusPill))
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

// MARK: - Details Section

/// Transaction details grid.
struct DetailsSection: View {
    let transaction: WalletTransaction

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Text("Details")
                .font(DesignSystem.Typography.title(16))
                .foregroundColor(DesignSystem.Colors.inkBlack)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.sm)

            // Details card
            VStack(spacing: 0) {
                // Date & Time
                DetailRow(label: "Date & Time", value: transaction.formattedDate)

                Divider()

                // Transaction type description
                DetailRow(label: "Description", value: transaction.type.description)

                // Challenge reference (if applicable)
                if let challengeName = transaction.challengeName {
                    Divider()
                    DetailRow(label: "Challenge", value: challengeName)
                }

                // Counterparty (if applicable)
                if let counterparty = transaction.counterpartyName {
                    Divider()
                    DetailRow(label: "From/To", value: counterparty)
                }

                // Fee disclosure
                Divider()
                DetailRow(
                    label: "Fee",
                    value: transaction.formattedFee,
                    valueColor: transaction.fee > 0
                        ? DesignSystem.Colors.alertRed : DesignSystem.Colors.inkGray
                )

                // Transaction ID (truncated)
                Divider()
                DetailRow(
                    label: "Reference",
                    value: String(transaction.id.uuidString.prefix(8)).uppercased())
            }
            .background(DesignSystem.Colors.cardWhite)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusCard))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusCard)
                    .stroke(DesignSystem.Colors.inkBlack.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let label: String
    let value: String
    var valueColor: Color = DesignSystem.Colors.inkBlack

    var body: some View {
        HStack {
            Text(label)
                .font(DesignSystem.Typography.caption())
                .foregroundColor(DesignSystem.Colors.inkGray)

            Spacer()

            Text(value)
                .font(DesignSystem.Typography.body())
                .foregroundColor(valueColor)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

// MARK: - Support Button

struct SupportButton: View {
    var body: some View {
        Button {
            // Open support
        } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 16))

                Text("Need help with this transaction?")
                    .font(DesignSystem.Typography.caption())
            }
            .foregroundColor(DesignSystem.Colors.inkGray)
        }
    }
}

// MARK: - Previews

#Preview("Receipt - Deposit") {
    TransactionReceiptView(transaction: WalletTransaction.mockDeposit())
}

#Preview("Receipt - Payout") {
    TransactionReceiptView(transaction: WalletTransaction.mockPayout())
}

#Preview("Receipt - Pending") {
    TransactionReceiptView(transaction: WalletTransaction.mockPendingWithdrawal())
}
