//
//  GPStyle.swift
//  GitHubStats
//
//  Created by João Pedro Volponi on 19/07/26.
//

import SwiftUI

enum GPStyle {
    static let cardRadius: CGFloat = 20
    static let cardPadding: CGFloat = 21
    static let cardGap: CGFloat = 17
    static let buttonRadius: CGFloat = 15

    static let spring = Animation.spring(response: 0.4, dampingFraction: 0.85)
}

extension Int {
    /// Formata para exibição: agrupado em pt-BR até 99.999, compacto (k/M) acima disso.
    var gpFormatted: String {
        let locale = Locale(identifier: "pt_BR")
        switch self {
        case 1_000_000...:
            return Self.trimmedDecimal(Double(self) / 1_000_000, locale: locale) + "M"
        case 100_000...:
            return Self.trimmedDecimal(Double(self) / 1_000, locale: locale) + "k"
        default:
            return formatted(.number.grouping(.automatic).locale(locale))
        }
    }

    private static func trimmedDecimal(_ value: Double, locale: Locale) -> String {
        let rounded = (value * 10).rounded() / 10
        if rounded == rounded.rounded() {
            return String(format: "%.0f", rounded)
        }
        return rounded.formatted(.number.precision(.fractionLength(1)).locale(locale))
    }
}

/// Fade + slide-up escalonado para os cards do dashboard.
struct StaggeredAppear: ViewModifier {
    let index: Int
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown ? 0 : 24)
            .onAppear {
                withAnimation(GPStyle.spring.delay(Double(index) * 0.06)) {
                    shown = true
                }
            }
    }
}

extension View {
    func staggered(_ index: Int) -> some View {
        modifier(StaggeredAppear(index: index))
    }
}
