//
//  HomeView.swift
//  GitPulse
//

import SwiftUI

struct HomeView: View {
    var onAnalyze: (GitHubUser) -> Void

    @State private var viewModel = HomeViewModel()
    @FocusState private var searchFocused: Bool

    var body: some View {
        ZStack {
            GPColor.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: 64)

                    LogoMark(size: 64)
                        .padding(.bottom, 24)

                    VStack(spacing: 10) {
                        Text("Visualize qualquer perfil do GitHub")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(GPColor.text)
                            .multilineTextAlignment(.center)

                        Text("Estatísticas, contribuições, linguagens e conquistas de qualquer usuário — em um painel só.")
                            .font(.system(size: 15))
                            .foregroundStyle(GPColor.subtitle)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }
                    .padding(.bottom, 30)

                    VStack(spacing: 14) {
                        SearchField(text: $viewModel.username, onSubmit: analyze)
                            .focused($searchFocused)
                        
                        if let error = viewModel.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 14))
                                Text(error)
                                    .font(.system(size: 13, weight: .medium))
                                    .multilineTextAlignment(.leading)
                            }
                            .foregroundStyle(GPColor.danger)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        PrimaryButton(title: "Analisar Perfil", isLoading: viewModel.isChecking) {
                            analyze()
                        }
                    }

                    Spacer(minLength: 48)

                    Text("Dados públicos via API do GitHub")
                        .font(.system(size: 12))
                        .foregroundStyle(GPColor.subtitle.opacity(0.7))
                        .padding(.bottom, 12)
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .toolbar(.hidden, for: .navigationBar)
        .animation(GPStyle.spring, value: viewModel.errorMessage)
        .onChange(of: viewModel.username) {
            viewModel.clearError()
        }
    }

    private func analyze() {
        searchFocused = false
        Task {
            if let user = await viewModel.analyze() {
                onAnalyze(user)
            }
        }
    }
}
