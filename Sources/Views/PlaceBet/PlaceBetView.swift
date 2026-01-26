//
//  PlaceBetView.swift
//  BetterBet
//
//  "Place Bet" screen built with Industrial Pop design tokens.
//  No hardcoded hex values - all styling from IndustrialPopDesignSystem.swift
//
//  SEMANTIC FIREWALL NOTICE:
//  This is internally named "PlaceBet" but UI text uses approved terminology:
//  "Pledge", "Stake", "Commitment", "Collateral", "Contract"
//

import SwiftUI

// MARK: - Place Bet View (Main Screen)

/// The main "Place Bet" screen using Industrial Pop design system.
/// Internal name uses "Bet" but all UI shows commitment contract terminology.
struct PlaceBetView: View {
    @State private var collateralAmount: String = "25"
    @State private var isEditing = false
    @Environment(\.dismiss) private var dismiss

    // Mock data for peers
    private let peers = [
        Peer(name: "Marcus K.", avatarName: "person.fill"),
        Peer(name: "Sarah L.", avatarName: "person.fill"),
        Peer(name: "Jake M.", avatarName: "person.fill"),
        Peer(name: "Emma R.", avatarName: "person.fill"),
    ]

    var body: some View {
        IndustrialLayoutWrapper {
            VStack(spacing: 0) {
                // Navigation Header
                IndustrialNav(contractTitle: "MARCH MADNESS") {
                    dismiss()
                }

                ScrollView {
                    VStack(spacing: IndustrialPop.Spacing.lg) {
                        // Collateral Input Section
                        CollateralInputSection(
                            amount: $collateralAmount,
                            isEditing: $isEditing
                        )

                        // Terms Receipt Card
                        TermsReceiptCard()

                        // Peer Pressure Section
                        PeerPressureSection(peers: peers)

                        // Sign & Commit Button
                        Button("SIGN & COMMIT") {
                            // Handle commitment action
                        }
                        .buttonStyle(.industrial)
                        .padding(.horizontal, IndustrialPop.Spacing.md)
                        .padding(.bottom, IndustrialPop.Spacing.xl)
                    }
                    .padding(.top, IndustrialPop.Spacing.lg)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Collateral Input Section

/// Massive currency input with yellow underline.
/// Uses design tokens for all styling.
struct CollateralInputSection: View {
    @Binding var amount: String
    @Binding var isEditing: Bool
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: IndustrialPop.Spacing.sm) {
            // Label
            Text("YOUR COLLATERAL")
                .font(IndustrialPop.Typography.nav())
                .foregroundColor(IndustrialPop.Colors.textMuted)
                .tracking(2)

            // Currency Input with Yellow Underline
            VStack(spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("$")
                        .font(IndustrialPop.Typography.currency(48))
                        .foregroundColor(IndustrialPop.Colors.textStrong)

                    TextField("0", text: $amount)
                        .font(IndustrialPop.Typography.currency())
                        .foregroundColor(IndustrialPop.Colors.textStrong)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.plain)
                        .focused($isFocused)
                        .frame(minWidth: 120)
                        .fixedSize()
                }
                .padding(.bottom, IndustrialPop.Spacing.xs)

                // Yellow underline (4px thick)
                Rectangle()
                    .fill(IndustrialPop.Colors.brandAccent)
                    .frame(height: IndustrialPop.Borders.inputUnderline)
                    .frame(maxWidth: 200)
            }

            // Helper text
            Text("MIN: $5 • MAX: $500")
                .font(IndustrialPop.Typography.caption())
                .foregroundColor(IndustrialPop.Colors.textMuted)
                .padding(.top, IndustrialPop.Spacing.xs)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, IndustrialPop.Spacing.xl)
    }
}

// MARK: - Terms Receipt Card

/// Contract details in a "receipt card" with zigzag torn edge.
struct TermsReceiptCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("TERMS OF AGREEMENT")
                    .font(IndustrialPop.Typography.title(14))
                    .foregroundColor(IndustrialPop.Colors.textStrong)

