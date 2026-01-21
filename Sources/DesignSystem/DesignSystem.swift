//
//  DesignSystem.swift
//  BetterBet
//
//  Neo-Brutalist Design System: "Chunky Retro" aesthetic
//  Vibe: "Liquid Death meets Strava" - Irreverent, high-stakes, brutally honest
//
//  SEMANTIC FIREWALL NOTICE:
//  This app uses commitment contract terminology, NOT gambling terms.
//  Approved: "Pledge", "Stake", "Commitment", "Pot", "Challenge"
//  Forbidden: "Bet", "Wager", "Gamble", "Win", "Lose" (use "Succeed"/"Fail")
//

import SwiftUI

// MARK: - Design System Namespace

/// Central namespace for all design tokens in the Better Bet app.
/// Enforces the "Chunky Retro" / Neo-Brutalist aesthetic throughout.
enum DesignSystem {

    // MARK: - Color Palette

    enum Colors {
        /// Primary app background - Warm cream (#F9F7F1)
        static let background = Color(hex: "F9F7F1")

        /// Primary text, borders, icons - Near black (#050505)
        static let inkBlack = Color(hex: "050505")

        /// Accent color for highlights and hard shadows (#F4D03F)
        static let mustard = Color(hex: "F4D03F")

        /// Failed states, warnings, elimination indicators (#FF453A)
        static let alertRed = Color(hex: "FF453A")

        /// Pot values, success states, money indicators (#00A86B)
        static let moneyGreen = Color(hex: "00A86B")

        /// Secondary text, disabled states
        static let inkGray = Color(hex: "6B6B6B")

        /// Card/component backgrounds - Pure white for contrast
        static let cardWhite = Color.white
    }

    // MARK: - Typography

    enum Typography {
        /// Large display headlines - Heavy serif impact
        /// Ideal: Cooper Black, Fallback: System Serif Heavy
        static func headline(_ size: CGFloat = 32) -> Font {
            // Cooper Black is not a system font, using serif with black weight
            .system(size: size, weight: .black, design: .serif)
        }

        /// Section titles and emphasis
        static func title(_ size: CGFloat = 24) -> Font {
            .system(size: size, weight: .bold, design: .serif)
        }

        /// Primary body text - Clean geometric sans
        /// Ideal: DM Sans, Fallback: System Rounded
        static func body(_ size: CGFloat = 16) -> Font {
            .system(size: size, weight: .medium, design: .rounded)
        }

        /// Secondary text, captions
        static func caption(_ size: CGFloat = 14) -> Font {
            .system(size: size, weight: .regular, design: .rounded)
        }

        /// Button labels - Bold and commanding
        static func button(_ size: CGFloat = 18) -> Font {
            .system(size: size, weight: .bold, design: .rounded)
        }

        /// Monospace for numbers/stats
        static func mono(_ size: CGFloat = 16) -> Font {
            .system(size: size, weight: .semibold, design: .monospaced)
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

    // MARK: - Border & Shadow Constants

    enum Borders {
        /// Standard thick border width for Neo-Brutalist style
        static let thickness: CGFloat = 3

        /// Minimal corner radius (sharp aesthetic)
        static let radiusSharp: CGFloat = 0
        static let radiusSmall: CGFloat = 4
        static let radiusMedium: CGFloat = 8
    }

    enum Shadows {
        /// Hard shadow offset (no blur - brutalist style)
        static let offset: CGSize = CGSize(width: 4, height: 4)
        static let offsetSmall: CGSize = CGSize(width: 2, height: 2)
        static let offsetLarge: CGSize = CGSize(width: 6, height: 6)

        /// Shadow blur radius (always 0 for hard shadows)
        static let blur: CGFloat = 0
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

// MARK: - Neo-Brutalist View Modifier

/// The signature "Better Bet" style modifier.
/// Applies thick borders, hard shadows, and cream/white fills.
struct NeoBrutalistModifier: ViewModifier {
    var backgroundColor: Color
    var borderColor: Color
    var shadowColor: Color
    var cornerRadius: CGFloat
    var shadowOffset: CGSize

    init(
        backgroundColor: Color = DesignSystem.Colors.cardWhite,
        borderColor: Color = DesignSystem.Colors.inkBlack,
        shadowColor: Color = DesignSystem.Colors.inkBlack,
        cornerRadius: CGFloat = DesignSystem.Borders.radiusSmall,
        shadowOffset: CGSize = DesignSystem.Shadows.offset
    ) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.shadowColor = shadowColor
        self.cornerRadius = cornerRadius
        self.shadowOffset = shadowOffset
    }

    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: DesignSystem.Borders.thickness)
            )
            .shadow(
                color: shadowColor,
                radius: DesignSystem.Shadows.blur,
                x: shadowOffset.width,
                y: shadowOffset.height
            )
    }
}

