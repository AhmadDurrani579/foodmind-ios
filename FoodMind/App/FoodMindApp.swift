//
//  FoodMindApp.swift
//  FoodMind
//
//  Created by Ahmad on 13/03/2026.
//

import SwiftUI

@main
struct FoodMindApp: App {

    @State private var showSplash = true
    @State private var isLoggedIn = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {

                    // ── Step 1: Splash ──
                    SplashView(onFinished: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showSplash = false
                        }
                    })
                    .transition(.opacity)

                } else if !isLoggedIn {

                    // ── Step 2: Login ──
                    LoginView(onLoginSuccess: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            isLoggedIn = true
                        }
                    })
                    .transition(.opacity)

                } else {

                    // ── Step 3: Main App ──
                    MainTabView()
                        .transition(.opacity)

                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
