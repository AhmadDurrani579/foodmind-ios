//
//  Splash.swift
//  FoodMind
//
//  Created by Ahmad on 13/03/2026.
//

import SwiftUI

struct SplashView: View {

    // Callback — called when splash is done
    var onFinished: () -> Void

    // Animation states
    @State private var logoScale:      CGFloat = 0.6
    @State private var logoOpacity:    Double  = 0
    @State private var nameOffset:     CGFloat = 24
    @State private var nameOpacity:    Double  = 0
    @State private var taglineOpacity: Double  = 0
    @State private var dotsOpacity:    Double  = 0
    @State private var ringsOpacity:   Double  = 0

    var body: some View {
        ZStack {

            // ── 1. Background ──────────────────
            FMColors.background
                .ignoresSafeArea()

            // ── 2. Ambient glows ───────────────
            GeometryReader { geo in
                // Top-left green glow
                Circle()
                    .fill(Color(hex: "263C16"))
                    .frame(width: geo.size.width * 0.75)
                    .blur(radius: 90)
                    .offset(
                        x: -geo.size.width * 0.25,
                        y: -geo.size.height * 0.15
                    )
                    .opacity(0.55)

                // Bottom-right dark green glow
                Circle()
                    .fill(Color(hex: "1A3010"))
                    .frame(width: geo.size.width * 0.65)
                    .blur(radius: 80)
                    .offset(
                        x: geo.size.width * 0.45,
                        y: geo.size.height * 0.58
                    )
                    .opacity(0.45)
            }
            .ignoresSafeArea()

            // ── 3. Concentric rings ────────────
            ZStack {
                ForEach(
                    [
                        (340.0, 0.05),
                        (260.0, 0.07),
                        (180.0, 0.09),
                        (110.0, 0.12)
                    ],
                    id: \.0
                ) { diameter, opacity in
                    Circle()
                        .stroke(
                            FMColors.green.opacity(opacity),
                            lineWidth: 1
                        )
                        .frame(width: diameter, height: diameter)
                }
            }
            .offset(y: -24)
            .opacity(ringsOpacity)

            // ── 4. Main content ────────────────
            VStack(spacing: 0) {

                Spacer()

                // Logo icon
                LogoIconView(size: 88)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                // App name
                Text("FoodMind")
                    .font(.system(size: 38, weight: .semibold, design: .serif))
                    .foregroundColor(FMColors.cream)
                    .tracking(-0.5)
                    .padding(.top, 22)
                    .offset(y: nameOffset)
                    .opacity(nameOpacity)

                // Tagline
                Text("Point. Think. Know.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(FMColors.cream.opacity(0.4))
                    .tracking(1.2)
                    .padding(.top, 10)
                    .opacity(taglineOpacity)

                Spacer()

                // Loading dots
                VStack(spacing: 10) {
                    LoadingDotsView()
                    Text("Loading your experience")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(FMColors.cream.opacity(0.22))
                        .tracking(0.8)
                }
                .opacity(dotsOpacity)
                .padding(.bottom, 56)

                // Version
                Text("Version 1.0.0")
                    .font(.system(size: 10))
                    .foregroundColor(FMColors.cream.opacity(0.14))
                    .padding(.bottom, 32)
            }
        }
        .onAppear {
            runAnimations()
        }
    }

    // ─────────────────────────────────
    // MARK: — Animation Sequence
    // ─────────────────────────────────
    private func runAnimations() {

        // Rings fade in
        withAnimation(.easeOut(duration: 0.6).delay(0.05)) {
            ringsOpacity = 1
        }

        // Logo springs in
        withAnimation(
            .spring(response: 0.55, dampingFraction: 0.68)
            .delay(0.1)
        ) {
            logoScale   = 1.0
            logoOpacity = 1.0
        }

        // App name rises up
        withAnimation(
            .spring(response: 0.5, dampingFraction: 0.75)
            .delay(0.38)
        ) {
            nameOffset  = 0
            nameOpacity = 1.0
        }

        // Tagline fades in
        withAnimation(.easeOut(duration: 0.4).delay(0.58)) {
            taglineOpacity = 1.0
        }

        // Loading dots appear
        withAnimation(.easeOut(duration: 0.3).delay(0.75)) {
            dotsOpacity = 1.0
        }

        // Transition to next screen after 2.8s
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            onFinished()
        }
    }
}

#Preview {
    SplashView(onFinished: {})
}
