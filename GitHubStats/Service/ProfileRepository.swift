//
//  ProfileRepository.swift
//  GitHubStats
//
//  Created by João Pedro Volponi on 19/07/26.
//

import Foundation

enum SearchKind: String {
    case pullRequests = "pr"
    case issues = "issue"
}

protocol ProfileRepository {
    func user(named username: String) async throws -> GitHubUser
    func repositories(for username: String) async throws -> [GitHubRepo]
    func contributions(for username: String, range: ContributionRange) async throws -> [ContributionDay]
    func searchCount(for username: String, kind: SearchKind) async throws -> Int
}

final class GitHubProfileRepository: ProfileRepository {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func user(named username: String) async throws -> GitHubUser {
        try await client.get(GitHubUser.self, from: githubURL(path: "/users/\(escaped(username))"))
    }

    func repositories(for username: String) async throws -> [GitHubRepo] {
        let url = githubURL(
            path: "/users/\(escaped(username))/repos",
            queryItems: [
                URLQueryItem(name: "per_page", value: "100"),
                URLQueryItem(name: "sort", value: "updated"),
            ]
        )
        return try await client.get([GitHubRepo].self, from: url)
    }

    func contributions(for username: String, range: ContributionRange) async throws -> [ContributionDay] {
        switch range {
        case .lastYear:
            return try await contributionDays(for: username, year: "last")
        case .all:
            return try await contributionDays(for: username, year: "all")
        case .twoYears:
            let year = Calendar.current.component(.year, from: Date())
            async let current = contributionDays(for: username, year: String(year))
            async let previous = contributionDays(for: username, year: String(year - 1))
            return try await previous + current
        }
    }

    func searchCount(for username: String, kind: SearchKind) async throws -> Int {
        let url = githubURL(
            path: "/search/issues",
            queryItems: [
                URLQueryItem(name: "q", value: "author:\(username) type:\(kind.rawValue)"),
                URLQueryItem(name: "per_page", value: "1"),
            ]
        )
        return try await client.get(SearchCount.self, from: url).totalCount
    }

    // MARK: - Helpers

    private func contributionDays(for username: String, year: String) async throws -> [ContributionDay] {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "github-contributions-api.jogruber.de"
        components.path = "/v4/\(escaped(username))"
        components.queryItems = [URLQueryItem(name: "y", value: year)]
        let response = try await client.get(ContributionsResponse.self, from: components.url!)
        return response.contributions
    }

    private func githubURL(path: String, queryItems: [URLQueryItem] = []) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = path
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        return components.url!
    }

    private func escaped(_ username: String) -> String {
        username.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? username
    }
}
