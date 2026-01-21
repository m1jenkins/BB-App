//
//  OnboardingView.swift
//  BetterBet
//
//  The "Hook" - First impression that sells the commitment contract concept.
//  Three slides that challenge conventional motivation and introduce the mechanism.
//
//  SEMANTIC FIREWALL NOTICE:
//  Language here is crucial. We're selling "accountability through commitment",
//  NOT gambling. The messaging emphasizes personal stakes and social accountability.
//

import SwiftUI

/// The onboarding flow that hooks users with the Better Bet value proposition.
/// Uses provocative messaging to challenge conventional motivation approaches.
struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0

    // SEMANTIC FIREWALL: All copy here avoids gambling terminology
    private let slides: [OnboardingSlide] = [
        OnboardingSlide(
            icon: "😴",
            headline: "Willpower is a Myth.",
            subheadline: "Studies show motivation fades. You've started that habit tracker 47 times already.",
            accentText: "Let's be honest."
        ),
        OnboardingSlide(
            icon: "🔥",
            headline: "Collateral is Real.",
            subheadline: "Put your money where your mouth is. Stake something you'll actually miss.",
            // SEMANTIC FIREWALL: "Stake" not "Bet"
            accentText: "Skin in the game."
        ),
        OnboardingSlide(
            icon: "💰",
            headline: "Profit from Your Friends.",
            subheadline: "When they slack, you stack. The pot grows every time someone fails their commitment.",
            // SEMANTIC FIREWALL: "fails their commitment" not "loses"
            accentText: "Accountability pays."
        )
    ]

    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Page indicator
                HStack(spacing: DesignSystem.Spacing.xs) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(index == currentPage ? DesignSystem.Colors.inkBlack : DesignSystem.Colors.inkBlack.opacity(0.3))
                            .frame(width: index == currentPage ? 24 : 8, height: 4)
                            .animation(.easeInOut(duration: 0.2), value: currentPage)
                    }
                }
                .padding(.top, DesignSystem.Spacing.lg)

                // Slides
                TabView(selection: $currentPage) {
                    ForEach(Array(slides.enumerated()), id: \.offset) { index, slide in
                        OnboardingSlideView(slide: slide)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // Bottom section with CTA
                VStack(spacing: DesignSystem.Spacing.md) {
                    if currentPage == slides.count - 1 {
                        // Final slide - Show the main CTA
                        // SEMANTIC FIREWALL: "Stake Your Claim" not "Place Your Bet"
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                hasCompletedOnboarding = true
                            }
                        } label: {
                            HStack {
                                Text("Stake Your Claim")
                                Image(systemName: "arrow.right")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.chunky)
                        .padding(.horizontal, DesignSystem.Spacing.lg)

                    } else {
                        // Not final slide - Show next button
                        Button {
                            withAnimation {
                                currentPage += 1
                            }
                        } label: {
                            HStack {
                                Text("Next")
                                Image(systemName: "arrow.right")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.chunky)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                    }

                    // Skip option (subtle)
                    if currentPage < slides.count - 1 {
                        Button {
                            withAnimation {
                                currentPage = slides.count - 1
                            }
                        } label: {
                            Text("Skip")
                                .font(DesignSystem.Typography.caption())
                                .foregroundColor(DesignSystem.Colors.inkGray)
                        }
                    }
                }
                .padding(.bottom, DesignSystem.Spacing.xxl)
            }
        }
    }
}

// MARK: - Onboarding Slide Data Model

struct OnboardingSlide {
    let icon: String
    let headline: String
    let subheadline: String
    let accentText: String
}

// MARK: - Individual Slide View

struct OnboardingSlideView: View {
    let slide: OnboardingSlide

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Spacer()

            // Icon in a brutalist frame
            ZStack {
                // Hard shadow
                RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusMedium)
                    .fill(DesignSystem.Colors.inkBlack)
                    .frame(width: 140, height: 140)
                    .offset(x: 6, y: 6)

                // Icon container
                RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusMedium)
                    .fill(DesignSystem.Colors.mustard)
                    .frame(width: 140, height: 140)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusMedium)
                            .stroke(DesignSystem.Colors.inkBlack, lineWidth: DesignSystem.Borders.thickness)
                    )

                // Emoji icon
                Text(slide.icon)
                    .font(.system(size: 64))
            }
            .padding(.bottom, DesignSystem.Spacing.md)

            // Headline
            Text(slide.headline)
                .font(DesignSystem.Typography.headline(36))
                .foregroundColor(DesignSystem.Colors.inkBlack)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.lg)

            // Accent text (the hook)
            Text(slide.accentText)
                .font(DesignSystem.Typography.body(18))
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.mustard)
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(DesignSystem.Colors.inkBlack)

            // Subheadline
            Text(slide.subheadline)
                .font(DesignSystem.Typography.body(18))
                .foregroundColor(DesignSystem.Colors.inkGray)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, DesignSystem.Spacing.xl)

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview("Onboarding Flow") {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}

#Preview("Slide 1 - Willpower") {
    OnboardingSlideView(slide: OnboardingSlide(
        icon: "😴",
        headline: "Willpower is a Myth.",
        subheadline: "Studies show motivation fades. You've started that habit tracker 47 times already.",
        accentText: "Let's be honest."
    ))
    .background(DesignSystem.Colors.background)
}

#Preview("Slide 2 - Collateral") {
    OnboardingSlideView(slide: OnboardingSlide(
        icon: "🔥",
        headline: "Collateral is Real.",
        subheadline: "Put your money where your mouth is. Stake something you'll actually miss.",
        accentText: "Skin in the game."
    ))
    .background(DesignSystem.Colors.background)
}

#Preview("Slide 3 - Profit") {
    OnboardingSlideView(slide: OnboardingSlide(
        icon: "💰",
        headline: "Profit from Your Friends.",
        subheadline: "When they slack, you stack. The pot grows every time someone fails their commitment.",
        accentText: "Accountability pays."
    ))
    .background(DesignSystem.Colors.background)
}
