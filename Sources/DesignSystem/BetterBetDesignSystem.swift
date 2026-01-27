//
//  BetterBetDesignSystem.swift
//  BetterBet
//
//  Dark-first, high-contrast design system.
//  "Trust beats hype when money is involved."
//
//  See DESIGN_SYSTEM.md for complete specification.
//

import SwiftUI
import UIKit

// MARK: - Better Bet Design System

/// Central namespace for the Better Bet design system.
/// Dark-first, high-contrast, fintech-meets-fitness aesthetic.
enum BB {

    // MARK: - Semantic Colors

    /// Semantic color tokens that adapt to light/dark mode.
    /// Use these instead of hardcoded values.
    enum Colors {
        /// Primary background - near-black (OLED-friendly)
        static let bgPrimary = Color(light: .init(hex: "F5F5F5"), dark: .init(hex: "0A0A0A"))

        /// Secondary background - deep charcoal
        static let bgSecondary = Color(light: .init(hex: "EBEBEB"), dark: .init(hex: "1A1A1A"))

        /// Card/sheet surface
        static let surface = Color(light: .white, dark: .init(hex: "242424"))

        /// Primary text - off-white in dark, near-black in light
        static let textPrimary = Color(light: .init(hex: "0A0A0A"), dark: .init(hex: "F5F5F5"))

        /// Secondary text - muted gray
        static let textSecondary = Color(light: .init(hex: "6B6B6B"), dark: .init(hex: "8E8E93"))

        /// Dividers & borders
        static let divider = Color(light: .init(hex: "E0E0E0"), dark: .init(hex: "3A3A3C"))

        /// Brand accent - Money Lime (use sparingly)
        /// For CTAs, positive deltas, progress highlights
        static let accent = Color(hex: "BFFF00")

        /// Danger/error state
        static let danger = Color.red

        /// Success state
        static let success = Color.green

        /// Warning/caution
        static let warning = Color.orange
    }

    // MARK: - Typography

    /// SF Pro typography with Dynamic Type support.
    enum Typography {
        /// Large display title - use sparingly (max 1 per screen)
        static func largeTitle(_ size: CGFloat = 34) -> Font {
            .system(size: size, weight: .bold, design: .default)
        }

        /// Section titles
        static func title(_ size: CGFloat = 22) -> Font {
            .system(size: size, weight: .bold, design: .default)
        }

        /// Title 2 - smaller headers
        static func title2(_ size: CGFloat = 20) -> Font {
            .system(size: size, weight: .semibold, design: .default)
        }

        /// Title 3 - card headers
        static func title3(_ size: CGFloat = 18) -> Font {
            .system(size: size, weight: .semibold, design: .default)
        }

        /// Body text
        static func body(_ size: CGFloat = 17) -> Font {
            .system(size: size, weight: .regular, design: .default)
        }

        /// Callout - emphasized body
        static func callout(_ size: CGFloat = 16) -> Font {
            .system(size: size, weight: .medium, design: .default)
        }

        /// Caption - metadata, timestamps
        static func caption(_ size: CGFloat = 13) -> Font {
            .system(size: size, weight: .regular, design: .default)
        }

        /// Caption 2 - smaller metadata
        static func caption2(_ size: CGFloat = 11) -> Font {
            .system(size: size, weight: .regular, design: .default)
        }

        /// Monospaced - for money, countdowns, deltas
        static func mono(_ size: CGFloat = 17) -> Font {
            .system(size: size, weight: .medium, design: .monospaced)
        }

        /// Large monospaced - for pot amounts
        static func monoLarge(_ size: CGFloat = 32) -> Font {
            .system(size: size, weight: .bold, design: .monospaced)
        }

        /// Display headline - poster style (use very sparingly)
        static func display(_ size: CGFloat = 40) -> Font {
            .system(size: size, weight: .black, design: .default)
        }
    }

    // MARK: - Spacing (8pt Grid)

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius

