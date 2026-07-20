//
//  ContributionHeatmap.swift
//  GitHubStats
//
//  Created by João Pedro Volponi on 19/07/26.
//

import SwiftUI

/// Heatmap de contribuições: colunas = semanas, linhas = dias (domingo no topo,
/// como no GitHub). Tap num quadrado abre tooltip com data e contagem.
struct ContributionHeatmap: View {
    private let weeks: [[ContributionDay?]]
    private let monthLabels: [String?]

    private let cellSize: CGFloat = 15
    private let cellSpacing: CGFloat = 3.5
    private let monthRowHeight: CGFloat = 12

    @State private var appeared = false
    @State private var selection: Selection?

    private struct Selection: Equatable {
        let week: Int
        let row: Int
        let day: ContributionDay
    }

    init(days: [ContributionDay]) {
        (weeks, monthLabels) = Self.layout(days: days)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            weekdayGutter

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: cellSpacing) {
                    ForEach(weeks.indices, id: \.self) { weekIndex in
                        weekColumn(weekIndex)
                            .opacity(appeared ? 1 : 0)
                            .animation(
                                GPStyle.spring.delay(min(Double(weekIndex) * 0.012, 0.8)),
                                value: appeared
                            )
                            .zIndex(selection?.week == weekIndex ? 1 : 0)
                    }
                }
            }
            .defaultScrollAnchor(.trailing)
            .scrollClipDisabled()
        }
        .frame(height: monthRowHeight + 4 + 7 * cellSize + 6 * cellSpacing)
        .onAppear { appeared = true }
        .task(id: selection) {
            guard selection != nil else { return }
            try? await Task.sleep(for: .seconds(2.5))
            withAnimation(GPStyle.spring) { selection = nil }
        }
    }

    // MARK: - Subviews

    private var weekdayGutter: some View {
        VStack(alignment: .leading, spacing: 4) {
            Color.clear.frame(width: 26, height: monthRowHeight)
            VStack(spacing: cellSpacing) {
                ForEach(0..<7, id: \.self) { row in
                    Text(gutterLabel(for: row))
                        .font(.system(size: 9))
                        .foregroundStyle(GPColor.subtitle)
                        .frame(width: 26, height: cellSize, alignment: .leading)
                }
            }
        }
    }

    private func weekColumn(_ weekIndex: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(monthLabels[weekIndex] ?? "")
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(GPColor.subtitle)
                .fixedSize()
                .frame(width: cellSize, height: monthRowHeight, alignment: .leading)

            VStack(spacing: cellSpacing) {
                ForEach(0..<7, id: \.self) { row in
                    cell(week: weekIndex, row: row)
                }
            }
        }
    }

    @ViewBuilder
    private func cell(week: Int, row: Int) -> some View {
        if let day = weeks[week][row] {
            let isSelected = selection?.week == week && selection?.row == row
            RoundedRectangle(cornerRadius: 3.5, style: .continuous)
                .fill(GPColor.heatmapLevels[min(max(day.level, 0), 4)])
                .frame(width: cellSize, height: cellSize)
                .overlay(
                    RoundedRectangle(cornerRadius: 3.5, style: .continuous)
                        .strokeBorder(.white.opacity(isSelected ? 0.9 : 0), lineWidth: 1)
                )
                .zIndex(isSelected ? 1 : 0)
                .overlay(alignment: row < 2 ? .bottom : .top) {
                    if isSelected {
                        HeatmapTooltip(day: day)
                            .offset(y: row < 2 ? 42 : -42)
                    }
                }
                .onTapGesture {
                    withAnimation(GPStyle.spring) {
                        selection = isSelected ? nil : Selection(week: week, row: row, day: day)
                    }
                }
        } else {
            Color.clear.frame(width: cellSize, height: cellSize)
        }
    }

    private func gutterLabel(for row: Int) -> String {
        switch row {
        case 1: "Seg"
        case 3: "Qua"
        case 5: "Sex"
        default: ""
        }
    }

    // MARK: - Layout dos dados

    /// Distribui os dias em colunas de 7 (domingo primeiro) e calcula o rótulo
    /// de mês exibido na primeira semana em que o mês aparece.
    private static func layout(days: [ContributionDay]) -> ([[ContributionDay?]], [String?]) {
        guard let first = days.first, let firstDate = ContributionDates.parse(first.date) else {
            return ([], [])
        }

        let leading = ContributionDates.calendar.component(.weekday, from: firstDate) - 1
        var cells: [ContributionDay?] = Array(repeating: nil, count: leading) + days
        while cells.count % 7 != 0 { cells.append(nil) }

        let weeks = stride(from: 0, to: cells.count, by: 7).map {
            Array(cells[$0..<$0 + 7])
        }

        var labels: [String?] = []
        var lastMonth = ""
        for week in weeks {
            guard let day = week.compactMap({ $0 }).first else {
                labels.append(nil)
                continue
            }
            let month = String(day.date.prefix(7))
            if month != lastMonth {
                let monthNumber = Int(month.suffix(2)) ?? 1
                labels.append(ContributionDates.shortMonths[(monthNumber - 1) % 12])
                lastMonth = month
            } else {
                labels.append(nil)
            }
        }
        return (weeks, labels)
    }
}

private struct HeatmapTooltip: View {
    let day: ContributionDay

    var body: some View {
        VStack(spacing: 1) {
            Text(contributionText)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(GPColor.text)
            Text(dateText)
                .font(.system(size: 10))
                .foregroundStyle(GPColor.subtitle)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(hex: "222229"), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .strokeBorder(GPColor.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.4), radius: 8, y: 3)
        .fixedSize()
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }

    private var contributionText: String {
        switch day.count {
        case 0: "Sem contribuições"
        case 1: "1 contribuição"
        default: "\(day.count) contribuições"
        }
    }

    private var dateText: String {
        guard let date = ContributionDates.parse(day.date) else { return day.date }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "d 'de' MMM 'de' yyyy"
        return formatter.string(from: date)
    }
}

/// Legenda "Menos → Mais" com os 5 níveis de intensidade.
struct HeatmapLegend: View {
    var body: some View {
        HStack(spacing: 4) {
            Text("Menos")
                .font(.system(size: 10))
                .foregroundStyle(GPColor.subtitle)
            ForEach(GPColor.heatmapLevels.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                    .fill(GPColor.heatmapLevels[index])
                    .frame(width: 10, height: 10)
            }
            Text("Mais")
                .font(.system(size: 10))
                .foregroundStyle(GPColor.subtitle)
        }
    }
}
