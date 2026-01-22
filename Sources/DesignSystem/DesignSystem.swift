//
//  DesignSystem.swift
//  BetterBet
//
//  "Clean Athletic" Design System - Phase 2
//  Vibe: Strava meets Nike Run Club - Clean, legible, high-contrast
//
//  SEMANTIC FIREWALL NOTICE:
//  This app uses commitment contract terminology, NOT gambling terms.
//  Approved: "Pledge", "Stake", "Commitment", "Pot", "Challenge"
//  Forbidden: "Bet", "Wager", "Gamble", "Win", "Lose" (use "Succeed"/"Fail")
//

import SwiftUI

// MARK: - Design System Namespace

/// Central namespace for all design tokens in the Better Bet app.
/// Phase 2: "Clean Athletic" aesthetic - legible, modern, high-contrast.
enum DesignSystem {

    // MARK: - Color Palette

    enum Colors {
        /// Primary app background - Warm cream (#F9F7F1)
        static let background = Color(hex: "F9F7F1")

        /// Primary text, borders, icons - Near black (#050505)
        static let inkBlack = Color(hex: "050505")

        /// Accent color for highlights (#F4D03F)
        static let mustard = Color(hex: "F4D03F")

        /// Failed states, warnings, elimination indicators (#FF453A)
        static let alertRed = Color(hex: "FF453A")

        /// Pot values, success states, money indicators (#00A86B)
        static let moneyGreen = Color(hex: "00A86B")

        /// Secondary text, disabled states
        static let inkGray = Color(hex: "6B6B6B")

        /// Tertiary text, hints
        static let lightGray = Color(hex: "9B9B9B")

        /// Card/component backgrounds - Pure white
        static let cardWhite = Color.white

        /// Subtle shadow color
        static let shadowColor = Color.black.opacity(0.1)
    }

    // MARK: - Typography

    enum Typography {
        /// Large display headlines - Cooper Black style (serif black)
        /// Used sparingly for impact
        static func headline(_ size: CGFloat = 32) -> Font {
            .system(size: size, weight: .black, design: .serif)
        }

        /// Section titles - Bold condensed feel
        static func title(_ size: CGFloat = 22) -> Font {
            .system(size: size, weight: .bold, design: .default)
        }

        /// Data display - Condensed, athletic look (SF Pro style)
        static func data(_ size: CGFloat = 28) -> Font {
            .system(size: size, weight: .semibold, design: .default)
        }

        /// Primary body text - Clean sans-serif
        static func body(_ size: CGFloat = 16) -> Font {
            .system(size: size, weight: .medium, design: .default)
        }

        /// Secondary text, captions
        static func caption(_ size: CGFloat = 14) -> Font {
            .system(size: size, weight: .regular, design: .default)
        }

        /// Button labels - Bold and clear
        static func button(_ size: CGFloat = 17) -> Font {
            .system(size: size, weight: .semibold, design: .default)
        }

        /// Monospace for numbers/stats - Tabular figures
        static func mono(_ size: CGFloat = 16) -> Font {
            .system(size: size, weight: .medium, design: .monospaced)
        }

        /// Small labels, tags
        static func label(_ size: CGFloat = 12) -> Font {
            .system(size: size, weight: .semibold, design: .default)
        }
    }

    // MARK: - Spacing & Layout

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Border & Radius Constants (Clean Athletic Style)

    enum Borders {
        /// Clean single border - 2px solid black
        static let thickness: CGFloat = 2

        /// Card corner radius - tactile but not sharp
        static let radiusCard: CGFloat = 12

        /// Button corner radius
        static let radiusButton: CGFloat = 12

        /// Medium elements (icons, containers)
        static let radiusMedium: CGFloat = 10

        /// Small elements (tags, badges)
        static let radiusSmall: CGFloat = 8

        /// Pill shape for specific elements
        static let radiusPill: CGFloat = 100
    }

    // MARK: - Shadows (Subtle, not brutal)

