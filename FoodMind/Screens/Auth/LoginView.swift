//
//  Login.swift
//  FoodMind
//
//  Created by Ahmad on 13/03/2026.
//

import SwiftUI
 
struct LoginView: View {
 
    // Callback — called when login succeeds
    var onLoginSuccess: () -> Void = {}
 
    @State private var email    = ""
    @State private var password = ""
    @State private var showSignUp    = false
    @State private var isLoading     = false
    @State private var showError     = false
    @State private var errorMessage  = ""
 
    // Animation states
    @State private var contentOpacity: Double  = 0
    @State private var contentOffset:  CGFloat = 20
 
    var body: some View {
        ZStack {
 
            // ── Background ──────────────────────
            FMColors.background.ignoresSafeArea()
 
            // ── Ambient glows ───────────────────
            AmbientGlowBackground()
 
            // ── Scrollable content ──────────────
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
 
                    // Brand section
                    BrandHeader()
                        .padding(.top, 72)
                        .padding(.horizontal, 28)
                        .padding(.bottom, 36)
 
                    // Form section
                    VStack(spacing: 14) {
 
                        // Social login
                        SocialLoginRow(onApple: {
                            handleSocialLogin(provider: "Apple")
                        }, onGoogle: {
                            handleSocialLogin(provider: "Google")
                        })
 
                        // Divider
                        FMDivider(label: "or with email")
 
                        // Email field
                        FMInputField(
                            label: "Email",
                            placeholder: "you@example.com",
                            text: $email,
                            icon: "envelope",
                            keyboardType: .emailAddress,
                            autoCapitalize: false
                        )
 
                        // Password field
                        FMSecureInputField(
                            label: "Password",
                            placeholder: "••••••••••",
                            text: $password,
                            icon: "lock"
                        )
 
                        // Forgot password
                        HStack {
                            Spacer()
                            Button("Forgot password?") {}
                                .font(.system(size: 13))
                                .foregroundColor(FMColors.green)
                        }
 
                        // Error message
                        if showError {
                            ErrorBanner(message: errorMessage)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
 
                        // Sign in button
                        FMPrimaryButton(
                            label: "Sign In",
                            isLoading: isLoading
                        ) {
                            handleLogin()
                        }
 
                        // Sign up link
                        SignUpPrompt {
                            showSignUp = true
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
            }
            .opacity(contentOpacity)
            .offset(y: contentOffset)
        }
        .onAppear {
            animateIn()
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView(onSignUpSuccess: {
                showSignUp = false
                onLoginSuccess()
            })
        }
    }
 
    // ─────────────────────────────────
    // MARK: — Actions
    // ─────────────────────────────────
    private func handleLogin() {
        // Basic validation
        guard !email.isEmpty, !password.isEmpty else {
            showErrorMessage("Please fill in all fields")
            return
        }
        guard email.contains("@") else {
            showErrorMessage("Please enter a valid email")
            return
        }
        guard password.count >= 6 else {
            showErrorMessage("Password must be at least 6 characters")
            return
        }
 
        // Show loading
        isLoading = true
 
        // Simulate API call (replace with real auth later)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isLoading = false
            onLoginSuccess()
        }
    }
 
    private func handleSocialLogin(provider: String) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            onLoginSuccess()
        }
    }
 
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        withAnimation(.spring()) {
            showError = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showError = false
            }
        }
    }
 
    private func animateIn() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
            contentOpacity = 1
            contentOffset  = 0
        }
    }
    
}

#Preview {
    LoginView(onLoginSuccess: {
        print("Login successful")
    })
}


// Sign up prompt at bottom
private struct SignUpPrompt: View {
    var onTap: () -> Void
 
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text("Don't have an account?")
                    .foregroundColor(FMColors.cream.opacity(0.25))
                Text("Create one →")
                    .foregroundColor(FMColors.cream.opacity(0.5))
            }
            .font(.system(size: 14))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
    }
}
