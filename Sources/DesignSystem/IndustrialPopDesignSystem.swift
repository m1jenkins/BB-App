//
//  IndustrialPopDesignSystem.swift
//  BetterBet
//
//  "Industrial Pop / High-Utility Neo-Brutalist" Design System
//  Vibe: Stark, high-stakes, utilitarian - like financial contracts and physical receipts
//
//  DESIGN PHILOSOPHY:
//  - 0px border radius everywhere (Anti-Design Rule)
//  - Heavy black borders (2-3px)
//  - Hard shadows with no blur
//  - Monospace typography throughout
//  - Machine-like precision and urgency
//

import SwiftUI

// MARK: - Industrial Pop Design System Namespace

/// Central namespace for all Industrial Pop design tokens.
/// This is the SINGLE SOURCE OF TRUTH for the Neo-Brutalist aesthetic.
enum IndustrialPop {

    // MARK: - Semantic Color Tokens

    /// Color palette following semantic naming for easy global updates.
    /// Change a value here and it updates the entire app.
    enum Colors {
        /// Main app background - Ghost White (#F2F2F2)
        static let surfaceMain = Color(red: 0.95, green: 0.95, blue: 0.95)

        /// Card/component backgrounds - Pure White
        static let surfaceCard = Color.white

        /// Primary text and borders - Jet Black (#000000)
        static let textStrong = Color.black

        /// Secondary text
        static let textMuted = Color(red: 0.29, green: 0.29, blue: 0.29)

        /// Brand accent - Safety Yellow (#D6FF00)
        /// Used for primary buttons, critical data highlighting, input underlines
        static let brandAccent = Color(red: 0.84, green: 1.0, blue: 0.0)

        /// Alert/failed states - Signal Red
        static let alertRed = Color(red: 1.0, green: 0.23, blue: 0.19)

        /// Success states - Money Green
        static let successGreen = Color(red: 0.0, green: 0.66, blue: 0.42)
    }

    // MARK: - Typography

    /// All typography uses monospace fonts for machine-like precision.
    enum Typography {
        /// Massive headline - Extra heavy weight, uppercase
        /// Used for main headers like "YOUR COLLATERAL"
        static func headline(_ size: CGFloat = 48) -> Font {
            .system(size: size, weight: .black, design: .monospaced)
        }

        /// Section title - Bold monospace
        static func title(_ size: CGFloat = 24) -> Font {
            .system(size: size, weight: .bold, design: .monospaced)
        }

        /// Navigation/contract labels
        static func nav(_ size: CGFloat = 14) -> Font {
            .system(size: size, weight: .semibold, design: .monospaced)
        }

        /// Data display - Medium weight monospace
        static func data(_ size: CGFloat = 18) -> Font {
            .system(size: size, weight: .medium, design: .monospaced)
        }

        /// Body text - Regular monospace
        static func body(_ size: CGFloat = 14) -> Font {
            .system(size: size, weight: .regular, design: .monospaced)
        }

        /// Button labels - Bold monospace
        static func button(_ size: CGFloat = 16) -> Font {
            .system(size: size, weight: .bold, design: .monospaced)
        }

        /// Small labels/captions
        static func caption(_ size: CGFloat = 12) -> Font {
            .system(size: size, weight: .medium, design: .monospaced)
        }

        /// Currency display - Extra large for collateral input
        static func currency(_ size: CGFloat = 72) -> Font {
            .system(size: size, weight: .black, design: .monospaced)
        }
    }

    // MARK: - Spacing

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Borders (Neo-Brutalist Rule: 0px radius)

    enum Borders {
        /// Thick border for primary elements - 3px
        static let thick: CGFloat = 3

        /// Standard border - 2px
        static let standard: CGFloat = 2

        /// Border radius - ALWAYS 0px (Anti-Design Rule)
        static let radius: CGFloat = 0

        /// Yellow underline for inputs - 4px
        static let inputUnderline: CGFloat = 4
    }

    // MARK: - Hard Shadows (No Blur)

    enum Shadows {
        /// Standard hard shadow: 4px 4px 0px #000
        static let hard = HardShadow(x: 4, y: 4, color: Color.black)

        /// Small hard shadow for subtle depth
        static let small = HardShadow(x: 2, y: 2, color: Color.black)

        /// Large hard shadow for emphasis
        static let large = HardShadow(x: 6, y: 6, color: Color.black)
    }

    struct HardShadow {
        let x: CGFloat
        let y: CGFloat
        let color: Color
    }
}

// MARK: - View Modifiers

/// Hard shadow modifier - applies offset shadow layer with no blur
struct HardShadowModifier: ViewModifier {
    var shadow: IndustrialPop.HardShadow

    func body(content: Content) -> some View {
        content
            .background(
                Rectangle()
                    .fill(shadow.color)
                    .offset(x: shadow.x, y: shadow.y)
            )
    }
}

