//
//  InsightRow.swift
//  GitPulse
//

import SwiftUI

struct InsightRow: View {
    let insight: Insight

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: insight.icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(GPColor.primaryBright)
                .frame(width: 30, height: 30)
                .background(
                    GPColor.primary.opacity(0.12),
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                )

            Text(insight.text)
                .font(.system(size: 14))
                .foregroundStyle(GPColor.text.opacity(0.92))
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
