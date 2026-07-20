//
//  LoadingView.swift
//  GitHubStats
//
//  Created by João Pedro Volponi on 19/07/26.
//

import SwiftUI

/// Tela de carregamento: skeletons com shimmer + checklist das etapas async.
struct LoadingView: View {
    let completedSteps: Set<LoadStep>

    var body: some View {
        ScrollView {
            VStack(spacing: GPStyle.cardGap) {
                profileSkeleton
                statsSkeleton
                heatmapSkeleton
                checklist
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .scrollDisabled(true)
    }

    private var profileSkeleton: some View {
        skeletonCard {
            HStack(spacing: 14) {
                LoadingSkeleton(Circle())
                    .frame(width: 72, height: 72)

                VStack(alignment: .leading, spacing: 10) {
                    LoadingSkeleton(cornerRadius: 7)
                        .frame(width: 150, height: 18)
                    LoadingSkeleton(cornerRadius: 7)
                        .frame(width: 100, height: 13)
                }
                Spacer()
            }
        }
    }

    private var statsSkeleton: some View {
        skeletonCard {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                ForEach(0..<6, id: \.self) { _ in
                    LoadingSkeleton(cornerRadius: 14)
                        .frame(height: 62)
                }
            }
        }
    }

    private var heatmapSkeleton: some View {
        skeletonCard {
            VStack(alignment: .leading, spacing: 12) {
                LoadingSkeleton(cornerRadius: 7)
                    .frame(width: 120, height: 13)
                LoadingSkeleton(cornerRadius: 12)
                    .frame(height: 140)
            }
        }
    }

    private var checklist: some View {
        skeletonCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(GPColor.primaryBright)
                    Text("Obtendo informações...")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(GPColor.text)
                }

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(LoadStep.allCases) { step in
                        stepRow(step)
                    }
                }
            }
        }
    }

    private func stepRow(_ step: LoadStep) -> some View {
        let done = completedSteps.contains(step)
        return HStack(spacing: 10) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 16))
                .foregroundStyle(done ? GPColor.primaryBright : GPColor.subtitle.opacity(0.5))
                .contentTransition(.symbolEffect(.replace))

            Text(step.title)
                .font(.system(size: 14, weight: done ? .semibold : .regular))
                .foregroundStyle(done ? GPColor.text : GPColor.subtitle)
        }
        .animation(GPStyle.spring, value: done)
    }

    private func skeletonCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(GPStyle.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(GPColor.card, in: RoundedRectangle(cornerRadius: GPStyle.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GPStyle.cardRadius, style: .continuous)
                    .strokeBorder(GPColor.border, lineWidth: 1)
            )
    }
}
