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
    // Messaging aligned with "Put Your Money Where Your Health Is" philosophy
    // Follows the How It Works flow from CLAUDE.md
    private let slides: [OnboardingSlide] = [
        // Slide 1: The Hook - Core Philosophy
        OnboardingSlide(
            icon: "💪",
            headline: "Willpower is Finite.",
            subheadline:
                "But incentives are powerful. Better Bet isn't just a fitness tracker—it's an accountability engine that makes skipping workouts cost you.",
            accentText: "Put your money where your health is."
        ),
        // Slide 2: How It Works - The Flow
        OnboardingSlide(
            icon: "🏆",
            headline: "Here's How It Works.",
            subheadline:
                "Create a challenge. Invite your squad. Sweat it out. At the deadline, survivors split the pot—those who miss the mark pay the price.",
            // SEMANTIC FIREWALL: "Stake" not "Bet"
            accentText: "Create → Invite → Sweat → Payout"
        ),
        // Slide 3: The Game Modes
        OnboardingSlide(
            icon: "📊",
            headline: "Pick Your Battle.",
            subheadline:
                "👟 Step Showdown for walkers\n🏃 Distance Derby for runners\n⏱️ Active Zone for gym-goers",
            accentText: "Three ways to compete."
        ),
        // Slide 4: Verification - The Trust
        OnboardingSlide(
            icon: "📱",
            headline: "No Cheating. Period.",
            subheadline:
                "We sync directly with Apple Health. No manual entry. No honor system. If it's not tracked, it didn't happen.",
            // SEMANTIC FIREWALL: "fails their commitment" not "loses"
            accentText: "Automatic verification."
        ),
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
                            .fill(
                                index == currentPage
                                    ? DesignSystem.Colors.inkBlack
                                    : DesignSystem.Colors.inkBlack.opacity(0.3)
                            )
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
                            .stroke(
                                DesignSystem.Colors.inkBlack,
                                lineWidth: DesignSystem.Borders.thickness)
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

#Preview("Slide 1 - Philosophy") {
    OnboardingSlideView(
        slide: OnboardingSlide(
            icon: "💪",
            headline: "Willpower is Finite.",
            subheadline:
                "But incentives are powerful. Better Bet isn't just a fitness tracker—it's an accountability engine that makes skipping workouts cost you.",
            accentText: "Put your money where your health is."
        )
    )
    .background(DesignSystem.Colors.background)
}

#Preview("Slide 2 - Flow") {
    OnboardingSlideView(
        slide: OnboardingSlide(
            icon: "🏆",
            headline: "Here's How It Works.",
            subheadline:
                "Create a challenge. Invite your squad. Sweat it out. At the deadline, survivors split the pot—those who miss the mark pay the price.",
            accentText: "Create → Invite → Sweat → Payout"
        )
    )
    .background(DesignSystem.Colors.background)
}

#Preview("Slide 3 - Game Modes") {
    OnboardingSlideView(
        slide: OnboardingSlide(
            icon: "📊",
            headline: "Pick Your Battle.",
            subheadline:
                "👟 Step Showdown for walkers\n🏃 Distance Derby for runners\n⏱️ Active Zone for gym-goers",
            accentText: "Three ways to compete."
        )
    )
    .background(DesignSystem.Colors.background)
}

#Preview("Slide 4 - Verification") {
    OnboardingSlideView(
        slide: OnboardingSlide(
            icon: "📱",
            headline: "No Cheating. Period.",
            subheadline:
                "We sync directly with Apple Health. No manual entry. No honor system. If it's not tracked, it didn't happen.",
            accentText: "Automatic verification."
        )
    )
    .background(DesignSystem.Colors.background)
}
