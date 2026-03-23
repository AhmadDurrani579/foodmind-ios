//
//  SignUp.swift
//  FoodMind
//
//  Created by Ahmad on 13/03/2026.
//

import SwiftUI

struct SignUpView: View {

    // Callback — called when sign up succeeds
    var onSignUpSuccess: () -> Void = {}
    @Environment(\.dismiss) var dismiss
    @State private var firstName    = ""
    @State private var lastName     = ""
    @State private var username     = ""
    @State private var email        = ""
    @State private var password     = ""
    @State private var agreedToTerms = false
    @State private var isLoading    = false
    @State private var showError    = false
    @State private var errorMessage = ""
    @State private var selectedImage: UIImage?
    // Animation
    @State private var contentOpacity: Double  = 0
    @State private var contentOffset:  CGFloat = 20
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        ZStack {

            // ── Background ──────────────────────
            FMColors.background.ignoresSafeArea()
            

            // ── Ambient glows ───────────────────
            GeometryReader { geo in
                // Top-right warm glow
                Circle()
                    .fill(Color(hex: "3a1a0e"))
                    .frame(width: geo.size.width * 0.65)
                    .blur(radius: 75)
                    .offset(
                        x: geo.size.width * 0.42,
                        y: -geo.size.height * 0.08
                    )
                    .opacity(0.35)

                // Bottom-left green glow
                Circle()
                    .fill(Color(hex: "1a3010"))
                    .frame(width: geo.size.width * 0.55)
                    .blur(radius: 70)
                    .offset(
                        x: -geo.size.width * 0.18,
                        y: geo.size.height * 0.6
                    )
                    .opacity(0.3)
            }
            .ignoresSafeArea()

            // ── Scrollable content ──────────────
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // Back button
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .medium))
                            Text("Back")
                                .font(.system(size: 15))
                        }
                        .foregroundColor(FMColors.cream.opacity(0.5))
                    }
                    .padding(.top, 60)
                    .padding(.horizontal, 24)

                    // Heading
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Create your\nprofile")
                            .font(.system(size: 30, weight: .semibold, design: .serif))
                            .foregroundColor(FMColors.cream)
                            .lineSpacing(3)

                        Text("Join your circle's food intelligence feed")
                            .font(.system(size: 14))
                            .foregroundColor(FMColors.cream.opacity(0.45))
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 24)

                    // Form
                    VStack(spacing: 14) {

                        // Avatar picker
                        AvatarPickerRow(selectedImage: $selectedImage)

                        // First + Last name
                        HStack(spacing: 10) {
                            FMInputField(
                                label: "First Name",
                                placeholder: "Ahmad",
                                text: $firstName,
                                icon: "person"
                            )
                            FMInputField(
                                label: "Last Name",
                                placeholder: "Khan",
                                text: $lastName,
                                icon: ""
                            )
                        }

                        // Username
                        FMInputField(
                            label: "Username",
                            placeholder: "@ahmad",
                            text: $username,
                            icon: "at",
                            autoCapitalize: false
                        )

                        // Email
                        FMInputField(
                            label: "Email",
                            placeholder: "ahmad@example.com",
                            text: $email,
                            icon: "envelope",
                            keyboardType: .emailAddress,
                            autoCapitalize: false
                        )

                        // Password
                        FMSecureInputField(
                            label: "Password",
                            placeholder: "Minimum 6 characters",
                            text: $password,
                            icon: "lock"
                        )

                        // Password strength indicator
                        if !password.isEmpty {
                            PasswordStrengthBar(password: password)
                                .transition(.opacity)
                        }

                        // Terms checkbox
                        TermsRow(agreed: $agreedToTerms)

                        // Error banner
                        if showError {
                            ErrorBanner(message: errorMessage)
                                .transition(
                                    .move(edge: .top)
                                    .combined(with: .opacity)
                                )
                        }

                        // Create account button
                        FMPrimaryButton(
                            label: "Create Account",
                            isLoading: isLoading
                        ) {
                            handleSignUp()
                        }

                        // Already have account
                        Button {
                            dismiss()
                        } label: {
                            HStack(spacing: 4) {
                                Text("Already have an account?")
                                    .foregroundColor(FMColors.cream.opacity(0.25))
                                Text("Sign in →")
                                    .foregroundColor(FMColors.cream.opacity(0.5))
                            }
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 48)
                }
            }
            .opacity(contentOpacity)
            .offset(y: contentOffset)
        }
        .onAppear {
            withAnimation(
                .spring(response: 0.6, dampingFraction: 0.8)
                .delay(0.05)
            ) {
                contentOpacity = 1
                contentOffset  = 0
            }
        }
    }

    // ─────────────────────────────────
    // MARK: — Actions
    // ─────────────────────────────────
    private func handleSignUp() {
        TokenManager.shared.clearToken()
        // Validation
        guard !firstName.isEmpty else {
            showErrorMessage("Please enter your first name")
            return
        }

        guard !username.isEmpty else {
            showErrorMessage("Please choose a username")
            return
        }

        guard !email.isEmpty, email.contains("@") else {
            showErrorMessage("Please enter a valid email")
            return
        }

        guard password.count >= 6 else {
            showErrorMessage("Password must be at least 6 characters")
            return
        }

        guard agreedToTerms else {
            showErrorMessage("Please agree to the Terms of Service")
            return
        }

        isLoading = true

        Task {
            defer {
                isLoading = false
            }

            do {
                _ = try await viewModel.signup(
                    email: email,
                    username: username,
                    firstName: firstName,
                    lastName: lastName,
                    password: password,
                    avatar: selectedImage
                )

                // Navigate to main screen after success
                onSignUpSuccess()

            } catch {
                showErrorMessage(error.localizedDescription)
            }
        }
    }

    private func showErrorMessage(_ message: String) {
        errorMessage = message
        withAnimation(.spring()) {
            showError = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation {
                showError = false
            }
        }
    }
}

// ─────────────────────────────────────
// MARK: — Preview
// ─────────────────────────────────────
#Preview {
    SignUpView(onSignUpSuccess: {
        print("Sign up successful")
    })
}
