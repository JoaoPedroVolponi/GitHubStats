//
//  EvolutionLineChart.swift
//  GitPulse
//

import SwiftUI

/// Card Evolução: linha com área preenchida e abas Commits / Repositórios / Stars
/// com swipe horizontal entre elas.
struct EvolutionLineChart: View {
    let commits: [ChartPoint]
    let repositories: [ChartPoint]
    let stars: [ChartPoint]

    @State private var selection: Series = .commits

    enum Series: Int, CaseIterable, Identifiable {
        case commits
        case repositories
        case stars

        var id: Int { rawValue }

        var title: String {
            switch self {
            case .commits: "Commits"
            case .repositories: "Repositórios"
            case .stars: "Stars"
            }
        }
    }

    var body: some View {
        GPCard(title: "Evolução", icon: "chart.xyaxis.line") {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    ForEach(Series.allCases) { series in
                        FilterChip(title: series.title, isSelected: selection == series) {
                            withAnimation(GPStyle.spring) { selection = series }
                        }
                    }
                }

                TabView(selection: $selection) {
                    LineAreaChart(points: commits).tag(Series.commits)
                    LineAreaChart(points: repositories).tag(Series.repositories)
                    LineAreaChart(points: stars).tag(Series.stars)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 190)

                Text(caption)
                    .font(.system(size: 11))
                    .foregroundStyle(GPColor.subtitle)
            }
        }
    }

    private var caption: String {
        switch selection {
        case .commits:
            "Contribuições por mês nos últimos 12 meses."
        case .repositories, .stars:
            "Acumulado aproximado pela data de criação de cada repositório."
        }
    }
}

/// Gráfico de linha com área em gradiente, desenhado com Path.
struct LineAreaChart: View {
    let points: [ChartPoint]

    @State private var progress: CGFloat = 0

    var body: some View {
        VStack(spacing: 8) {
            if points.count < 2 {
                Text("Sem dados suficientes")
                    .font(.system(size: 13))
                    .foregroundStyle(GPColor.subtitle)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                chartBody
                xAxis
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.15)) {
                progress = 1
            }
        }
        .onDisappear {
            progress = 0
        }
    }

    private var chartBody: some View {
        GeometryReader { geo in
            let positions = self.positions(in: geo.size)
            ZStack(alignment: .topLeading) {
                gridLines(in: geo.size)

                areaPath(positions, size: geo.size)
                    .fill(
                        LinearGradient(
                            colors: [GPColor.primary.opacity(0.35), GPColor.primary.opacity(0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(progress)

                linePath(positions)
                    .trimmedPath(from: 0, to: progress)
                    .stroke(
                        GPColor.primaryBright,
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                    )

                if let last = positions.last {
                    Circle()
                        .fill(GPColor.primaryBright)
                        .frame(width: 7, height: 7)
                        .position(last)
                        .opacity(progress >= 1 ? 1 : 0)
                        .animation(GPStyle.spring, value: progress)
                }

                Text(maxValue.gpFormatted)
                    .font(.system(size: 10))
                    .foregroundStyle(GPColor.subtitle)
                    .monospacedDigit()
            }
        }
    }

    private var xAxis: some View {
        HStack {
            Text(points.first?.label ?? "")
            Spacer()
            if points.count > 4 {
                Text(points[points.count / 2].label)
                Spacer()
            }
            Text(points.last?.label ?? "")
        }
        .font(.system(size: 10))
        .foregroundStyle(GPColor.subtitle)
    }

    // MARK: - Geometria

    private var maxValue: Int {
        Int(points.map(\.value).max() ?? 0)
    }

    private func positions(in size: CGSize) -> [CGPoint] {
        let maxY = max(points.map(\.value).max() ?? 1, 1)
        let stepX = size.width / CGFloat(points.count - 1)
        let topInset: CGFloat = 16
        let usableHeight = size.height - topInset

        return points.enumerated().map { index, point in
            CGPoint(
                x: CGFloat(index) * stepX,
                y: topInset + usableHeight * (1 - CGFloat(point.value / maxY))
            )
        }
    }

    private func linePath(_ positions: [CGPoint]) -> Path {
        var path = Path()
        guard let first = positions.first else { return path }
        path.move(to: first)
        for index in 1..<positions.count {
            let previous = positions[index - 1]
            let current = positions[index]
            let midpoint = CGPoint(x: (previous.x + current.x) / 2, y: (previous.y + current.y) / 2)
            path.addQuadCurve(to: midpoint, control: previous)
        }
        if let last = positions.last {
            path.addLine(to: last)
        }
        return path
    }

    private func areaPath(_ positions: [CGPoint], size: CGSize) -> Path {
        var path = linePath(positions)
        guard let last = positions.last, let first = positions.first else { return path }
        path.addLine(to: CGPoint(x: last.x, y: size.height))
        path.addLine(to: CGPoint(x: first.x, y: size.height))
        path.closeSubpath()
        return path
    }

    private func gridLines(in size: CGSize) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<4) { _ in
                Rectangle()
                    .fill(GPColor.border.opacity(0.55))
                    .frame(height: 0.5)
                Spacer()
            }
            Rectangle()
                .fill(GPColor.border.opacity(0.55))
                .frame(height: 0.5)
        }
    }
}
