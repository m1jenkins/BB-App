//
//  BetterBetApp.swift
//  BetterBet
//
//  Main app entry point for Better Bet - a social accountability app
//  where friends pool money to enforce fitness habits.
//
//  SEMANTIC FIREWALL NOTICE:
//  This is a COMMITMENT CONTRACT platform, NOT a gambling app.
//  All UI strings, variable names, and comments must use approved terminology:
//  - Approved: Pledge, Stake, Commitment, Pot, Challenge, Fulfill, Fail
//  - Forbidden: Bet, Wager, Gamble, Win, Lose (gambling context)
//

import SwiftData
import SwiftUI

/// The main entry point for the Better Bet application.
@main
struct BetterBetApp: App {
    // MARK: - State

    /// Tracks whether the user is signed in
    @AppStorage("isSignedIn") private var isSignedIn = false

    /// Tracks whether the user has completed onboarding
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    // MARK: - SwiftData Configuration

    /// Model container for local persistence
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Challenge.self,
            Participant.self,
            Pledge.self,  // Added Pledge model for step tracking
            Friend.self,  // Added Friend model for social features
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
            ContentView(isSignedIn: $isSignedIn, hasCompletedOnboarding: $hasCompletedOnboarding)
                .preferredColorScheme(.light)  // Clean Athletic design works best in light mode
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Content View (Root Navigation)

/// Root view that handles navigation between sign-in, onboarding, and main app.
struct ContentView: View {
    @Binding var isSignedIn: Bool
    @Binding var hasCompletedOnboarding: Bool
    @State private var healthManager = HealthManager()

    var body: some View {
        Group {
            if !isSignedIn {
                // User needs to sign in
                SignInView(isSignedIn: $isSignedIn)
            } else if hasCompletedOnboarding {
                // User is signed in and has completed onboarding
                MainTabView()
                    .environment(healthManager)
            } else {
                // User is signed in but needs onboarding
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .environment(healthManager)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isSignedIn)
        .animation(.easeInOut(duration: 0.3), value: hasCompletedOnboarding)
        .task {
            // Request HealthKit authorization on app launch (only if signed in)
            if isSignedIn {
                await healthManager.requestAuthorization()
            }
        }
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

            // Friends Tab
            NavigationStack {
                FriendsView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: "person.2.fill")
                                    .foregroundColor(DesignSystem.Colors.mustard)
                                Text("Friends")
                                    .font(DesignSystem.Typography.title(18))
                                    .foregroundColor(DesignSystem.Colors.inkBlack)
                            }
                        }
                    }
            }
            .tabItem {
                Label("Friends", systemImage: "person.2.fill")
            }
            .tag(1)

            // Create Challenge Tab
            NavigationStack {
                CreatePledgeView()
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                // SEMANTIC FIREWALL: "Pledge" not "Bet"
                Label("Pledge", systemImage: "plus.circle.fill")
            }
            .tag(2)

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
                // Icon in clean card
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusMedium)
                        .fill(DesignSystem.Colors.cardWhite)
                        .frame(width: 84, height: 84)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusMedium)
                                .stroke(
                                    DesignSystem.Colors.inkBlack.opacity(0.1),
                                    lineWidth: DesignSystem.Borders.thickness)
                        )
                        .elevatedShadow()

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
                    .foregroundColor(.white)
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.vertical, DesignSystem.Spacing.xxs)
                    .background(DesignSystem.Colors.inkBlack)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(.top, DesignSystem.Spacing.sm)
            }
        }
    }
}

// MARK: - Previews

#Preview("App - Sign In") {
    ContentView(isSignedIn: .constant(false), hasCompletedOnboarding: .constant(false))
}

#Preview("App - Onboarding") {
    ContentView(isSignedIn: .constant(true), hasCompletedOnboarding: .constant(false))
}

#Preview("App - Main") {
    ContentView(isSignedIn: .constant(true), hasCompletedOnboarding: .constant(true))
}

#Preview("Tab View") {
    MainTabView()
        .environment(HealthManager.preview)
}
