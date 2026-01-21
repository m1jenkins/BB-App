//
//  BetterBetApp.swift
//  BetterBet
//
//  Main app entry point for Better Bet - a social accountability app
//  where friends pool money to enforce habits.
//
//  SEMANTIC FIREWALL NOTICE:
//  This is a COMMITMENT CONTRACT platform, NOT a gambling app.
//  All UI strings, variable names, and comments must use approved terminology:
//  - Approved: Pledge, Stake, Commitment, Pot, Challenge, Fulfill, Fail
//  - Forbidden: Bet, Wager, Gamble, Win, Lose (gambling context)
//

import SwiftUI
import SwiftData

/// The main entry point for the Better Bet application.
@main
struct BetterBetApp: App {
    // MARK: - State

    /// Tracks whether the user has completed onboarding
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    // MARK: - SwiftData Configuration

    /// Model container for local persistence
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Challenge.self,
            Participant.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            ContentView(hasCompletedOnboarding: $hasCompletedOnboarding)
                .preferredColorScheme(.light) // Neo-brutalist design works best in light mode
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Content View (Root Navigation)

/// Root view that handles navigation between onboarding and main app.
struct ContentView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var healthManager = HealthManager()

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
                    .environment(healthManager)
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: hasCompletedOnboarding)
    }
}

// MARK: - Main Tab View

/// Main navigation structure after onboarding.
struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            NavigationStack {
                DashboardView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(DesignSystem.Colors.mustard)
                                Text("Better Bet")
                                    .font(DesignSystem.Typography.title(18))
                                    .foregroundColor(DesignSystem.Colors.inkBlack)
                            }
                        }

                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                // Profile action
                            } label: {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(DesignSystem.Colors.inkBlack)
                            }
                        }
                    }
            }
            .tabItem {
                Label("Challenge", systemImage: "flame.fill")
            }
            .tag(0)

            // History Tab (Placeholder)
            NavigationStack {
                PlaceholderView(
                    icon: "clock.arrow.circlepath",
                    title: "History",
                    subtitle: "Your past challenges and commitment record will appear here."
                )
                .navigationTitle("History")
            }
            .tabItem {
                Label("History", systemImage: "clock.arrow.circlepath")
            }
            .tag(1)

            // Create Challenge Tab (Placeholder)
            NavigationStack {
                PlaceholderView(
                    icon: "plus.circle.fill",
                    // SEMANTIC FIREWALL: "Create Commitment" not "Place Bet"
                    title: "New Challenge",
                    subtitle: "Create a new commitment challenge with friends."
                )
                .navigationTitle("New Challenge")
            }
            .tabItem {
                // SEMANTIC FIREWALL: "Pledge" not "Bet"
                Label("Pledge", systemImage: "plus.circle.fill")
            }
            .tag(2)

            // Friends Tab (Placeholder)
            NavigationStack {
                PlaceholderView(
                    icon: "person.2.fill",
                    title: "Friends",
                    // SEMANTIC FIREWALL: "accountability partners" not "opponents"
                    subtitle: "Manage your accountability partners."
                )
                .navigationTitle("Friends")
            }
            .tabItem {
                Label("Friends", systemImage: "person.2.fill")
            }
            .tag(3)
        }
        .tint(DesignSystem.Colors.inkBlack)
    }
}

// MARK: - Placeholder View

/// Placeholder for tabs that aren't implemented yet.
struct PlaceholderView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()

            VStack(spacing: DesignSystem.Spacing.md) {
                // Icon in brutalist frame
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusMedium)
                        .fill(DesignSystem.Colors.inkBlack)
                        .frame(width: 84, height: 84)
                        .offset(x: 4, y: 4)

                    RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusMedium)
                        .fill(DesignSystem.Colors.mustard.opacity(0.3))
                        .frame(width: 84, height: 84)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusMedium)
                                .stroke(DesignSystem.Colors.inkBlack, lineWidth: DesignSystem.Borders.thickness)
                        )

                    Image(systemName: icon)
                        .font(.system(size: 36))
                        .foregroundColor(DesignSystem.Colors.inkBlack)
                }

                Text(title)
                    .font(DesignSystem.Typography.title())
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                Text(subtitle)
                    .font(DesignSystem.Typography.body())
                    .foregroundColor(DesignSystem.Colors.inkGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.xl)

                Text("Coming Soon")
                    .font(DesignSystem.Typography.caption())
                    .fontWeight(.bold)
                    .tracking(2)
                    .textCase(.uppercase)
                    .foregroundColor(DesignSystem.Colors.mustard)
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.vertical, DesignSystem.Spacing.xxs)
                    .background(DesignSystem.Colors.inkBlack)
                    .padding(.top, DesignSystem.Spacing.sm)
            }
        }
    }
}

// MARK: - Previews

#Preview("App - Onboarding") {
    ContentView(hasCompletedOnboarding: .constant(false))
}

#Preview("App - Main") {
    ContentView(hasCompletedOnboarding: .constant(true))
}

#Preview("Tab View") {
    MainTabView()
}
