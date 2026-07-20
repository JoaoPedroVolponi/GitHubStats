//
//  SafariView.swift
//  GitHubStats
//
//  Created by João Pedro Volponi on 19/07/26.
//

import SwiftUI
import SafariServices
import UIKit

struct SafariItem: Identifiable {
    let url: URL

    var id: String { url.absoluteString }

    init?(_ string: String) {
        guard let url = URL(string: string) else { return nil }
        self.url = url
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        controller.preferredBarTintColor = UIColor(GPColor.background)
        controller.preferredControlTintColor = UIColor(GPColor.primaryBright)
        return controller
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
