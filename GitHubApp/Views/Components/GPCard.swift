//
//  GPCard.swift
//  GitPulse
//

import SwiftUI

/// Container padrão das seções do dashboard: fundo elevado, borda 1pt e sombra discreta.
struct GPCard<Content: View>: View {
    var title: String? = nil
    var icon: String? = nil
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let title {
                HStack(spacing: 7) {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(GPColor.subtitle)
                    }
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(GPColor.subtitle)
                        .textCase(.uppercase)
                        .kerning(0.6)
                }
            }
            content
        }
        .padding(GPStyle.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(GPColor.card, in: RoundedRectangle(cornerRadius: GPStyle.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: GPStyle.cardRadius, style: .continuous)
                .strokeBorder(GPColor.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 20, y: 8)
    }
}
