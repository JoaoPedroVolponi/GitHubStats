//
//  AvatarImage.swift
//  GitPulse
//

import SwiftUI
import UIKit

/// Avatar circular com cache em disco via URLCache.
struct AvatarImage: View {
    let urlString: String
    var size: CGFloat = 72

    @State private var image: UIImage?

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity)
            } else {
                Circle().fill(GPColor.elevated)
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.4))
                    .foregroundStyle(GPColor.subtitle)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(GPColor.border, lineWidth: 1))
        .task(id: urlString) {
            guard image == nil else { return }
            let loaded = await ImageLoader.load(urlString)
            withAnimation(GPStyle.spring) { image = loaded }
        }
    }
}

enum ImageLoader {
    private static let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(
            memoryCapacity: 30 * 1024 * 1024,
            diskCapacity: 150 * 1024 * 1024
        )
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: configuration)
    }()

    static func load(_ urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString),
              let (data, _) = try? await session.data(from: url) else { return nil }
        return UIImage(data: data)
    }
}
