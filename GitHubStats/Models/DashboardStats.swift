//
//  DashboardStats.swift
//  GitHubStats
//
//  Created by João Pedro Volponi on 19/07/26.
//
//  Estatísticas derivadas no cliente a partir dos dados brutos das APIs.
//

import SwiftUI

struct LanguageShare: Identifiable {
    let name: String
    let count: Int
    let percent: Double

    var id: String { name }
    var color: Color { GPColor.language(name) }
}

struct ChartPoint: Identifiable {
    let label: String
    let value: Double

    var id: String { label + String(value) }
}

struct Achievement: Identifiable {
    let id: String
    let emoji: String
    let title: String
    let requirement: String
    let unlocked: Bool
}

struct Insight: Identifiable {
    let icon: String
    let text: String

    var id: String { text }
}

struct DashboardStats {
    let totalStars: Int
    let totalForks: Int
    let contributionsLastYear: Int
    let currentStreak: Int
    let longestStreak: Int
    /// Índice 0 = segunda ... 6 = domingo.
    let weekdayCounts: [Int]
    let monthlyCommits: [ChartPoint]
    let repoEvolution: [ChartPoint]
    let starEvolution: [ChartPoint]
    let languages: [LanguageShare]
    let distinctLanguageCount: Int
    let achievements: [Achievement]
    let insights: [Insight]
    let topRepos: [GitHubRepo]

    // MARK: - Build

    static func build(user: GitHubUser, repos: [GitHubRepo], lastYearDays: [ContributionDay]) -> DashboardStats {
        let totalStars = repos.reduce(0) { $0 + $1.stargazersCount }
        let totalForks = repos.reduce(0) { $0 + $1.forksCount }
        let contributionsLastYear = lastYearDays.reduce(0) { $0 + $1.count }
        let (currentStreak, longestStreak) = streaks(in: lastYearDays)
        let weekdayCounts = weekdayAggregation(of: lastYearDays)
        let languages = languageShares(of: repos)
        let distinctLanguages = Set(repos.compactMap(\.language)).count
        let topRepos = Array(repos.sorted { $0.stargazersCount > $1.stargazersCount }.prefix(10))

        let achievements = buildAchievements(
            user: user,
            totalStars: totalStars,
            totalForks: totalForks,
            longestStreak: longestStreak,
            distinctLanguages: distinctLanguages,
            contributionsLastYear: contributionsLastYear
        )

        let insights = buildInsights(
            user: user,
            repos: repos,
            languages: languages,
            weekdayCounts: weekdayCounts,
            longestStreak: longestStreak,
            contributionsLastYear: contributionsLastYear
        )

        return DashboardStats(
            totalStars: totalStars,
            totalForks: totalForks,
            contributionsLastYear: contributionsLastYear,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            weekdayCounts: weekdayCounts,
            monthlyCommits: monthlySeries(of: lastYearDays),
            repoEvolution: cumulativeSeries(of: repos) { _ in 1 },
            starEvolution: cumulativeSeries(of: repos) { $0.stargazersCount },
            languages: languages,
            distinctLanguageCount: distinctLanguages,
            achievements: achievements,
            insights: insights,
            topRepos: topRepos
        )
    }

    // MARK: - Derivações

    /// Streak atual e mais longo em dias consecutivos com contribuição.
    static func streaks(in days: [ContributionDay]) -> (current: Int, longest: Int) {
        var longest = 0
        var run = 0
        for day in days {
            if day.count > 0 {
                run += 1
                longest = max(longest, run)
            } else {
                run = 0
            }
        }

        var current = 0
        var index = days.count - 1
        // O dia de hoje ainda sem contribuição não quebra o streak.
        if index >= 0, days[index].count == 0 {
            index -= 1
        }
        while index >= 0, days[index].count > 0 {
            current += 1
            index -= 1
        }
        return (current, longest)
    }

    private static func weekdayAggregation(of days: [ContributionDay]) -> [Int] {
        var counts = Array(repeating: 0, count: 7)
        for day in days where day.count > 0 {
            guard let date = ContributionDates.parse(day.date) else { continue }
            counts[ContributionDates.mondayFirstIndex(of: date)] += day.count
        }
        return counts
    }

    private static func languageShares(of repos: [GitHubRepo]) -> [LanguageShare] {
        var counts: [String: Int] = [:]
        for repo in repos {
            guard let language = repo.language else { continue }
            counts[language, default: 0] += 1
        }
        let total = counts.values.reduce(0, +)
        guard total > 0 else { return [] }

        return counts
            .sorted { $0.value > $1.value || ($0.value == $1.value && $0.key < $1.key) }
            .prefix(8)
            .map { LanguageShare(name: $0.key, count: $0.value, percent: Double($0.value) / Double(total)) }
    }