/// Thick border modifier - 3px solid black, 0px radius
struct ThickBorderModifier: ViewModifier {
    var color: Color = IndustrialPop.Colors.textStrong
    var width: CGFloat = IndustrialPop.Borders.thick

    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .stroke(color, lineWidth: width)
            )
    }
}

/// Receipt card modifier - thick border, hard shadow, for contract-like containers
struct ReceiptCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(IndustrialPop.Colors.surfaceCard)
            .modifier(ThickBorderModifier())
            .modifier(HardShadowModifier(shadow: IndustrialPop.Shadows.hard))
    }
}

/// Industrial button modifier - yellow fill, thick border, hard shadow
struct IndustrialButtonModifier: ViewModifier {
    var isEnabled: Bool = true

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Hard shadow layer
                    Rectangle()
                        .fill(IndustrialPop.Colors.textStrong)
                        .offset(x: 4, y: 4)

                    // Button background
                    Rectangle()
                        .fill(
                            isEnabled
                                ? IndustrialPop.Colors.brandAccent : IndustrialPop.Colors.textMuted)

                    // Border
                    Rectangle()
                        .stroke(
                            IndustrialPop.Colors.textStrong, lineWidth: IndustrialPop.Borders.thick)
                }
            )
    }
}

// MARK: - View Extensions

extension View {
    /// Apply hard shadow (4px 4px 0px black)
    func hardShadow(_ shadow: IndustrialPop.HardShadow = IndustrialPop.Shadows.hard) -> some View {
        modifier(HardShadowModifier(shadow: shadow))
    }

    /// Apply thick black border (3px solid black, 0px radius)
    func thickBorder(
        color: Color = IndustrialPop.Colors.textStrong, width: CGFloat = IndustrialPop.Borders.thick
    ) -> some View {
        modifier(ThickBorderModifier(color: color, width: width))
    }

    /// Apply receipt card styling (thick border + hard shadow)
    func receiptCard() -> some View {
        modifier(ReceiptCardModifier())
    }

    /// Apply monospace styling
    func monospaceStyle() -> some View {
        self.font(IndustrialPop.Typography.body())
    }
}

// MARK: - Industrial Primary Button Style

/// Primary CTA button - Safety Yellow fill, 0px radius, hard shadow
struct IndustrialButtonStyle: ButtonStyle {
    var isEnabled: Bool

    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // Hard shadow layer
            Rectangle()
                .fill(IndustrialPop.Colors.textStrong)
                .offset(x: configuration.isPressed ? 2 : 4, y: configuration.isPressed ? 2 : 4)

            // Button content
            configuration.label
                .font(IndustrialPop.Typography.button())
                .textCase(.uppercase)
                .tracking(1)
                .foregroundColor(IndustrialPop.Colors.textStrong)
                .padding(.horizontal, IndustrialPop.Spacing.lg)
                .padding(.vertical, IndustrialPop.Spacing.md)
                .frame(maxWidth: .infinity)
                .background(
                    isEnabled
                        ? IndustrialPop.Colors.brandAccent
                        : IndustrialPop.Colors.textMuted.opacity(0.3)
                )
                .overlay(
                    Rectangle()
                        .stroke(
                            IndustrialPop.Colors.textStrong, lineWidth: IndustrialPop.Borders.thick)
                )
        }
        .offset(x: configuration.isPressed ? 2 : 0, y: configuration.isPressed ? 2 : 0)
        .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Secondary button style - outline only
struct IndustrialSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(IndustrialPop.Typography.button())
            .textCase(.uppercase)
            .tracking(1)
            .foregroundColor(IndustrialPop.Colors.textStrong)
            .padding(.horizontal, IndustrialPop.Spacing.lg)
            .padding(.vertical, IndustrialPop.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(IndustrialPop.Colors.surfaceCard)
            .overlay(
                Rectangle()
                    .stroke(
                        IndustrialPop.Colors.textStrong, lineWidth: IndustrialPop.Borders.standard)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Button Style Extensions

extension ButtonStyle where Self == IndustrialButtonStyle {
    /// Industrial primary button - Safety Yellow with hard shadow
    static var industrial: IndustrialButtonStyle { IndustrialButtonStyle() }

    /// Disabled industrial button
    static var industrialDisabled: IndustrialButtonStyle { IndustrialButtonStyle(isEnabled: false) }
}

extension ButtonStyle where Self == IndustrialSecondaryButtonStyle {
    /// Industrial secondary button - outline style
    static var industrialSecondary: IndustrialSecondaryButtonStyle {
        IndustrialSecondaryButtonStyle()
    }
}

// MARK: - Zigzag Edge Shape (Torn Receipt Effect)

/// Creates a zigzag/sawtooth pattern for the bottom edge of receipt cards
struct ZigzagEdge: Shape {
    var teethCount: Int = 12
    var teethHeight: CGFloat = 8

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let teethWidth = rect.width / CGFloat(teethCount)

        // Start at top-left
        path.move(to: CGPoint(x: 0, y: 0))

        // Top edge
        path.addLine(to: CGPoint(x: rect.width, y: 0))

        // Right edge
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - teethHeight))

        // Zigzag bottom edge
        for i in stride(from: teethCount, through: 0, by: -1) {
            let x = CGFloat(i) * teethWidth
            let isValley = i % 2 == 0
            let y = isValley ? rect.height : rect.height - teethHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }

        // Left edge
        path.addLine(to: CGPoint(x: 0, y: 0))

        return path
    }
}