    enum Shadows {
        /// Standard card shadow - subtle depth
        static let cardShadow = Shadow(
            color: Color.black.opacity(0.08),
            radius: 8,
            x: 0,
            y: 4
        )

        /// Elevated element shadow
        static let elevatedShadow = Shadow(
            color: Color.black.opacity(0.12),
            radius: 12,
            x: 0,
            y: 6
        )

        /// Pressed/active state shadow
        static let pressedShadow = Shadow(
            color: Color.black.opacity(0.04),
            radius: 2,
            x: 0,
            y: 1
        )
    }

    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - Color Hex Extension

extension Color {
    /// Initialize a Color from a hex string (without #)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Clean Card Modifier

/// Clean Athletic card style - white background, 2px border, subtle shadow
struct CleanCardModifier: ViewModifier {
    var hasBorder: Bool
    var cornerRadius: CGFloat

    init(hasBorder: Bool = true, cornerRadius: CGFloat = DesignSystem.Borders.radiusCard) {
        self.hasBorder = hasBorder
        self.cornerRadius = cornerRadius
    }

    func body(content: Content) -> some View {
        content
            .background(DesignSystem.Colors.cardWhite)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        hasBorder ? DesignSystem.Colors.inkBlack : Color.clear,
                        lineWidth: DesignSystem.Borders.thickness
                    )
            )
            .shadow(
                color: DesignSystem.Shadows.cardShadow.color,
                radius: DesignSystem.Shadows.cardShadow.radius,
                x: DesignSystem.Shadows.cardShadow.x,
                y: DesignSystem.Shadows.cardShadow.y
            )
    }
}

// MARK: - View Extensions

extension View {
    /// Apply clean card style with 2px black border and subtle shadow
    func cleanCard(hasBorder: Bool = true, cornerRadius: CGFloat = DesignSystem.Borders.radiusCard) -> some View {
        modifier(CleanCardModifier(hasBorder: hasBorder, cornerRadius: cornerRadius))
    }

    /// Apply subtle shadow only (no border)
    func subtleShadow() -> some View {
        self.shadow(
            color: DesignSystem.Shadows.cardShadow.color,
            radius: DesignSystem.Shadows.cardShadow.radius,
            x: DesignSystem.Shadows.cardShadow.x,
            y: DesignSystem.Shadows.cardShadow.y
        )
    }

    /// Apply elevated shadow for floating elements
    func elevatedShadow() -> some View {
        self.shadow(
            color: DesignSystem.Shadows.elevatedShadow.color,
            radius: DesignSystem.Shadows.elevatedShadow.radius,
            x: DesignSystem.Shadows.elevatedShadow.x,
            y: DesignSystem.Shadows.elevatedShadow.y
        )
    }
}

// MARK: - Primary Button Style (Black fill, white text)

/// Primary CTA button - "Lock It In" style
struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool

    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.button())
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(isEnabled ? DesignSystem.Colors.inkBlack : DesignSystem.Colors.inkGray)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusButton))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Secondary button - outline style
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.button())
            .foregroundColor(DesignSystem.Colors.inkBlack)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(DesignSystem.Colors.cardWhite)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusButton))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusButton)
                    .stroke(DesignSystem.Colors.inkBlack, lineWidth: DesignSystem.Borders.thickness)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Destructive button - red fill
struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.button())
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(DesignSystem.Colors.alertRed)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusButton))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Button Style Extensions

extension ButtonStyle where Self == PrimaryButtonStyle {
    /// Primary black button - "Lock It In"
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }

    /// Disabled primary button
    static var primaryDisabled: PrimaryButtonStyle { PrimaryButtonStyle(isEnabled: false) }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    /// Secondary outline button
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}

extension ButtonStyle where Self == DestructiveButtonStyle {
    /// Destructive red button
    static var destructive: DestructiveButtonStyle { DestructiveButtonStyle() }
}

// MARK: - Progress Bar (Clean Style)