    /// Contribuições agrupadas por mês (12 últimos meses).
    private static func monthlySeries(of days: [ContributionDay]) -> [ChartPoint] {
        var order: [String] = []
        var totals: [String: Int] = [:]
        for day in days {
            let month = String(day.date.prefix(7)) // "yyyy-MM"
            if totals[month] == nil { order.append(month) }
            totals[month, default: 0] += day.count
        }

        return order.suffix(12).map { month in
            let monthNumber = Int(month.suffix(2)) ?? 1
            let label = ContributionDates.shortMonths[(monthNumber - 1) % 12]
            return ChartPoint(label: label, value: Double(totals[month] ?? 0))
        }
    }

    /// Série acumulada mês a mês a partir da data de criação de cada repositório.
    /// Aproximação honesta: a API não fornece o histórico real desses totais.
    private static func cumulativeSeries(of repos: [GitHubRepo], weight: (GitHubRepo) -> Int) -> [ChartPoint] {
        let sorted = repos.sorted { $0.createdAt < $1.createdAt }
        guard let firstDate = sorted.first?.createdAt else { return [] }

        let calendar = ContributionDates.calendar
        var month = calendar.date(from: calendar.dateComponents([.year, .month], from: firstDate))!
        let now = Date()
        var points: [ChartPoint] = []
        var cumulative = 0
        var index = 0

        while month <= now {
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: month)!
            while index < sorted.count, sorted[index].createdAt < nextMonth {
                cumulative += weight(sorted[index])
                index += 1
            }
            let year = calendar.component(.year, from: month)
            points.append(ChartPoint(label: String(year), value: Double(cumulative)))
            month = nextMonth
        }

        if points.count == 1, let only = points.first {
            points.append(ChartPoint(label: only.label + " ", value: only.value))
        }
        return points
    }

    // MARK: - Conquistas e insights

    private static func buildAchievements(
        user: GitHubUser,
        totalStars: Int,
        totalForks: Int,
        longestStreak: Int,
        distinctLanguages: Int,
        contributionsLastYear: Int
    ) -> [Achievement] {
        [
            Achievement(id: "streak", emoji: "🔥", title: "Consistente",
                        requirement: "Streak de 7+ dias", unlocked: longestStreak >= 7),
            Achievement(id: "stars", emoji: "⭐", title: "Popular",
                        requirement: "100+ estrelas", unlocked: totalStars >= 100),
            Achievement(id: "repos", emoji: "🚀", title: "Explorer",
                        requirement: "20+ repositórios", unlocked: user.publicRepos >= 20),
            Achievement(id: "languages", emoji: "💻", title: "Polyglot",
                        requirement: "5+ linguagens", unlocked: distinctLanguages >= 5),
            Achievement(id: "forks", emoji: "🧠", title: "Open Source",
                        requirement: "20+ forks", unlocked: totalForks >= 20),
            Achievement(id: "contributions", emoji: "🏆", title: "Top Contributor",
                        requirement: "1000+ contribuições/ano", unlocked: contributionsLastYear >= 1000),
        ]
    }

    private static func buildInsights(
        user: GitHubUser,
        repos: [GitHubRepo],
        languages: [LanguageShare],
        weekdayCounts: [Int],
        longestStreak: Int,
        contributionsLastYear: Int
    ) -> [Insight] {
        var insights: [Insight] = []

        if let top = languages.first {
            let plural = top.count == 1 ? "repositório" : "repositórios"
            insights.append(Insight(
                icon: "chevron.left.forwardslash.chevron.right",
                text: "\(top.name) é a linguagem principal, presente em \(top.count) \(plural)."
            ))
        }

        if let maxCount = weekdayCounts.max(), maxCount > 0,
           let maxIndex = weekdayCounts.firstIndex(of: maxCount) {
            let day = ContributionDates.fullWeekdays[maxIndex].capitalized
            insights.append(Insight(
                icon: "calendar",
                text: "\(day) é o dia da semana com mais contribuições."
            ))
        }

        if let topRepo = repos.max(by: { $0.stargazersCount < $1.stargazersCount }),
           topRepo.stargazersCount > 0 {
            insights.append(Insight(
                icon: "star.fill",
                text: "\(topRepo.name) é o repositório mais popular, com \(topRepo.stargazersCount.gpFormatted) estrelas."
            ))
        }

        if longestStreak > 1 {
            insights.append(Insight(
                icon: "flame.fill",
                text: "Maior sequência: \(longestStreak) dias seguidos contribuindo."
            ))
        }

        let currentYear = Calendar.current.component(.year, from: Date())
        let reposThisYear = repos.filter {
            Calendar.current.component(.year, from: $0.createdAt) == currentYear
        }.count
        if reposThisYear > 0 {
            let plural = reposThisYear == 1 ? "repositório criado" : "repositórios criados"
            insights.append(Insight(
                icon: "plus.circle.fill",
                text: "\(reposThisYear) \(plural) em \(String(currentYear))."
            ))
        }

        insights.append(Insight(
            icon: "chart.bar.fill",
            text: "\(contributionsLastYear.gpFormatted) contribuições nos últimos 12 meses."
        ))

        return insights
    }
}