                Spacer()

                Text("CONTRACT #2847")
                    .font(IndustrialPop.Typography.caption())
                    .foregroundColor(IndustrialPop.Colors.textMuted)
            }
            .padding(.bottom, IndustrialPop.Spacing.md)

            // Divider
            Rectangle()
                .fill(IndustrialPop.Colors.textStrong)
                .frame(height: 1)
                .padding(.bottom, IndustrialPop.Spacing.md)

            // Term Items
            VStack(spacing: IndustrialPop.Spacing.sm) {
                TermRow(label: "CHALLENGE TYPE", value: "STEP SHOWDOWN")
                TermRow(label: "DURATION", value: "7 DAYS")
                TermRow(label: "DAILY GOAL", value: "10,000 STEPS")
                TermRow(label: "PARTICIPANTS", value: "4 / 6")
                TermRow(label: "CURRENT POT", value: "$100", isHighlighted: true)
            }
            .padding(.bottom, IndustrialPop.Spacing.lg)

            // Dotted separator line
            HStack(spacing: 4) {
                ForEach(0..<30, id: \.self) { _ in
                    Rectangle()
                        .fill(IndustrialPop.Colors.textMuted)
                        .frame(width: 6, height: 1)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, IndustrialPop.Spacing.sm)

            // Disclaimer
            Text(
                "BY SIGNING, YOU AGREE TO FORFEIT YOUR COLLATERAL IF YOU FAIL TO MEET THE DAILY GOAL."
            )
            .font(IndustrialPop.Typography.caption())
            .foregroundColor(IndustrialPop.Colors.textMuted)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.bottom, IndustrialPop.Spacing.md)
        }
        .padding(IndustrialPop.Spacing.md)
        .padding(.bottom, IndustrialPop.Spacing.sm)  // Extra padding for zigzag
        .background(IndustrialPop.Colors.surfaceCard)
        .clipShape(ZigzagEdge(teethCount: 16, teethHeight: 10))
        .overlay(
            ZigzagEdge(teethCount: 16, teethHeight: 10)
                .stroke(IndustrialPop.Colors.textStrong, lineWidth: IndustrialPop.Borders.thick)
        )
        .background(
            ZigzagEdge(teethCount: 16, teethHeight: 10)
                .fill(IndustrialPop.Colors.textStrong)
                .offset(x: 4, y: 4)
        )
        .padding(.horizontal, IndustrialPop.Spacing.md)
    }
}

/// Single row in the terms receipt
struct TermRow: View {
    let label: String
    let value: String
    var isHighlighted: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(IndustrialPop.Typography.caption())
                .foregroundColor(IndustrialPop.Colors.textMuted)

            Spacer()

            // Dotted line filler
            GeometryReader { geo in
                Path { path in
                    let dotSpacing: CGFloat = 4
                    var x: CGFloat = 0
                    while x < geo.size.width {
                        path.addRect(CGRect(x: x, y: geo.size.height / 2, width: 1, height: 1))
                        x += dotSpacing
                    }
                }
                .fill(IndustrialPop.Colors.textMuted.opacity(0.5))
            }
            .frame(height: 16)
            .padding(.horizontal, IndustrialPop.Spacing.xs)

            Text(value)
                .font(IndustrialPop.Typography.data(14))
                .foregroundColor(IndustrialPop.Colors.textStrong)
                .padding(.horizontal, isHighlighted ? IndustrialPop.Spacing.xs : 0)
                .padding(.vertical, isHighlighted ? 2 : 0)
                .background(
                    isHighlighted ? IndustrialPop.Colors.brandAccent : Color.clear
                )
        }
    }
}

// MARK: - Peer Pressure Section

/// Grid of dithered B&W avatars showing who's already committed.
struct PeerPressureSection: View {
    let peers: [Peer]

