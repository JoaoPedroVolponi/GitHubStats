//
//  GitHubStatsApp.swift
//  GitHubStats
//
//  Created by João Pedro Volponi on 19/07/26.
//

import SwiftUI

@main
struct GitHubStatsApp: App {
    init() {
        URLCache.shared = URLCache(
            memoryCapacity: 20 * 1024 * 1024,
            diskCapacity: 120 * 1024 * 1024
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
        }
    }
}
