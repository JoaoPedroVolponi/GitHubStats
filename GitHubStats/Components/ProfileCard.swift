//
//  ProfileCard.swift
//  GitHubStats
//
//  Created by João Pedro Volponi on 19/07/26.
//

import SwiftUI

struct ProfileCard: View {
    let user: GitHubUser
    var onOpenProfile: () -> Void

    var body: some View {
        GPCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 14) {
                    AvatarImage(urlString: user.avatarUrl, size: 72)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(user.displayName)
                            .font(.system(size: 21, weight: .bold))
                            .foregroundStyle(GPColor.text)
                            .lineLimit(1)
                        Text("@\(user.login)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(GPColor.secondary)
                    }
                }

                if let bio = user.bio, !bio.isEmpty {
                    Text(bio)
                        .font(.system(size: 15))
                        .foregroundStyle(GPColor.text.opacity(0.9))
                        .lineSpacing(3)
                }

                let metadata = metadataRows
                if !metadata.isEmpty {
                    VStack(alignment: .leading, spacing: 7) {
                        ForEach(metadata, id: \.text) { row in
                            HStack(spacing: 8) {
                                Image(systemName: row.icon)
                                    .font(.system(size: 12))
                                    .foregroundStyle(GPColor.subtitle)
                                    .frame(width: 16)
                                Text(row.text)
                                    .font(.system(size: 13))
                                    .foregroundStyle(GPColor.subtitle)
                                    .lineLimit(1)
                            }
                        }
                    }
                }

                Divider().overlay(GPColor.border)

                HStack {
                    profileStat(value: user.followers.gpFormatted, label: "Seguidores")
                    Spacer()
                    profileStat(value: user.following.gpFormatted, label: "Seguindo")
                    Spacer()
                    profileStat(value: user.publicRepos.gpFormatted, label: "Repositórios")
                    Spacer()
                    profileStat(value: String(user.memberSinceYear), label: "No GitHub desde")
                }

                Button(action: onOpenProfile) {
                    HStack(spacing: 8) {
                        Text("Abrir Perfil no GitHub")
                            .font(.system(size: 15, weight: .semibold))
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(GPColor.text)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        GPColor.elevated,
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(GPColor.border, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var metadataRows: [(icon: String, text: String)] {
        var rows: [(String, String)] = []
        if let company = user.company, !company.isEmpty {
            rows.append(("building.2", company))
        }
        if let location = user.location, !location.isEmpty {
            rows.append(("mappin.and.ellipse", location))
        }
        if let website = user.website {
            rows.append(("link", website))
        }
        return rows
    }

    private func profileStat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(GPColor.text)
                .monospacedDigit()
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(GPColor.subtitle)
        }
    }
}
