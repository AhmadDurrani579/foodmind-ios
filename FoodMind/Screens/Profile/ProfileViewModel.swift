//
//  profileViewModel.swift
//  FoodMind
//
//  Created by Ahmad on 17/03/2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var user: User?

    // NEW
    @Published var recentScans: [Scan] = []
    @Published var stats: ScanStats?
    
    private let authRepository: AuthRepositoryProtocol = AuthRepository()
    private let scanRepository: ScanRepositoryProtocol = ScanRepository()

    func fetchProfile() {
        Task {
            do {
                isLoading = true
                user = try await authRepository.getProfile()
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    func fetchRecentScans() {
        Task {
            do {
                recentScans = try await scanRepository.getMyScans(
                    limit: 5,
                    offset: 0
                )
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func fetchStats() {
        Task {
            do {
                stats = try await scanRepository.getScanStats()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
