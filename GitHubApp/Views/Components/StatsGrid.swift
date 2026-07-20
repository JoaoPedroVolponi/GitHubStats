//
//  StatsGrid.swift
//  GitPulse
//

import SwiftUI

/// Grid 3x2 do card Resumo, com count-up animado nos números.
struct StatsGrid: View {
    let commits: Int
    let stars: Int
    let forks: Int
    let repositories: Int
    let pullRequests: Int?
    let issues: Int?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        GPCard(title: "Resumo", icon: "square.grid.2x2.fill") {
            LazyVGrid(columns: columns, spacing: 12) {
                StatCell(label: "Commits", value: commits)
                StatCell(label: "Stars", value: stars)
                StatCell(label: "Forks", value: forks)
                StatCell(label: "Repositórios", value: repositories)
                StatCell(label: "Pull Requests", value: pullRequests)
                StatCell(label: "Issues", value: issues)
            }
        }
    }
}

struct StatCell: View {
    let label: String
    let value: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let value {
                CountUpText(value: value, font: .system(size: 22, weight: .bold))
                    .foregroundStyle(GPColor.text)
            } else {
                Text("—")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(GPColor.subtitle)
            }
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(GPColor.subtitle)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            GPColor.elevated.opacity(0.6),
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
    }
}
