//
//  PrimaryButton.swift
//  GitHubStats
//
//  Created by João Pedro Volponi on 19/07/26.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    var isLoading = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                HStack(spacing: 8) {
                    if let systemImage {
                        Image(systemName: systemImage)
                            .font(.system(size: 15, weight: .semibold))
                    }
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                }
                .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .tint(.white)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                GPColor.primary,
                in: RoundedRectangle(cornerRadius: GPStyle.buttonRadius, style: .continuous)
            )
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .animation(GPStyle.spring, value: isLoading)
    }
}