    var body: some View {
        VStack(alignment: .leading, spacing: IndustrialPop.Spacing.md) {
            // Header
            HStack {
                Text("PEER PRESSURE")
                    .font(IndustrialPop.Typography.title(14))
                    .foregroundColor(IndustrialPop.Colors.textStrong)

                Spacer()

                Text("\(peers.count) COMMITTED")
                    .font(IndustrialPop.Typography.caption())
                    .foregroundColor(IndustrialPop.Colors.textMuted)
            }

            // Avatar Grid
            HStack(spacing: IndustrialPop.Spacing.md) {
                ForEach(peers) { peer in
                    DitheredAvatarView(peer: peer)
                }

                // Add more slot
                VStack(spacing: IndustrialPop.Spacing.xxs) {
                    ZStack {
                        Rectangle()
                            .fill(IndustrialPop.Colors.surfaceMain)
                            .frame(width: 56, height: 56)
                            .overlay(
                                Rectangle()
                                    .stroke(
                                        IndustrialPop.Colors.textStrong,
                                        style: StrokeStyle(lineWidth: 2, dash: [4])
                                    )
                            )

                        Text("+")
                            .font(IndustrialPop.Typography.headline(24))
                            .foregroundColor(IndustrialPop.Colors.textMuted)
                    }

                    Text("INVITE")
                        .font(IndustrialPop.Typography.caption(10))
                        .foregroundColor(IndustrialPop.Colors.textMuted)
                }
            }
        }
        .padding(.horizontal, IndustrialPop.Spacing.md)
    }
}

// MARK: - Dithered Avatar View

/// B&W high-contrast avatar with thick black border.
struct DitheredAvatarView: View {
    let peer: Peer

    var body: some View {
        VStack(spacing: IndustrialPop.Spacing.xxs) {
            ZStack {
                // Avatar placeholder with dithered effect
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.gray.opacity(0.3),
                                Color.gray.opacity(0.6),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                // Dithered pattern overlay (halftone effect)
                DitherPatternView()
                    .frame(width: 56, height: 56)

                // Icon
                Image(systemName: peer.avatarName)
                    .font(.system(size: 28))
                    .foregroundColor(IndustrialPop.Colors.textStrong)
            }
            .overlay(
                Rectangle()
                    .stroke(IndustrialPop.Colors.textStrong, lineWidth: IndustrialPop.Borders.thick)
            )

            // Name label
            Text(peer.name.uppercased())
                .font(IndustrialPop.Typography.caption(10))
                .foregroundColor(IndustrialPop.Colors.textStrong)
                .lineLimit(1)
        }
    }
}

/// Halftone/dither pattern overlay
struct DitherPatternView: View {
    var body: some View {
        Canvas { context, size in
            let dotSize: CGFloat = 2
            let spacing: CGFloat = 4

            for row in stride(from: 0, to: size.height, by: spacing) {
                for col in stride(from: 0, to: size.width, by: spacing) {
                    // Alternate dots for halftone effect
                    let shouldDraw = (Int(row / spacing) + Int(col / spacing)) % 2 == 0
                    if shouldDraw {
                        let rect = CGRect(x: col, y: row, width: dotSize, height: dotSize)
                        context.fill(
                            Path(ellipseIn: rect),
                            with: .color(IndustrialPop.Colors.textStrong.opacity(0.15))
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Peer Model

struct Peer: Identifiable {
    let id = UUID()
    let name: String
    let avatarName: String
}

// MARK: - Preview

#Preview("Place Bet View") {
    PlaceBetView()
}

#Preview("Collateral Input") {
    IndustrialLayoutWrapper {
        CollateralInputSection(
            amount: .constant("50"),
            isEditing: .constant(false)
        )
    }
}

#Preview("Terms Receipt Card") {
    IndustrialLayoutWrapper {
        TermsReceiptCard()
            .padding()
    }
}

#Preview("Peer Pressure Section") {
    IndustrialLayoutWrapper {
        PeerPressureSection(peers: [
            Peer(name: "Marcus K.", avatarName: "person.fill"),
            Peer(name: "Sarah L.", avatarName: "person.fill"),
            Peer(name: "Jake M.", avatarName: "person.fill"),
        ])
        .padding()
    }
}
