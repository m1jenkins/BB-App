//
//  SignInView.swift
//  BetterBet
//
//  Sign-in screen for Better Bet - the entry point for user authentication.
//  Follows the "Clean Athletic" design system.
//
//  SEMANTIC FIREWALL NOTICE:
//  This is a COMMITMENT CONTRACT platform, NOT a gambling app.
//  Approved: Pledge, Stake, Commitment, Pot, Challenge, Fulfill, Fail
//  Forbidden: Bet, Wager, Gamble, Win, Lose
//

import SwiftUI

/// Sign-in view that allows users to authenticate before accessing the app.
struct SignInView: View {
    @Binding var isSignedIn: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var isShowingCreateAccount = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    Spacer()
                        .frame(height: DesignSystem.Spacing.xxl)

                    // Logo and branding
                    brandingSection

                    Spacer()
                        .frame(height: DesignSystem.Spacing.lg)

                    // Sign in form
                    signInForm

                    // Divider with "or"
                    dividerSection

                    // Social sign-in options
                    socialSignInSection

                    Spacer()
                        .frame(height: DesignSystem.Spacing.lg)

                    // Create account link
                    createAccountSection

                    Spacer()
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
            }
        }
        .alert("Sign In Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Branding Section

    private var brandingSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // App icon with brutalist frame
            ZStack {
                // Hard shadow
                RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusMedium)
                    .fill(DesignSystem.Colors.inkBlack)
                    .frame(width: 100, height: 100)
                    .offset(x: 5, y: 5)

                // Icon container
                RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusMedium)
                    .fill(DesignSystem.Colors.mustard)
                    .frame(width: 100, height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusMedium)
                            .stroke(DesignSystem.Colors.inkBlack, lineWidth: DesignSystem.Borders.thickness)
                    )

                // Flame icon
                Image(systemName: "flame.fill")
                    .font(.system(size: 48))
                    .foregroundColor(DesignSystem.Colors.inkBlack)
            }

            // App name
            Text("Better Bet")
                .font(DesignSystem.Typography.headline(36))
                .foregroundColor(DesignSystem.Colors.inkBlack)

            // Tagline
            Text("Commitment contracts that pay.")
                .font(DesignSystem.Typography.body(16))
                .foregroundColor(DesignSystem.Colors.inkGray)
        }
    }

    // MARK: - Sign In Form

    private var signInForm: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Email field
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("Email")
                    .font(DesignSystem.Typography.label())
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                TextField("you@example.com", text: $email)
                    .font(DesignSystem.Typography.body())
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.cardWhite)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusButton))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusButton)
                            .stroke(DesignSystem.Colors.inkBlack, lineWidth: DesignSystem.Borders.thickness)
                    )
            }

            // Password field
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("Password")
                    .font(DesignSystem.Typography.label())
                    .foregroundColor(DesignSystem.Colors.inkBlack)

                SecureField("Enter your password", text: $password)
                    .font(DesignSystem.Typography.body())
                    .textContentType(.password)
                    .padding(DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.cardWhite)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusButton))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusButton)
                            .stroke(DesignSystem.Colors.inkBlack, lineWidth: DesignSystem.Borders.thickness)
                    )
            }

            // Forgot password link
            HStack {
                Spacer()
                Button {
                    // TODO: Implement forgot password flow
                } label: {
                    Text("Forgot password?")
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.inkGray)
                }
            }

            // Sign In button
            Button {
                signIn()
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Sign In")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.primary)
            .disabled(email.isEmpty || password.isEmpty || isLoading)
            .padding(.top, DesignSystem.Spacing.xs)
        }
        .padding(DesignSystem.Spacing.lg)
        .cleanCard()
    }

    // MARK: - Divider Section

    private var dividerSection: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Rectangle()
                .fill(DesignSystem.Colors.inkBlack.opacity(0.2))
                .frame(height: 1)

            Text("or")
                .font(DesignSystem.Typography.caption())
                .foregroundColor(DesignSystem.Colors.inkGray)

            Rectangle()
                .fill(DesignSystem.Colors.inkBlack.opacity(0.2))
                .frame(height: 1)
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
    }

    // MARK: - Social Sign In Section

    private var socialSignInSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            // Sign in with Apple
            Button {
                signInWithApple()
            } label: {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 20))
                    Text("Continue with Apple")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.secondary)

            // Sign in with Google
            Button {
                signInWithGoogle()
            } label: {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "g.circle.fill")
                        .font(.system(size: 20))
                    Text("Continue with Google")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.secondary)
        }
    }

    // MARK: - Create Account Section

    private var createAccountSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text("New to Better Bet?")
                .font(DesignSystem.Typography.caption())
                .foregroundColor(DesignSystem.Colors.inkGray)

            Button {
                isShowingCreateAccount = true
            } label: {
                Text("Create Account")
                    .font(DesignSystem.Typography.button())
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.inkBlack)
                    .underline()
            }
        }
        .sheet(isPresented: $isShowingCreateAccount) {
            CreateAccountView(isSignedIn: $isSignedIn)
        }
    }

    // MARK: - Actions

    private func signIn() {
        guard !email.isEmpty, !password.isEmpty else { return }

        isLoading = true

        // Simulate network request
        // TODO: Replace with actual authentication
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            // For now, just sign in the user
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isSignedIn = true
            }
        }
    }

    private func signInWithApple() {
        // TODO: Implement Apple Sign In
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isSignedIn = true
        }
    }

    private func signInWithGoogle() {
        // TODO: Implement Google Sign In
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isSignedIn = true
        }
    }
}

