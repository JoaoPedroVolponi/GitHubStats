//
//  LanguageDonutChart.swift
//  GitPulse
//

import SwiftUI

/// Donut chart das linguagens mais frequentes + lista lateral com % e cor.
struct LanguageDonutChart: View {
    let languages: [LanguageShare]

    @State private var appeared = false

    var body: some View {
        GPCard(title: "Linguagens", icon: "curlybraces") {
            HStack(alignment: .center, spacing: 22) {
                donut
                legend
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.9, dampingFraction: 0.9).delay(0.15)) {
                appeared = true
            }
        }
    }

    private var donut: some View {
        ZStack {
            Circle()
                .stroke(GPColor.elevated, lineWidth: 16)

            ForEach(segments) { segment in
                Circle()
                    .trim(from: segment.start, to: appeared ? segment.end : segment.start)
                    .stroke(
                        segment.color,
                        style: StrokeStyle(lineWidth: 16, lineCap: .butt)
                    )
                    .rotationEffect(.degrees(-90))
            }

            if let top = languages.first {
                VStack(spacing: 1) {
                    Text(top.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(GPColor.text)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(percentText(top.percent))
                        .font(.system(size: 11))
                        .foregroundStyle(GPColor.subtitle)
                }
                .padding(.horizontal, 14)
            }
        }
        .frame(width: 128, height: 128)
        .padding(8)
    }

    private var legend: some View {
        VStack(alignment: .leading, spacing: 9) {
            ForEach(languages) { language in
                HStack(spacing: 8) {
                    Circle()
                        .fill(language.color)
                        .frame(width: 8, height: 8)
                    Text(language.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(GPColor.text)
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    Text(percentText(language.percent))
                        .font(.system(size: 12))
                        .foregroundStyle(GPColor.subtitle)
                        .monospacedDigit()
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private struct Segment: Identifiable {
        let id: String
        let start: CGFloat
        let end: CGFloat
        let color: Color
    }

    private var segments: [Segment] {
        let gap: CGFloat = languages.count > 1 ? 0.006 : 0
        var cursor: CGFloat = 0
        return languages.map { language in
            let start = cursor
            cursor += CGFloat(language.percent)
            return Segment(
                id: language.id,
                start: start + gap / 2,
                end: max(start + gap / 2, cursor - gap / 2),
                color: language.color
            )
        }
    }

    private func percentText(_ percent: Double) -> String {
        (percent * 100).formatted(
            .number.precision(.fractionLength(0...1)).locale(Locale(identifier: "pt_BR"))
        ) + "%"
    }
}
