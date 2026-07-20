//
//  HomeViewModel.swift
//  GitHubStats
//
//  Created by João Pedro Volponi on 19/07/26.
//

import Foundation
import Observation

@Observable
final class HomeViewModel {
    var username = ""
    private(set) var isChecking = false
    private(set) var errorMessage: String?

    private let repository: any ProfileRepository

    init(repository: any ProfileRepository = GitHubProfileRepository()) {
        self.repository = repository
    }

    func clearError() {
        errorMessage = nil
    }

    /// Valida o usuário na API antes de navegar; retorna o perfil quando encontrado.
    func analyze() async -> GitHubUser? {
        let name = username
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "@", with: "")
        guard !name.isEmpty else {
            errorMessage = "Digite um usuário para analisar."
            return nil
        }

        isChecking = true
        errorMessage = nil
        defer { isChecking = false }

        do {
            return try await repository.user(named: name)
        } catch let error as APIError {
            errorMessage = error.errorDescription
            return nil
        } catch {
            errorMessage = APIError.network.errorDescription
            return nil
        }
    }
}
