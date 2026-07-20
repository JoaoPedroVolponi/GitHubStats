//
//  DashboardContainerView.swift
//  GitPulse
//

import SwiftUI

/// Controla Loading → Dashboard → Erro e a navbar sticky com blur.
struct DashboardContainerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: DashboardViewModel

    init(user: GitHubUser) {
        _viewModel = State(initialValue: DashboardViewModel(user: user))
    }

    var body: some View {
        ZStack {
            GPColor.background.ignoresSafeArea()

            switch viewModel.phase {
            case .loading:
                LoadingView(completedSteps: viewModel.completedSteps)
                    .transition(.opacity)
            case .ready:
                DashboardView(viewModel: viewModel)
                    .transition(.opacity)
            case .failed(let message):
                ErrorStateView(message: message) {
                    Task { await viewModel.load() }
                }
                .transition(.opacity)
            }
        }
        .animation(GPStyle.spring, value: viewModel.phase)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(GPColor.text)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("@\(viewModel.user.login)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(GPColor.secondary)
            }
        }
        .toolbarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .task {
            await viewModel.load()
        }
    }
}

struct ErrorStateView: View {
    let message: String
    var onRetry: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(GPColor.warning)

            VStack(spacing: 8) {
                Text("Algo deu errado")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(GPColor.text)
                Text(message)
                    .font(.system(size: 14))
                    .foregroundStyle(GPColor.subtitle)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            PrimaryButton(title: "Tentar novamente", action: onRetry)
                .frame(maxWidth: 240)
        }
        .padding(32)
    }
}
