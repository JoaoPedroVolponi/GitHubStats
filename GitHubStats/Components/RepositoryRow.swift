//
//  RepositoryRow.swift
//  GitHubStats
//
//  Created by João Pedro Volponi on 19/07/26.
//

import SwiftUI

struct RepositoryRow: View {
    let repo: GitHubRepo
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(repo.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(GPColor.text)
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(GPColor.subtitle)
                }

                if let description = repo.description, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundStyle(GPColor.subtitle)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                HStack(spacing: 14) {
                    if let language = repo.language {
                        HStack(spacing: 5) {
                            Circle()
                                .fill(GPColor.language(language))
                                .frame(width: 8, height: 8)
                            Text(language)
                                .font(.system(size: 12))
                                .foregroundStyle(GPColor.subtitle)
                        }
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(GPColor.warning)
                        Text(repo.stargazersCount.gpFormatted)
                            .font(.system(size: 12))
                            .foregroundStyle(GPColor.subtitle)
                            .monospacedDigit()
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.branch")
                            .font(.system(size: 10))
                            .foregroundStyle(GPColor.subtitle)
                        Text(repo.forksCount.gpFormatted)
                            .font(.system(size: 12))
                            .foregroundStyle(GPColor.subtitle)
                            .monospacedDigit()
                    }
                }
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
