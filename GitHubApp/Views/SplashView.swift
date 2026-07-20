//
//  SplashView.swift
//  GitPulse
//

import SwiftUI

struct SplashView: View {
    var onFinished: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            GPColor.background.ignoresSafeArea()

            VStack(spacing: 22) {
                LogoMark(size: 112)

                VStack(spacing: 6) {
                    Text("GitPulse")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(GPColor.text)
                    Text("O pulso de qualquer perfil do GitHub")
                        .font(.system(size: 14))
                        .foregroundStyle(GPColor.subtitle)
                }
            }
            .scaleEffect(appeared ? 1 : 0.86)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.9)) {
                appeared = true
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.5))
            onFinished()
        }
    }
}
