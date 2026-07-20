//
//  SearchField.swift
//  GitHubStats
//
//  Created by João Pedro Volponi on 19/07/26.
//

import SwiftUI

struct SearchField: View {
    @Binding var text: String
    var onSubmit: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(GPColor.subtitle)

            TextField("Digite um usuário do GitHub", text: $text)
                .font(.system(size: 16))
                .foregroundStyle(GPColor.text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.asciiCapable)
                .submitLabel(.search)
                .onSubmit(onSubmit)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(GPColor.subtitle)
                }
                .buttonStyle(.plain)
                .transition(.opacity.combined(with: .scale))
            }
        }
        .padding(.horizontal, 18)
        .frame(height: 56)
        .background(GPColor.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(GPColor.border, lineWidth: 1)
        )
        .animation(GPStyle.spring, value: text.isEmpty)
    }
}