/// Accent variant with mustard shadow for highlights
struct NeoBrutalistAccentModifier: ViewModifier {
    var cornerRadius: CGFloat

    init(cornerRadius: CGFloat = DesignSystem.Borders.radiusSmall) {
        self.cornerRadius = cornerRadius
    }

    func body(content: Content) -> some View {
        content
            .background(DesignSystem.Colors.mustard)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(DesignSystem.Colors.inkBlack, lineWidth: DesignSystem.Borders.thickness)
            )
            .shadow(
                color: DesignSystem.Colors.inkBlack,
                radius: DesignSystem.Shadows.blur,
                x: DesignSystem.Shadows.offset.width,
                y: DesignSystem.Shadows.offset.height
            )
    }
}

// MARK: - View Extensions for Easy Access

extension View {
    /// Apply the signature Neo-Brutalist card style
    /// - Parameters:
    ///   - backgroundColor: Fill color (default: white)
    ///   - shadowColor: Hard shadow color (default: inkBlack)
    ///   - cornerRadius: Corner radius (default: 4px - minimal)
    func neoBrutalist(
        backgroundColor: Color = DesignSystem.Colors.cardWhite,
        borderColor: Color = DesignSystem.Colors.inkBlack,
        shadowColor: Color = DesignSystem.Colors.inkBlack,
        cornerRadius: CGFloat = DesignSystem.Borders.radiusSmall,
        shadowOffset: CGSize = DesignSystem.Shadows.offset
    ) -> some View {
        modifier(NeoBrutalistModifier(
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            shadowColor: shadowColor,
            cornerRadius: cornerRadius,
            shadowOffset: shadowOffset
        ))
    }

    /// Apply Neo-Brutalist style with mustard accent (for CTAs, highlights)
    func neoBrutalistAccent(cornerRadius: CGFloat = DesignSystem.Borders.radiusSmall) -> some View {
        modifier(NeoBrutalistAccentModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - Reusable Button Style

/// Chunky, pressable button style for primary actions
struct ChunkyButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var foregroundColor: Color
    var isDestructive: Bool

    init(
        backgroundColor: Color = DesignSystem.Colors.mustard,
        foregroundColor: Color = DesignSystem.Colors.inkBlack,
        isDestructive: Bool = false
    ) {
        self.backgroundColor = isDestructive ? DesignSystem.Colors.alertRed : backgroundColor
        self.foregroundColor = isDestructive ? .white : foregroundColor
        self.isDestructive = isDestructive
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.button())
            .foregroundColor(foregroundColor)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusSmall))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusSmall)
                    .stroke(DesignSystem.Colors.inkBlack, lineWidth: DesignSystem.Borders.thickness)
            )
            .shadow(
                color: DesignSystem.Colors.inkBlack,
                radius: DesignSystem.Shadows.blur,
                x: configuration.isPressed ? 1 : DesignSystem.Shadows.offset.width,
                y: configuration.isPressed ? 1 : DesignSystem.Shadows.offset.height
            )
            .offset(
                x: configuration.isPressed ? 3 : 0,
                y: configuration.isPressed ? 3 : 0
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Secondary/outline button style
struct OutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.button())
            .foregroundColor(DesignSystem.Colors.inkBlack)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.background)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusSmall))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusSmall)
                    .stroke(DesignSystem.Colors.inkBlack, lineWidth: DesignSystem.Borders.thickness)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

// MARK: - Button Style Extensions

extension ButtonStyle where Self == ChunkyButtonStyle {
    /// Primary chunky button with mustard background
    static var chunky: ChunkyButtonStyle { ChunkyButtonStyle() }

    /// Destructive chunky button with red background
    static var chunkyDestructive: ChunkyButtonStyle { ChunkyButtonStyle(isDestructive: true) }

    /// Money/success themed button
    static var chunkyMoney: ChunkyButtonStyle {
        ChunkyButtonStyle(backgroundColor: DesignSystem.Colors.moneyGreen, foregroundColor: .white)
    }
}

