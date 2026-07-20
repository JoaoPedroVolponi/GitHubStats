//
//  AchievementBadge.swift
//  GitHubStats
//
//  Created by João Pedro Volponi on 19/07/26.
//

import SwiftUI

struct AchievementBadge: View {
    let achievement: Achievement

    var body: some View {
        HStack(spacing: 12) {
            Text(achievement.emoji)
                .font(.system(size: 24))
                .frame(width: 46, height: 46)
                .background(
                    GPColor.elevated,
                    in: RoundedRectangle(cornerRadius: 13, style: .continuous)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(GPColor.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(achievement.requirement)
                    .font(.system(size: 11))
                    .foregroundStyle(GPColor.subtitle)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color(hex: "18181D"),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    achievement.unlocked ? GPColor.primary.opacity(0.4) : GPColor.border,
                    lineWidth: 1
                )
        )
        .opacity(achievement.unlocked ? 1 : 0.4)
        .saturation(achievement.unlocked ? 1 : 0.3)
    }
}
