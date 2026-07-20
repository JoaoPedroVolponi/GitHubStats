//
//  LogoMark.swift
//  GitPulse
//

import SwiftUI

/// Logo do app: raio branco sobre gradiente verde arredondado.
struct LogoMark: View {
    var size: CGFloat = 64

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color(hex: "1A7A37"), GPColor.primary, GPColor.primaryBright],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: "bolt.fill")
                    .font(.system(size: size * 0.42, weight: .semibold))
                    .foregroundStyle(.white)
            )
            .shadow(color: GPColor.primary.opacity(0.35), radius: size * 0.2, y: size * 0.07)
    }
}
