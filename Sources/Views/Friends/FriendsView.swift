//
//  FriendsView.swift
//  BetterBet
//
//  Social hub for managing friends and sending pledge invitations.
//  Core to the social accountability experience.
//
//  SEMANTIC FIREWALL NOTICE:
//  - "Invite to pledge" not "invite to bet"
//  - "Active commitments" not "active bets"
//

import SwiftUI

/// Main friends management view.
struct FriendsView: View {
    @State private var friends: [Friend] = Friend.mockFriends
    @State private var showAddFriend = false

    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: DesignSystem.Spacing.md) {
                    // Friends count header
                    FriendsHeaderCard(friendCount: friends.count)

                    // Friends list
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        ForEach(friends, id: \.id) { friend in
                            FriendRow(friend: friend)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                }
                .padding(.top, DesignSystem.Spacing.sm)
            }

            // FAB for adding friends
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showAddFriend = true
                    } label: {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(DesignSystem.Colors.inkBlack)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(
                                        DesignSystem.Colors.inkBlack,
                                        lineWidth: DesignSystem.Borders.thickness)
                            )
                            .elevatedShadow()
                    }
                    .padding(.trailing, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.lg)
                }
            }
        }
        .sheet(isPresented: $showAddFriend) {
            AddFriendPlaceholder()
        }
    }
}

// MARK: - Friends Header Card

struct FriendsHeaderCard: View {
    let friendCount: Int

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Squad")
                        .font(DesignSystem.Typography.title(20))
                        .foregroundColor(DesignSystem.Colors.inkBlack)

                    // SEMANTIC FIREWALL: "commitments" not "bets"
                    Text("Hold each other accountable")
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.inkGray)
                }

                Spacer()

                // Friend count badge
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.mustard)
                        .frame(width: 56, height: 56)

                    VStack(spacing: 0) {
                        Text("\(friendCount)")
                            .font(DesignSystem.Typography.data(20))
                            .foregroundColor(DesignSystem.Colors.inkBlack)

                        Text("friends")
                            .font(DesignSystem.Typography.caption(9))
                            .foregroundColor(DesignSystem.Colors.inkBlack)
                            .textCase(.uppercase)
                            .tracking(0.5)
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cleanCard()
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
}

// MARK: - Friend Row

struct FriendRow: View {
    let friend: Friend
    @State private var showInvite = false

    var body: some View {
        Button {
            showInvite = true
        } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.background)
                        .frame(width: 48, height: 48)

                    Text(friend.avatar)
                        .font(.system(size: 24))
                }

                // Friend info
                VStack(alignment: .leading, spacing: 2) {
                    Text(friend.name)
                        .font(DesignSystem.Typography.body())
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.inkBlack)

                    if friend.activePledgesCount > 0 {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(DesignSystem.Colors.moneyGreen)
                                .frame(width: 6, height: 6)

                            // SEMANTIC FIREWALL: "pledges" not "bets"
                            Text(
                                "\(friend.activePledgesCount) active pledge\(friend.activePledgesCount == 1 ? "" : "s")"
                            )
                            .font(DesignSystem.Typography.caption(12))
                            .foregroundColor(DesignSystem.Colors.moneyGreen)
                        }
                    } else {
                        Text("No active pledges")
                            .font(DesignSystem.Typography.caption(12))
                            .foregroundColor(DesignSystem.Colors.inkGray)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(DesignSystem.Colors.inkGray)
            }
            .padding(DesignSystem.Spacing.sm)
            .background(DesignSystem.Colors.cardWhite)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusSmall))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusSmall)
                    .stroke(DesignSystem.Colors.inkBlack, lineWidth: DesignSystem.Borders.thickness)
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showInvite) {
            FriendDetailPlaceholder(friend: friend)
        }
    }
}

// MARK: - Placeholder Sheets

struct AddFriendPlaceholder: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background
                    .ignoresSafeArea()

                VStack(spacing: DesignSystem.Spacing.lg) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 64))
                        .foregroundColor(DesignSystem.Colors.inkGray)

                    Text("Add Friends")
                        .font(DesignSystem.Typography.title(24))
                        .foregroundColor(DesignSystem.Colors.inkBlack)

                    Text("Contact sync and friend invitations coming soon!")
                        .font(DesignSystem.Typography.body())
                        .foregroundColor(DesignSystem.Colors.inkGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignSystem.Spacing.xl)
                }
            }
            .navigationTitle("Add Friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FriendDetailPlaceholder: View {
    let friend: Friend
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background
                    .ignoresSafeArea()

                VStack(spacing: DesignSystem.Spacing.lg) {
                    Text(friend.avatar)
                        .font(.system(size: 80))

                    Text(friend.name)
                        .font(DesignSystem.Typography.title(28))
                        .foregroundColor(DesignSystem.Colors.inkBlack)

                    // SEMANTIC FIREWALL: "Invite to Pledge" not "Invite to Bet"
                    Button("Invite to Pledge") {
                        // Placeholder action
                    }
                    .buttonStyle(.primary)
                    .padding(.top, DesignSystem.Spacing.md)

                    Text("Pledge invitations coming soon!")
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.inkGray)
                }
            }
            .navigationTitle(friend.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Friends View") {
    NavigationStack {
        FriendsView()
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Friend Row") {
    FriendRow(friend: Friend.mockFriends[0])
        .padding()
        .background(DesignSystem.Colors.background)
}
