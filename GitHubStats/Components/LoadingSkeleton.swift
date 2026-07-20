//
//  LoadingSkeleton.swift
//  GitHubStats
//
//  Created by João Pedro Volponi on 19/07/26.
//

import SwiftUI

/// Bloco de skeleton com shimmer: gradiente claro deslizando em loop sobre a forma.
struct LoadingSkeleton<S: Shape>: View {
    var shape: S
    @State private var phase: CGFloat = -1.5

    init(_ shape: S) {
        self.shape = shape
    }

    var body: some View {
        shape
            .fill(Color(hex: "1B1B20"))
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.10), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.8)
                    .offset(x: phase * geo.size.width)
                }
            )
            .clipShape(shape)
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 1.5
                }
            }
    }
}

extension LoadingSkeleton where S == RoundedRectangle {
    init(cornerRadius: CGFloat = 10) {
        self.init(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
