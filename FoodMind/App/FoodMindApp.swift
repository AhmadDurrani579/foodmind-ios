//
//  FoodMindApp.swift
//  FoodMind
//
//  Created by Ahmad on 13/03/2026.
//

import SwiftUI

@main
struct FoodMindApp: App {

    @State private var showSplash     = true
    @State private var showEmailLogin = false
    @StateObject var authManager      = AuthManager()
    @StateObject private var wsManager = WebSocketManager()

    var body: some Scene {
        WindowGroup {
            ZStack {

                // ── Step 1: Splash ──────────────────────────
                if showSplash {
                    SplashView(onFinished: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showSplash = false
                        }
                    })
                    .transition(.opacity)

                // ── Step 2: Auth screens ────────────────────
                } else if !authManager.isLoggedIn {

                    if showEmailLogin {
                        // ── Email login ──
                        LoginView(onLoginSuccess: {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                showEmailLogin         = false
                                authManager.isLoggedIn = true
                                if let token = TokenManager.shared.getToken() {
                                    wsManager.connect(token: token)
                                }
                            }
                        })
                        .transition(.opacity)

                    } else {
                        // ── Face recognition welcome ──
                        FaceAuthWelcomeView(
                            onFaceSuccess: {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    authManager.isLoggedIn = true
                                    showEmailLogin         = false
                                    if let token = TokenManager.shared.getToken() {
                                        wsManager.connect(token: token)
                                    }
                                }
                            },
                            onUseEmail: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showEmailLogin = true
                                }
                            }
                        )
                        .transition(.opacity)
                    }

                // ── Step 3: Main App ────────────────────────
                } else {
                    MainTabView()
                        .environmentObject(wsManager)
                        .environmentObject(authManager)
                        .transition(.opacity)
                }
            }
            .preferredColorScheme(.dark)
            .onAppear {
                if authManager.isLoggedIn,
                   let token = TokenManager.shared.getToken() {
                    wsManager.connect(token: token)
                }
            }
            // Reconnect when app comes to foreground
            .onReceive(
                NotificationCenter.default.publisher(
                    for: UIApplication.willEnterForegroundNotification)
            ) { _ in
                if authManager.isLoggedIn,
                   let token = TokenManager.shared.getToken() {
                    if case .disconnected = wsManager.connectionState {
                        wsManager.connect(token: token)
                    }
                }
            }
            // 401 from any API call — clear token and go back to face screen
            .onReceive(
                NotificationCenter.default.publisher(
                    for: .unauthorizedAccess)
            ) { _ in
                withAnimation(.easeInOut(duration: 0.4)) {
                    wsManager.disconnect()
                    TokenManager.shared.clearToken()
                    authManager.isLoggedIn = false
                    showEmailLogin         = false   // reset to face screen not email
                }
            }
        }
    }
}
