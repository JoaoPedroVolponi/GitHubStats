//
//  GitHubUser.swift
//  GitPulse
//

import Foundation

struct GitHubUser: Codable, Hashable {
    let login: String
    let name: String?
    let avatarUrl: String
    let bio: String?
    let company: String?
    let blog: String?
    let location: String?
    let followers: Int
    let following: Int
    let publicRepos: Int
    let createdAt: Date
    let htmlUrl: String

    var displayName: String {
        let trimmed = name?.trimmingCharacters(in: .whitespaces) ?? ""
        return trimmed.isEmpty ? login : trimmed
    }

    var website: String? {
        guard let blog, !blog.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
        return blog
    }

    var memberSinceYear: Int {
        Calendar(identifier: .gregorian).component(.year, from: createdAt)
    }
}