    enum Radius {
        /// Small chips, pills
        static let sm: CGFloat = 10
        /// Medium elements
        static let md: CGFloat = 12
        /// Cards
        static let card: CGFloat = 16
        /// Primary buttons
        static let button: CGFloat = 14
    }

    // MARK: - Haptics

    enum Haptics {
        static func light() {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }

        static func medium() {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }

        static func heavy() {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }

        static func success() {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}

// MARK: - Color Extensions

extension Color {
    /// Initialize with light/dark mode colors
    init(light: Color, dark: Color) {
        self.init(
            UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(dark)
                    : UIColor(light)
            })
    }

    /// Initialize from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
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

// MARK: - View Modifiers

/// Card style modifier - surface background with subtle border
struct BBCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(BB.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: BB.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: BB.Radius.card)
                    .stroke(BB.Colors.divider, lineWidth: 1)
            )
    }
}

extension View {
    /// Apply card styling
    func bbCard() -> some View {
        modifier(BBCardModifier())
    }

    /// Apply primary background
    func bbBackground() -> some View {
        self.background(BB.Colors.bgPrimary.ignoresSafeArea())
    }
}

// MARK: - Button Styles

/// Primary CTA button - accent color
struct BBPrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BB.Typography.callout())
            .fontWeight(.semibold)
            .foregroundColor(.black)
            .padding(.horizontal, BB.Spacing.lg)
            .padding(.vertical, BB.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(isEnabled ? BB.Colors.accent : BB.Colors.textSecondary)
            .clipShape(RoundedRectangle(cornerRadius: BB.Radius.button))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Secondary button - outline style
struct BBSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BB.Typography.callout())
            .fontWeight(.medium)
            .foregroundColor(BB.Colors.textPrimary)
            .padding(.horizontal, BB.Spacing.lg)
            .padding(.vertical, BB.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(BB.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: BB.Radius.button))
            .overlay(
                RoundedRectangle(cornerRadius: BB.Radius.button)
                    .stroke(BB.Colors.divider, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == BBPrimaryButtonStyle {
    static var bbPrimary: BBPrimaryButtonStyle { BBPrimaryButtonStyle() }
    static var bbPrimaryDisabled: BBPrimaryButtonStyle { BBPrimaryButtonStyle(isEnabled: false) }
}

extension ButtonStyle where Self == BBSecondaryButtonStyle {
    static var bbSecondary: BBSecondaryButtonStyle { BBSecondaryButtonStyle() }
}

// MARK: - Components

/// Mode pill for challenge types
struct ModePill: View {
    let mode: String
    let icon: String
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: BB.Spacing.xxs) {
            Text(icon)
                .font(.system(size: 14))
            Text(mode.uppercased())
                .font(BB.Typography.caption2())
                .fontWeight(.semibold)
        }
        .padding(.horizontal, BB.Spacing.sm)
        .padding(.vertical, BB.Spacing.xs)
        .background(isSelected ? BB.Colors.accent : BB.Colors.surface)
        .foregroundColor(isSelected ? .black : BB.Colors.textSecondary)
        .clipShape(RoundedRectangle(cornerRadius: BB.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: BB.Radius.sm)
                .stroke(isSelected ? Color.clear : BB.Colors.divider, lineWidth: 1)
        )
    }
}

/// Pot amount display
struct PotDisplay: View {
    let amount: Double
    var size: Font = BB.Typography.monoLarge()

    var body: some View {
        Text("$\(Int(amount))")
            .font(size)
            .foregroundColor(BB.Colors.accent)
    }
}

/// Rank chip
struct RankChip: View {
    let rank: Int
    let total: Int

    var body: some View {
        Text("#\(rank) of \(total)")
            .font(BB.Typography.caption())
            .fontWeight(.medium)
            .foregroundColor(BB.Colors.textSecondary)
            .padding(.horizontal, BB.Spacing.sm)
            .padding(.vertical, BB.Spacing.xxs)
            .background(BB.Colors.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: BB.Radius.sm))
    }
}

