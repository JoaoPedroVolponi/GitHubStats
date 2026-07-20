//
//  CountUpText.swift
//  GitPulse
//

import SwiftUI

/// Número com count-up animado (easing cúbico, ~1.1s) ao entrar na tela.
struct CountUpText: View {
    let value: Int
    var font: Font = .system(size: 24, weight: .bold)
    var duration: Double = 1.1

    @State private var start: Date?
    @State private var finished = false

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: finished)) { context in
            Text(currentValue(at: context.date).gpFormatted)
        }
        .font(font)
        .monospacedDigit()
        .onAppear {
            if start == nil { start = Date() }
        }
        .task {
            try? await Task.sleep(for: .seconds(duration + 0.2))
            finished = true
        }
    }

    private func currentValue(at date: Date) -> Int {
        guard let start else { return 0 }
        let progress = min(max(date.timeIntervalSince(start) / duration, 0), 1)
        let eased = 1 - pow(1 - progress, 3)
        return Int((Double(value) * eased).rounded())
    }
}
