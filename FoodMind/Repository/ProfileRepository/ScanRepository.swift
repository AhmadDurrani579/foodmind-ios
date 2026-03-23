//
//  ScanRepository.swift
//  FoodMind
//
//  Created by Ahmad on 18/03/2026.
//


protocol ScanRepositoryProtocol {
    func getMyScans(limit: Int, offset: Int) async throws -> [Scan]
    func getScanStats() async throws -> ScanStats

}

class ScanRepository: ScanRepositoryProtocol {
    func getMyScans(limit: Int, offset: Int) async throws -> [Scan] {
        let endpoint = MyScansEndpoint(limit: limit, offset: offset)
        let scans: [Scan] = try await APIClient.shared.request(endpoint)

        return scans
    }
    
    func getScanStats() async throws -> ScanStats {
        let endpoint = ScanStatsEndpoint()
        return try await APIClient.shared.request(endpoint)
    }
}
