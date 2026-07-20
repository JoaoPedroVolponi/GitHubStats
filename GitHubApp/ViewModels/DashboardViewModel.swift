//
//  DashboardViewModel.swift
//  GitPulse
//

import SwiftUI
import Observation

enum LoadStep: Int, CaseIterable, Identifiable {
    case profile
    case repositories
    case languages
    case contributions
    case stats

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .profile: "Perfil"
        case .repositories: "Repositórios"
        case .languages: "Linguagens"
        case .contributions: "Contribuições"
        case .stats: "Estatísticas"
        }
    }
}

@Observable
final class DashboardViewModel {
    enum Phase: Equatable {
        case loading
        case ready
        case failed(String)
    }

    let user: GitHubUser
    private let repository: any ProfileRepository

    private(set) var phase: Phase = .loading
    private(set) var completedSteps: Set<LoadStep> = []
    private(set) var stats: DashboardStats?
    private(set) var repos: [GitHubRepo] = []
    private(set) var prCount: Int?
    private(set) var issueCount: Int?

    private(set) var heatmapRange: ContributionRange = .lastYear
    private(set) var heatmapDays: [ContributionDay] = []
    private(set) var isHeatmapLoading = false

    init(user: GitHubUser, repository: any ProfileRepository = GitHubProfileRepository()) {
        self.user = user
        self.repository = repository
    }

    func load() async {
        phase = .loading
        heatmapRange = .lastYear
        completedSteps = []
        mark(.profile) // Perfil já veio validado da Home.

        do {
            async let reposTask = repository.repositories(for: user.login)
            async let daysTask = repository.contributions(for: user.login, range: .lastYear)
            async let prTask = repository.searchCount(for: user.login, kind: .pullRequests)
            async let issueTask = repository.searchCount(for: user.login, kind: .issues)

            let repos = try await reposTask
            self.repos = repos
            mark(.repositories)
            try? await Task.sleep(for: .milliseconds(250))
            mark(.languages)

            let days = try await daysTask
            heatmapDays = days
            mark(.contributions)

            // A Search API tem rate limit agressivo; falha vira "—" em vez de erro.
            prCount = try? await prTask
            issueCount = try? await issueTask

            stats = DashboardStats.build(user: user, repos: repos, lastYearDays: days)
            try? await Task.sleep(for: .milliseconds(300))
            mark(.stats)

            try? await Task.sleep(for: .milliseconds(400))
            phase = .ready
        } catch let error as APIError {
            phase = .failed(error.errorDescription ?? "Algo deu errado.")
        } catch {
            phase = .failed(APIError.network.errorDescription ?? "Algo deu errado.")
        }
    }

    func setHeatmapRange(_ range: ContributionRange) async {
        guard range != heatmapRange, !isHeatmapLoading else { return }
        let previous = heatmapRange
        heatmapRange = range
        isHeatmapLoading = true
        defer { isHeatmapLoading = false }

        do {
            heatmapDays = try await repository.contributions(for: user.login, range: range)
        } catch {
            heatmapRange = previous // mantém os dados atuais em caso de falha
        }
    }

    var heatmapTotal: Int {
        heatmapDays.reduce(0) { $0 + $1.count }
    }

    private func mark(_ step: LoadStep) {
        withAnimation(GPStyle.spring) {
            _ = completedSteps.insert(step)
        }
    }
}
