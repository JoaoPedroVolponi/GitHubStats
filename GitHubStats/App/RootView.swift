//
//  RootView.swift
//  GitHubStats
//
//  Created by João Pedro Volponi on 19/07/26.
//

import SwiftUI

/// Fluxo raiz: Splash → Home → Loading → Dashboard.
struct RootView: View {
    @State private var showSplash = true
    @State private var path: [GitHubUser] = []

    var body: some View {
        NavigationStack(path: $path) {
            HomeView { user in
                path.append(user)
            }
            .navigationDestination(for: GitHubUser.self) { user in
                DashboardContainerView(user: user)
            }
        }
        .tint(GPColor.text)
        .overlay {
            if showSplash {
                SplashView {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
                .transition(.opacity)
            }
        }
    }
}

#Preview {
    RootView()
        .preferredColorScheme(.dark)
}