// MARK: - Create Account View

struct CreateAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isSignedIn: Bool

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    private var passwordsMatch: Bool {
        !password.isEmpty && password == confirmPassword
    }

    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty && passwordsMatch
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // Header
                        VStack(spacing: DesignSystem.Spacing.xs) {
                            Text("Join Better Bet")
                                .font(DesignSystem.Typography.headline(28))
                                .foregroundColor(DesignSystem.Colors.inkBlack)

                            Text("Start your commitment journey")
                                .font(DesignSystem.Typography.body())
                                .foregroundColor(DesignSystem.Colors.inkGray)
                        }
                        .padding(.top, DesignSystem.Spacing.lg)

                        // Form
                        VStack(spacing: DesignSystem.Spacing.md) {
                            // Name field
                            formField(
                                label: "Full Name",
                                placeholder: "Your name",
                                text: $name,
                                contentType: .name
                            )

                            // Email field
                            formField(
                                label: "Email",
                                placeholder: "you@example.com",
                                text: $email,
                                contentType: .emailAddress,
                                keyboardType: .emailAddress
                            )

                            // Password field
                            secureFormField(
                                label: "Password",
                                placeholder: "Create a password",
                                text: $password,
                                contentType: .newPassword
                            )

                            // Confirm password field
                            secureFormField(
                                label: "Confirm Password",
                                placeholder: "Confirm your password",
                                text: $confirmPassword,
                                contentType: .newPassword
                            )

                            // Password match indicator
                            if !confirmPassword.isEmpty {
                                HStack {
                                    Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(passwordsMatch ? DesignSystem.Colors.moneyGreen : DesignSystem.Colors.alertRed)
                                    Text(passwordsMatch ? "Passwords match" : "Passwords don't match")
                                        .font(DesignSystem.Typography.caption())
                                        .foregroundColor(passwordsMatch ? DesignSystem.Colors.moneyGreen : DesignSystem.Colors.alertRed)
                                    Spacer()
                                }
                            }

                            // Create Account button
                            Button {
                                createAccount()
                            } label: {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Text("Create Account")
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.chunky)
                            .disabled(!isFormValid || isLoading)
                            .padding(.top, DesignSystem.Spacing.sm)
                        }
                        .padding(DesignSystem.Spacing.lg)
                        .cleanCard()

                        // Terms
                        Text("By creating an account, you agree to our Terms of Service and Privacy Policy.")
                            .font(DesignSystem.Typography.caption(12))
                            .foregroundColor(DesignSystem.Colors.lightGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, DesignSystem.Spacing.lg)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.inkBlack)
                    }
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Form Field Helpers

    private func formField(
        label: String,
        placeholder: String,
        text: Binding<String>,
        contentType: UITextContentType?,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(label)
                .font(DesignSystem.Typography.label())
                .foregroundColor(DesignSystem.Colors.inkBlack)

            TextField(placeholder, text: text)
                .font(DesignSystem.Typography.body())
                .keyboardType(keyboardType)
                .textContentType(contentType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                .disableAutocorrection(keyboardType == .emailAddress)
                .padding(DesignSystem.Spacing.md)
                .background(DesignSystem.Colors.cardWhite)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusButton))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusButton)
                        .stroke(DesignSystem.Colors.inkBlack, lineWidth: DesignSystem.Borders.thickness)
                )
        }
    }

    private func secureFormField(
        label: String,
        placeholder: String,
        text: Binding<String>,
        contentType: UITextContentType?
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(label)
                .font(DesignSystem.Typography.label())
                .foregroundColor(DesignSystem.Colors.inkBlack)

            SecureField(placeholder, text: text)
                .font(DesignSystem.Typography.body())
                .textContentType(contentType)
                .padding(DesignSystem.Spacing.md)
                .background(DesignSystem.Colors.cardWhite)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusButton))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.Borders.radiusButton)
                        .stroke(DesignSystem.Colors.inkBlack, lineWidth: DesignSystem.Borders.thickness)
                )
        }
    }

    // MARK: - Actions

    private func createAccount() {
        guard isFormValid else { return }

        isLoading = true

        // Simulate network request
        // TODO: Replace with actual account creation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            dismiss()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isSignedIn = true
            }
        }
    }
}

// MARK: - Previews

#Preview("Sign In") {
    SignInView(isSignedIn: .constant(false))
}

#Preview("Create Account") {
    CreateAccountView(isSignedIn: .constant(false))
}