/// Clean progress bar with 2px border
struct ProgressBar: View {
    var progress: Double // 0.0 to 1.0
    var fillColor: Color
    var height: CGFloat
    var showBorder: Bool

    init(
        progress: Double,
        fillColor: Color = DesignSystem.Colors.moneyGreen,
        height: CGFloat = 12,
        showBorder: Bool = true
    ) {
        self.progress = min(max(progress, 0), 1)
        self.fillColor = fillColor
        self.height = height
        self.showBorder = showBorder
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(DesignSystem.Colors.background)

                // Fill bar
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(fillColor)
                    .frame(width: max(geometry.size.width * progress, height))

                // Border overlay
                if showBorder {
                    RoundedRectangle(cornerRadius: height / 2)
                        .stroke(DesignSystem.Colors.inkBlack, lineWidth: DesignSystem.Borders.thickness)
                }
            }
        }
        .frame(height: height)
    }
}

// MARK: - Pot Badge (Clean Circle Style)

/// Clean circular badge for pot display
struct PotBadge: View {
    let amount: Double
    var size: CGFloat

    init(amount: Double, size: CGFloat = 80) {
        self.amount = amount
        self.size = size
    }

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(DesignSystem.Colors.moneyGreen)
                .frame(width: size, height: size)

            // Border
            Circle()
                .stroke(DesignSystem.Colors.inkBlack, lineWidth: DesignSystem.Borders.thickness)
                .frame(width: size, height: size)

            // Amount display
            VStack(spacing: -2) {
                Text("POT")
                    .font(DesignSystem.Typography.label(10))
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.8))

                Text("$\(Int(amount))")
                    .font(DesignSystem.Typography.data(size * 0.28))
                    .foregroundColor(.white)
            }
        }
        .subtleShadow()
    }
}

// MARK: - Status Badge

/// Clean status badge for challenge states
struct StatusBadge: View {
    let status: ChallengeStatus
    var size: BadgeSize

    enum BadgeSize {
        case small, medium

        var fontSize: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 12
            }
        }

        var padding: CGFloat {
            switch self {
            case .small: return 6
            case .medium: return 8
            }
        }
    }

    init(status: ChallengeStatus, size: BadgeSize = .medium) {
        self.status = status
        self.size = size
    }

    var body: some View {
        Text(status.text)
            .font(DesignSystem.Typography.label(size.fontSize))
            .foregroundColor(status.textColor)
            .padding(.horizontal, size.padding)
            .padding(.vertical, size.padding / 2)
            .background(status.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusSmall))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusSmall)
                    .stroke(status.borderColor, lineWidth: 1.5)
            )
    }
}

enum ChallengeStatus {
    case onTrack
    case atRisk
    case failed
    case completed

    var text: String {
        switch self {
        case .onTrack: return "ON TRACK"
        case .atRisk: return "AT RISK"
        case .failed: return "FAILED"
        case .completed: return "COMPLETE"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .onTrack: return DesignSystem.Colors.moneyGreen.opacity(0.15)
        case .atRisk: return DesignSystem.Colors.mustard.opacity(0.15)
        case .failed: return DesignSystem.Colors.alertRed.opacity(0.15)
        case .completed: return DesignSystem.Colors.moneyGreen.opacity(0.15)
        }
    }

    var textColor: Color {
        switch self {
        case .onTrack: return DesignSystem.Colors.moneyGreen
        case .atRisk: return Color(hex: "B8860B") // Darker mustard
        case .failed: return DesignSystem.Colors.alertRed
        case .completed: return DesignSystem.Colors.moneyGreen
        }
    }

    var borderColor: Color {
        switch self {
        case .onTrack: return DesignSystem.Colors.moneyGreen.opacity(0.3)
        case .atRisk: return DesignSystem.Colors.mustard.opacity(0.3)
        case .failed: return DesignSystem.Colors.alertRed.opacity(0.3)
        case .completed: return DesignSystem.Colors.moneyGreen.opacity(0.3)
        }
    }
}

// MARK: - Challenge Mode Card

