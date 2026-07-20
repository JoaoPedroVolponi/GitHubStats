//
//  WeekdayActivityChart.swift
//  GitPulse
//

import SwiftUI

/// Barras por dia da semana (Seg–Dom); o dia mais ativo é destacado em verde.
struct WeekdayActivityChart: View {
    /// Índice 0 = segunda ... 6 = domingo.
    let counts: [Int]

    @State private var appeared = false

    private let chartHeight: CGFloat = 130

    var body: some View {
        GPCard(title: "Atividade Semanal", icon: "chart.bar.fill") {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .bottom, spacing: 10) {
                    ForEach(0..<7, id: \.self) { index in
                        bar(at: index)
                    }
                }
                .frame(height: chartHeight + 34)

                Text("Baseado nas contribuições dos últimos 12 meses.")
                    .font(.system(size: 11))
                    .foregroundStyle(GPColor.subtitle)
            }
        }
        .onAppear { appeared = true }
    }

    private func bar(at index: Int) -> some View {
        let maxCount = max(counts.max() ?? 1, 1)
        let isTop = counts[index] == maxCount && maxCount > 0
        let ratio = CGFloat(counts[index]) / CGFloat(maxCount)
        let height = max(chartHeight * ratio, 6)

        return VStack(spacing: 6) {
            Text(counts[index].gpFormatted)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(GPColor.subtitle)
                .monospacedDigit()
                .opacity(counts[index] > 0 ? 1 : 0)

            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(isTop ? AnyShapeStyle(barGradient) : AnyShapeStyle(GPColor.elevated))
                .frame(height: appeared ? height : 6)
                .animation(GPStyle.spring.delay(Double(index) * 0.05), value: appeared)

            Text(ContributionDates.shortWeekdays[index])
                .font(.system(size: 11, weight: isTop ? .bold : .regular))
                .foregroundStyle(isTop ? GPColor.text : GPColor.subtitle)
        }
        .frame(maxWidth: .infinity, alignment: .bottom)
    }

    private var barGradient: LinearGradient {
        LinearGradient(
            colors: [GPColor.primaryBright, GPColor.primary],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