// MARK: - Dithered/Halftone Image Effect

/// Applies a high-contrast B&W dithered effect to images
struct DitheredImageModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .saturation(0)  // Convert to grayscale
            .contrast(1.5)  // Increase contrast for halftone look
            .brightness(0.05)
    }
}

extension View {
    /// Apply dithered B&W effect (high-contrast grayscale)
    func dithered() -> some View {
        modifier(DitheredImageModifier())
    }
}

// MARK: - Preview

#Preview("Industrial Pop Design System") {
    ScrollView {
        VStack(spacing: IndustrialPop.Spacing.lg) {
            // Header
            Text("INDUSTRIAL POP")
                .font(IndustrialPop.Typography.headline(32))
                .foregroundColor(IndustrialPop.Colors.textStrong)

            Text("NEO-BRUTALIST DESIGN TOKENS")
                .font(IndustrialPop.Typography.nav())
                .foregroundColor(IndustrialPop.Colors.textMuted)

            // Colors
            HStack(spacing: IndustrialPop.Spacing.sm) {
                colorSwatch(IndustrialPop.Colors.surfaceMain, "SURFACE")
                colorSwatch(IndustrialPop.Colors.textStrong, "TEXT")
                colorSwatch(IndustrialPop.Colors.brandAccent, "ACCENT")
                colorSwatch(IndustrialPop.Colors.alertRed, "ALERT")
            }

            Divider()
                .frame(height: 2)
                .background(IndustrialPop.Colors.textStrong)

            // Receipt Card
            VStack(alignment: .leading, spacing: IndustrialPop.Spacing.xs) {
                Text("RECEIPT CARD STYLE")
                    .font(IndustrialPop.Typography.title(16))
                Text("THICK BORDER + HARD SHADOW")
                    .font(IndustrialPop.Typography.caption())
                    .foregroundColor(IndustrialPop.Colors.textMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(IndustrialPop.Spacing.md)
            .receiptCard()

            // Buttons
            VStack(spacing: IndustrialPop.Spacing.sm) {
                Button("SIGN & COMMIT") {}
                    .buttonStyle(.industrial)

                Button("CANCEL") {}
                    .buttonStyle(.industrialSecondary)
            }
            .padding(.horizontal)

            // Zigzag Card
            VStack(alignment: .leading, spacing: IndustrialPop.Spacing.xs) {
                Text("TORN RECEIPT EDGE")
                    .font(IndustrialPop.Typography.title(16))
                Text("ZIGZAG BOTTOM PATTERN")
                    .font(IndustrialPop.Typography.caption())
                    .foregroundColor(IndustrialPop.Colors.textMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(IndustrialPop.Spacing.md)
            .padding(.bottom, IndustrialPop.Spacing.sm)
            .background(IndustrialPop.Colors.surfaceCard)
            .clipShape(ZigzagEdge())
            .overlay(
                ZigzagEdge()
                    .stroke(IndustrialPop.Colors.textStrong, lineWidth: IndustrialPop.Borders.thick)
            )
            .hardShadow()

            // Typography
            VStack(alignment: .leading, spacing: IndustrialPop.Spacing.xs) {
                Text("HEADLINE")
                    .font(IndustrialPop.Typography.headline(28))
                Text("TITLE TEXT")
                    .font(IndustrialPop.Typography.title())
                Text("BODY TEXT")
                    .font(IndustrialPop.Typography.body())
                Text("CAPTION")
                    .font(IndustrialPop.Typography.caption())
                    .foregroundColor(IndustrialPop.Colors.textMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(IndustrialPop.Spacing.md)
            .thickBorder()
        }
        .padding()
    }
    .background(IndustrialPop.Colors.surfaceMain)
}

@ViewBuilder
private func colorSwatch(_ color: Color, _ name: String) -> some View {
    VStack(spacing: 4) {
        Rectangle()
            .fill(color)
            .frame(width: 60, height: 60)
            .overlay(
                Rectangle()
                    .stroke(IndustrialPop.Colors.textStrong, lineWidth: 2)
            )
        Text(name)
            .font(IndustrialPop.Typography.caption(10))
    }
}
