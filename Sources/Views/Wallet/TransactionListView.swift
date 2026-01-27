//
//  TransactionListView.swift
//  BetterBet
//
//  Full transaction history view with filtering and grouping.
//

import SwiftUI

// MARK: - Transaction List View

/// Full transaction history with filtering options.
struct TransactionListView: View {
    @State private var walletManager = WalletManager.preview
    @State private var selectedFilter: TransactionFilter = .all
    @State private var selectedTransaction: WalletTransaction?

    var filteredTransactions: [WalletTransaction] {
        switch selectedFilter {
        case .all:
            return walletManager.transactions
        case .deposits:
            return walletManager.transactions.filter { $0.type == .deposit }
        case .withdrawals:
            return walletManager.transactions.filter { $0.type == .withdrawal }
        case .stakes:
            return walletManager.transactions.filter {
                $0.type == .stakeIn || $0.type == .stakeReturn || $0.type == .payout
                    || $0.type == .forfeit
            }
        }
    }

    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Filter bar
                FilterBar(selectedFilter: $selectedFilter)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.sm)

                if filteredTransactions.isEmpty {
                    Spacer()
                    EmptyStateView(filter: selectedFilter)
                    Spacer()
                } else {
                    // Transaction list
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                            ForEach(walletManager.groupedTransactions, id: \.0) {
                                dateGroup, transactions in
                                let filteredInGroup = transactions.filter { transaction in
                                    switch selectedFilter {
                                    case .all: return true
                                    case .deposits: return transaction.type == .deposit
                                    case .withdrawals: return transaction.type == .withdrawal
                                    case .stakes:
                                        return transaction.type == .stakeIn
                                            || transaction.type == .stakeReturn
                                            || transaction.type == .payout
                                            || transaction.type == .forfeit
                                    }
                                }

                                if !filteredInGroup.isEmpty {
                                    Section {
                                        VStack(spacing: 0) {
                                            ForEach(filteredInGroup, id: \.id) { transaction in
                                                Button {
                                                    selectedTransaction = transaction
                                                } label: {
                                                    TransactionRow(transaction: transaction)
                                                }
                                                .buttonStyle(.plain)

                                                if transaction.id != filteredInGroup.last?.id {
                                                    Divider()
                                                        .padding(.leading, 60)
                                                }
                                            }
                                        }
                                        .background(DesignSystem.Colors.cardWhite)
                                    } header: {
                                        DateHeader(title: dateGroup)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.bottom, DesignSystem.Spacing.xl)
                    }
                }
            }
        }
        .navigationTitle("All Activity")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedTransaction) { transaction in
            TransactionReceiptView(transaction: transaction)
                .presentationDetents([.medium, .large])
        }
    }
}

// MARK: - Transaction Filter

enum TransactionFilter: String, CaseIterable {
    case all = "All"
    case deposits = "Deposits"
    case withdrawals = "Withdrawals"
    case stakes = "Stakes"

    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .deposits: return "arrow.down.circle"
        case .withdrawals: return "arrow.up.circle"
        case .stakes: return "lock.fill"
        }
    }
}

// MARK: - Filter Bar

struct FilterBar: View {
    @Binding var selectedFilter: TransactionFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(TransactionFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        icon: filter.icon,
                        isSelected: selectedFilter == filter,
                        action: { selectedFilter = filter }
                    )
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(DesignSystem.Typography.label())
            }
            .foregroundColor(isSelected ? .white : DesignSystem.Colors.inkBlack)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(isSelected ? DesignSystem.Colors.inkBlack : DesignSystem.Colors.cardWhite)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusPill))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusPill)
                    .stroke(
                        isSelected ? Color.clear : DesignSystem.Colors.inkBlack.opacity(0.2),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Date Header

struct DateHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(DesignSystem.Typography.caption())
                .foregroundColor(DesignSystem.Colors.inkGray)
                .textCase(.uppercase)
                .tracking(1)

            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(DesignSystem.Colors.background)
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let filter: TransactionFilter

    var message: String {
        switch filter {
        case .all: return "No transactions yet"
        case .deposits: return "No deposits yet"
        case .withdrawals: return "No withdrawals yet"
        case .stakes: return "No stake transactions yet"
        }
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(DesignSystem.Colors.inkGray.opacity(0.5))

            Text(message)
                .font(DesignSystem.Typography.body())
                .foregroundColor(DesignSystem.Colors.inkGray)
        }
    }
}

// MARK: - Previews

#Preview("Transaction List") {
    NavigationStack {
        TransactionListView()
    }
}
