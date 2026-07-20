//
//  DashboardView.swift
//  GitPulse
//

import SwiftUI

struct DashboardView: View {
    let viewModel: DashboardViewModel

    @State private var safariItem: SafariItem?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: GPStyle.cardGap) {
                ProfileCard(user: viewModel.user) {
                    safariItem = SafariItem(viewModel.user.htmlUrl)
                }
                .staggered(0)

                if let stats = viewModel.stats {
                    StatsGrid(
                        commits: stats.contributionsLastYear,
                        stars: stats.totalStars,
                        forks: stats.totalForks,
                        repositories: viewModel.user.publicRepos,
                        pullRequests: viewModel.prCount,
                        issues: viewModel.issueCount
                    )
                    .staggered(1)

                    contributionsCard
                        .staggered(2)

                    if !stats.languages.isEmpty {
                        LanguageDonutChart(languages: stats.languages)
                            .staggered(3)
                    }

                    EvolutionLineChart(
                        commits: stats.monthlyCommits,
                        repositories: stats.repoEvolution,
                        stars: stats.starEvolution
                    )
                    .staggered(4)

                    WeekdayActivityChart(counts: stats.weekdayCounts)
                        .staggered(5)

                    achievementsCard(stats)
                        .staggered(6)

                    insightsCard(stats)
                        .staggered(7)

                    if !stats.topRepos.isEmpty {
                        repositoriesCard(stats)
                            .staggered(8)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 44)
        }
        .sheet(item: $safariItem) { item in
            SafariView(url: item.url)
                .ignoresSafeArea()
        }
    }

    // MARK: - Contribuições

    private var contributionsCard: some View {
        GPCard(title: "Contribuições", icon: "square.grid.4x3.fill") {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    ForEach(ContributionRange.allCases) { range in
                        FilterChip(
                            title: range.title,
                            isSelected: viewModel.heatmapRange == range
                        ) {
                            Task { await viewModel.setHeatmapRange(range) }
                        }
                    }
                    Spacer()
                    if viewModel.isHeatmapLoading {
                        ProgressView()
                            .controlSize(.small)
                            .tint(GPColor.subtitle)
                    }
                }

                ContributionHeatmap(days: viewModel.heatmapDays)
                    .id(viewModel.heatmapRange)
                    .opacity(viewModel.isHeatmapLoading ? 0.4 : 1)
                    .animation(GPStyle.spring, value: viewModel.isHeatmapLoading)

                HStack {
                    Text("\(viewModel.heatmapTotal.gpFormatted) contribuições no período")
                        .font(.system(size: 12))
                        .foregroundStyle(GPColor.subtitle)
                    Spacer()
                    HeatmapLegend()
                }
            }
        }
    }

    // MARK: - Conquistas

    private func achievementsCard(_ stats: DashboardStats) -> some View {
        let unlockedCount = stats.achievements.filter(\.unlocked).count
        return GPCard(title: "Conquistas", icon: "trophy.fill") {
            VStack(alignment: .leading, spacing: 14) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    ForEach(stats.achievements) { achievement in
                        AchievementBadge(achievement: achievement)
                    }
                }

                Text("\(unlockedCount) de \(stats.achievements.count) desbloqueadas")
                    .font(.system(size: 12))
                    .foregroundStyle(GPColor.subtitle)
            }
        }
    }

    // MARK: - Insights

    private func insightsCard(_ stats: DashboardStats) -> some View {
        GPCard(title: "Insights", icon: "sparkles") {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(stats.insights) { insight in
                    InsightRow(insight: insight)
                }
            }
        }
    }

    // MARK: - Repositórios

    private func repositoriesCard(_ stats: DashboardStats) -> some View {
        GPCard(title: "Repositórios em Destaque", icon: "shippingbox.fill") {
            VStack(spacing: 0) {
                ForEach(Array(stats.topRepos.enumerated()), id: \.element.id) { index, repo in
                    RepositoryRow(repo: repo) {
                        safariItem = SafariItem(repo.htmlUrl)
                    }
                    if index < stats.topRepos.count - 1 {
                        Divider().overlay(GPColor.border.opacity(0.6))
                    }
                }
            }
        }
    }
}
