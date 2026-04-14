//
//  AppstoreUpdateChecker.swift
//  SoccerBeat
//
//  Created by Henry's Mac on 8/15/24.
//

import Foundation

//MARK: - AppStoreResponse
struct AppStoreResponse: Codable {
    let resultCount: Int
    let results: [AppStoreResult]
}

//MARK: - Result
struct AppStoreResult: Codable {
    let releaseNotes: String
    let releaseDate: String
    let version: String
}

private extension Bundle {
    var releaseVersionNumber: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

struct AppStoreUpdateChecker {
    static func isNewVersionAvailable() async -> Bool {
        guard
            let bundleID = Bundle.main.bundleIdentifier,
            let countryCode = Locale.current.language.region?.identifier,
            let currentVersionNumber = Bundle.main.releaseVersionNumber,
            let url = URL(string: "https://itunes.apple.com/lookup?bundleId=com.SoccerBeat.Guryongpo&country=KR")
        else { return false }
        print("---> url:", url)
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
            let appStoreResponse = try JSONDecoder().decode(AppStoreResponse.self, from: data)
            
            guard let latestVersionNumber = appStoreResponse.results.first?.version else {
                print("Error: no app with matching bundle ID found")
                return false
            }
            print("----> 최신 버전:", latestVersionNumber)
            print("----> 현재 버전:", currentVersionNumber)
            
            return isUpdateNeeded(latestVersion: latestVersionNumber, currentVersion: currentVersionNumber)
            
        } catch {
            return false
        }
    }
    
    private static func isUpdateNeeded(latestVersion: String, currentVersion: String) -> Bool {
        let splitLatestVersion = latestVersion.split(separator: ".").compactMap { Int($0) }
        let splitCurrentVersion = currentVersion.split(separator: ".").compactMap { Int($0) }
        let excludePatchVersion = 1
        
        for i in 0..<max(splitLatestVersion.count, splitCurrentVersion.count) - excludePatchVersion {
            let latest = i < splitLatestVersion.count ? splitLatestVersion[i] : 0
            let current = i < splitCurrentVersion.count ? splitCurrentVersion[i] : 0
            
            if latest > current { return true }
            if latest < current { return false }
        }
        return false
    }
    
}