/// Selection card for challenge types
struct ChallengeModeCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? DesignSystem.Colors.inkBlack : DesignSystem.Colors.background)
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .white : DesignSystem.Colors.inkBlack)
                }

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DesignSystem.Typography.body())
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.inkBlack)

                    Text(subtitle)
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.inkGray)
                }

                Spacer()

                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(DesignSystem.Colors.moneyGreen)
                }
            }
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.cardWhite)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusCard))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusCard)
                    .stroke(
                        isSelected ? DesignSystem.Colors.inkBlack : DesignSystem.Colors.inkBlack.opacity(0.2),
                        lineWidth: isSelected ? DesignSystem.Borders.thickness : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stake Selector

/// Pill selector for stake amounts
struct StakeSelector: View {
    @Binding var selectedAmount: Double
    let amounts: [Double]

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(amounts, id: \.self) { amount in
                StakePill(
                    amount: amount,
                    isSelected: selectedAmount == amount,
                    action: { selectedAmount = amount }
                )
            }
        }
    }
}

struct StakePill: View {
    let amount: Double
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("$\(Int(amount))")
                .font(DesignSystem.Typography.button())
                .foregroundColor(isSelected ? .white : DesignSystem.Colors.inkBlack)
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(isSelected ? DesignSystem.Colors.inkBlack : DesignSystem.Colors.cardWhite)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusButton))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusButton)
                        .stroke(DesignSystem.Colors.inkBlack, lineWidth: DesignSystem.Borders.thickness)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview Provider

#Preview("Clean Athletic Design System") {
    ScrollView {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Header
            Text("Clean Athletic")
                .font(DesignSystem.Typography.headline(28))
                .foregroundColor(DesignSystem.Colors.inkBlack)

            // Colors
            HStack(spacing: DesignSystem.Spacing.sm) {
                colorSwatch(DesignSystem.Colors.background, "BG")
                colorSwatch(DesignSystem.Colors.inkBlack, "Ink")
                colorSwatch(DesignSystem.Colors.mustard, "Accent")
                colorSwatch(DesignSystem.Colors.alertRed, "Alert")
                colorSwatch(DesignSystem.Colors.moneyGreen, "Money")
            }

            Divider()

            // Clean Card
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("Clean Card Style")
                    .font(DesignSystem.Typography.title())
                Text("2px border, 12px radius, subtle shadow")
                    .font(DesignSystem.Typography.caption())
                    .foregroundColor(DesignSystem.Colors.inkGray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignSystem.Spacing.md)
            .cleanCard()

            // Buttons
            VStack(spacing: DesignSystem.Spacing.sm) {
                Button("Lock It In") {}
                    .buttonStyle(.primary)

                Button("Cancel") {}
                    .buttonStyle(.secondary)
            }
            .padding(.horizontal)

            // Progress Bar
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("Progress: 72%")
                    .font(DesignSystem.Typography.caption())
                ProgressBar(progress: 0.72)
            }
            .padding(.horizontal)

            // Pot Badge
            PotBadge(amount: 150)

            // Status Badges
            HStack(spacing: DesignSystem.Spacing.sm) {
                StatusBadge(status: .onTrack)
                StatusBadge(status: .atRisk)
                StatusBadge(status: .failed)
            }

            // Challenge Mode Card
            ChallengeModeCard(
                icon: "figure.walk",
                title: "Step Survivor",
                subtitle: "Daily step goal",
                isSelected: true,
                action: {}
            )
            .padding(.horizontal)
        }
        .padding()
    }
    .background(DesignSystem.Colors.background)
}

@ViewBuilder
private func colorSwatch(_ color: Color, _ name: String) -> some View {
    VStack {
        RoundedRectangle(cornerRadius: 8)
            .fill(color)
            .frame(width: 50, height: 50)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(DesignSystem.Colors.inkBlack, lineWidth: 1.5)
            )
        Text(name)
            .font(DesignSystem.Typography.caption(10))
    }
}
