//
//  IndustrialLayoutWrapper.swift
//  BetterBet
//
//  Layout wrapper that enforces Industrial Pop styling globally.
//  Wraps any view to apply the Neo-Brutalist design system.
//

import SwiftUI

/// A wrapper view that enforces Industrial Pop styling on all child views.
/// Use this to wrap screens or components that should use the Neo-Brutalist aesthetic.
struct IndustrialLayoutWrapper<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Ghost White background
            IndustrialPop.Colors.surfaceMain
                .ignoresSafeArea()

            content
        }
        // Enforce monospace font globally for this view hierarchy
        .environment(\.font, IndustrialPop.Typography.body())
    }
}

// MARK: - Industrial Navigation View

/// A navigation header styled for the Industrial Pop design system.
/// Displays back button and contract title in monospace uppercase.
struct IndustrialNav: View {
    let contractTitle: String
    var onBack: (() -> Void)?

    var body: some View {
        HStack {
            // Back button
            if let onBack = onBack {
                Button(action: onBack) {
                    HStack(spacing: IndustrialPop.Spacing.xxs) {
                        Text("[")
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .bold))
                        Text("BACK")
                        Text("]")
                    }
                    .font(IndustrialPop.Typography.nav())
                    .foregroundColor(IndustrialPop.Colors.textStrong)
                }
            }

            Spacer()

            // Contract title
            Text("CONTRACT: \(contractTitle)")
                .font(IndustrialPop.Typography.nav())
                .foregroundColor(IndustrialPop.Colors.textStrong)
        }
        .padding(.horizontal, IndustrialPop.Spacing.md)
        .padding(.vertical, IndustrialPop.Spacing.sm)
        .background(IndustrialPop.Colors.surfaceMain)
        .overlay(
            Rectangle()
                .frame(height: IndustrialPop.Borders.standard)
                .foregroundColor(IndustrialPop.Colors.textStrong),
            alignment: .bottom
        )
    }
}

// MARK: - Industrial Safe Area Wrapper

/// Applies Industrial Pop background with safe area handling
struct IndustrialBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            IndustrialPop.Colors.surfaceMain
                .ignoresSafeArea()
            content
        }
    }
}

extension View {
    /// Apply Industrial Pop background (Ghost White) with safe area handling
    func industrialBackground() -> some View {
        modifier(IndustrialBackground())
    }
}

// MARK: - Preview

#Preview("Industrial Layout Wrapper") {
    IndustrialLayoutWrapper {
        VStack(spacing: 0) {
            IndustrialNav(contractTitle: "MARCH MADNESS") {
                print("Back tapped")
            }

            Spacer()

            VStack(spacing: IndustrialPop.Spacing.md) {
                Text("WRAPPED CONTENT")
                    .font(IndustrialPop.Typography.headline(24))

                Text("ALL TEXT USES MONOSPACE")
                    .font(IndustrialPop.Typography.body())
                    .foregroundColor(IndustrialPop.Colors.textMuted)

                Button("INDUSTRIAL BUTTON") {}
                    .buttonStyle(.industrial)
                    .padding(.horizontal)
            }

            Spacer()
        }
    }
}