/// Countdown timer display
struct CountdownDisplay: View {
    let timeRemaining: String

    var body: some View {
        HStack(spacing: BB.Spacing.xxs) {
            Image(systemName: "clock")
                .font(.system(size: 12))
            Text(timeRemaining)
                .font(BB.Typography.mono(14))
        }
        .foregroundColor(BB.Colors.textSecondary)
    }
}

/// Verification status badge
struct VerificationBadge: View {
    var body: some View {
        HStack(spacing: BB.Spacing.xxs) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 12))
            Text("READ-ONLY")
                .font(BB.Typography.caption2())
                .fontWeight(.semibold)
        }
        .foregroundColor(BB.Colors.success)
        .padding(.horizontal, BB.Spacing.xs)
        .padding(.vertical, BB.Spacing.xxs)
        .background(BB.Colors.success.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: BB.Radius.sm))
    }
}

// MARK: - Preview

#Preview("Better Bet Design System") {
    ScrollView {
        VStack(spacing: BB.Spacing.lg) {
            // Header
            Text("BETTER BET")
                .font(BB.Typography.display(32))
                .foregroundColor(BB.Colors.textPrimary)

            Text("Dark-First Design System")
                .font(BB.Typography.caption())
                .foregroundColor(BB.Colors.textSecondary)

            Divider()
                .background(BB.Colors.divider)

            // Colors
            HStack(spacing: BB.Spacing.sm) {
                colorSwatch(BB.Colors.bgPrimary, "BG")
                colorSwatch(BB.Colors.surface, "Surface")
                colorSwatch(BB.Colors.accent, "Accent")
                colorSwatch(BB.Colors.danger, "Danger")
            }

            // Card
            VStack(alignment: .leading, spacing: BB.Spacing.xs) {
                Text("Card Style")
                    .font(BB.Typography.title3())
                    .foregroundColor(BB.Colors.textPrimary)
                Text("Surface background, subtle border")
                    .font(BB.Typography.caption())
                    .foregroundColor(BB.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(BB.Spacing.md)
            .bbCard()

            // Components
            HStack(spacing: BB.Spacing.sm) {
                ModePill(mode: "Steps", icon: "👟", isSelected: true)
                ModePill(mode: "Distance", icon: "🏃")
                ModePill(mode: "Active", icon: "⏱️")
            }

            HStack {
                PotDisplay(amount: 150)
                Spacer()
                RankChip(rank: 2, total: 8)
            }
            .padding(.horizontal)

            CountdownDisplay(timeRemaining: "2d 14h 32m")

            VerificationBadge()

            // Buttons
            VStack(spacing: BB.Spacing.sm) {
                Button("Join Challenge") {}
                    .buttonStyle(.bbPrimary)

                Button("View Details") {}
                    .buttonStyle(.bbSecondary)
            }
            .padding(.horizontal)

            // Typography
            VStack(alignment: .leading, spacing: BB.Spacing.xs) {
                Text("Display")
                    .font(BB.Typography.display(28))
                Text("Title")
                    .font(BB.Typography.title())
                Text("Body Text")
                    .font(BB.Typography.body())
                Text("$1,234")
                    .font(BB.Typography.mono())
                Text("Caption")
                    .font(BB.Typography.caption())
                    .foregroundColor(BB.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(BB.Spacing.md)
            .foregroundColor(BB.Colors.textPrimary)
            .bbCard()
        }
        .padding()
    }
    .background(BB.Colors.bgPrimary)
    .preferredColorScheme(.dark)
}

@ViewBuilder
private func colorSwatch(_ color: Color, _ name: String) -> some View {
    VStack(spacing: 4) {
        RoundedRectangle(cornerRadius: 8)
            .fill(color)
            .frame(width: 60, height: 60)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(BB.Colors.divider, lineWidth: 1)
            )
        Text(name)
            .font(BB.Typography.caption2())
            .foregroundColor(BB.Colors.textSecondary)
    }
}
