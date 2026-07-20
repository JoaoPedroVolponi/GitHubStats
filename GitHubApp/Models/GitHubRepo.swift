//
//  GitHubRepo.swift
//  GitPulse
//

import Foundation

struct GitHubRepo: Codable, Hashable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let language: String?
    let stargazersCount: Int
    let forksCount: Int
    let createdAt: Date
    let htmlUrl: String
    let fork: Bool
}

struct SearchCount: Codable {
    let totalCount: Int
}