extension ButtonStyle where Self == OutlineButtonStyle {
    /// Secondary outline button
    static var outline: OutlineButtonStyle { OutlineButtonStyle() }
}

// MARK: - Starburst Badge Shape (for Pot Display)

/// Jagged starburst shape for highlighting important values (like the Pot)
struct StarburstShape: Shape {
    var points: Int
    var innerRadiusRatio: CGFloat

    init(points: Int = 12, innerRadiusRatio: CGFloat = 0.7) {
        self.points = points
        self.innerRadiusRatio = innerRadiusRatio
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * innerRadiusRatio

        var path = Path()
        let angleStep = .pi / CGFloat(points)

        for i in 0..<(points * 2) {
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let angle = CGFloat(i) * angleStep - .pi / 2
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )

            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Progress Bar Style

/// Thick-bordered progress bar matching the Neo-Brutalist aesthetic
struct ChunkyProgressBar: View {
    var progress: Double // 0.0 to 1.0
    var fillColor: Color
    var height: CGFloat

    init(
        progress: Double,
        fillColor: Color = DesignSystem.Colors.moneyGreen,
        height: CGFloat = 24
    ) {
        self.progress = min(max(progress, 0), 1)
        self.fillColor = fillColor
        self.height = height
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusSmall)
                    .fill(DesignSystem.Colors.background)

                // Fill bar
                RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusSmall)
                    .fill(fillColor)
                    .frame(width: geometry.size.width * progress)

                // Border overlay
                RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusSmall)
                    .stroke(DesignSystem.Colors.inkBlack, lineWidth: DesignSystem.Borders.thickness)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Preview Provider

#Preview("Design System Showcase") {
    ScrollView {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Colors
            Text("COLORS")
                .font(DesignSystem.Typography.headline(24))

            HStack(spacing: DesignSystem.Spacing.sm) {
                colorSwatch(DesignSystem.Colors.background, "BG")
                colorSwatch(DesignSystem.Colors.inkBlack, "Ink")
                colorSwatch(DesignSystem.Colors.mustard, "Mustard")
                colorSwatch(DesignSystem.Colors.alertRed, "Alert")
                colorSwatch(DesignSystem.Colors.moneyGreen, "Money")
            }

            Divider()

            // Typography
            Text("TYPOGRAPHY")
                .font(DesignSystem.Typography.headline(24))

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("Headline - Cooper Black")
                    .font(DesignSystem.Typography.headline())
                Text("Title - Bold Serif")
                    .font(DesignSystem.Typography.title())
                Text("Body - DM Sans Medium")
                    .font(DesignSystem.Typography.body())
                Text("Caption - DM Sans Regular")
                    .font(DesignSystem.Typography.caption())
            }

            Divider()

            // Components
            Text("COMPONENTS")
                .font(DesignSystem.Typography.headline(24))

            // Card
            Text("Neo-Brutalist Card")
                .font(DesignSystem.Typography.body())
                .padding()
                .frame(maxWidth: .infinity)
                .neoBrutalist()

            // Accent Card
            Text("Accent Card (Mustard)")
                .font(DesignSystem.Typography.body())
                .padding()
                .frame(maxWidth: .infinity)
                .neoBrutalistAccent()

            // Buttons
            HStack(spacing: DesignSystem.Spacing.md) {
                Button("Stake Now") {}
                    .buttonStyle(.chunky)

                Button("Cancel") {}
                    .buttonStyle(.outline)
            }

            // Progress Bar
            ChunkyProgressBar(progress: 0.72)
                .padding(.horizontal)

            // Starburst Badge
            ZStack {
                StarburstShape(points: 16)
                    .fill(DesignSystem.Colors.mustard)
                    .frame(width: 120, height: 120)
                StarburstShape(points: 16)
                    .stroke(DesignSystem.Colors.inkBlack, lineWidth: 2)
                    .frame(width: 120, height: 120)
                Text("$150")
                    .font(DesignSystem.Typography.headline(28))
                    .foregroundColor(DesignSystem.Colors.inkBlack)
            }
        }
        .padding()
    }
    .background(DesignSystem.Colors.background)
}

@ViewBuilder
private func colorSwatch(_ color: Color, _ name: String) -> some View {
    VStack {
        RoundedRectangle(cornerRadius: 4)
            .fill(color)
            .frame(width: 50, height: 50)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(DesignSystem.Colors.inkBlack, lineWidth: 2)
            )
        Text(name)
            .font(DesignSystem.Typography.caption(10))
    }
}
