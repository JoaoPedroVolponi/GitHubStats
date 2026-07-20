//
//  GPColor.swift
//  GitHubStats
//
//  Created by João Pedro Volponi on 19/07/26.
//

import SwiftUI

extension Color {
    init(hex: String) {
        var value: UInt64 = 0
        Scanner(string: hex.replacingOccurrences(of: "#", with: "")).scanHexInt64(&value)
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}

enum GPColor {
    static let background = Color(hex: "0B0B0D")
    static let card       = Color(hex: "141418")
    static let border     = Color(hex: "232328")
    static let primary    = Color(hex: "2EA043")
    static let secondary  = Color(hex: "58A6FF")
    static let warning    = Color(hex: "F7B731")
    static let danger     = Color(hex: "F85149")
    static let text       = Color.white
    static let subtitle   = Color(hex: "8B949E")

    /// Verde mais claro usado em gradientes e no traço dos gráficos.
    static let primaryBright = Color(hex: "39D353")

    /// Superfície elevada dentro de um card (chips, ícones, barras inativas).
    static let elevated = Color(hex: "1D1D23")

    static let heatmapLevels: [Color] = [
        Color(hex: "1C1C22"),
        Color(hex: "0E4429"),
        Color(hex: "1A7A37"),
        Color(hex: "26A641"),
        Color(hex: "39D353"),
    ]

    private static let languageColors: [String: Color] = [
        "TypeScript": Color(hex: "3178C6"),
        "JavaScript": Color(hex: "F1E05A"),
        "Python": Color(hex: "3572A5"),
        "Swift": Color(hex: "F05138"),
        "Go": Color(hex: "00ADD8"),
        "Java": Color(hex: "B07219"),
        "Rust": Color(hex: "DEA584"),
        "Kotlin": Color(hex: "A97BFF"),
        "C#": Color(hex: "178600"),
        "C++": Color(hex: "F34B7D"),
        "C": Color(hex: "555555"),
        "Ruby": Color(hex: "701516"),
        "PHP": Color(hex: "4F5D95"),
        "Shell": Color(hex: "89E051"),
        "HTML": Color(hex: "E34C26"),
        "CSS": Color(hex: "563D7C"),
        "Dart": Color(hex: "00B4AB"),
        "Objective-C": Color(hex: "438EFF"),
        "Vue": Color(hex: "41B883"),
        "Elixir": Color(hex: "6E4A7E"),
    ]

    static func language(_ name: String) -> Color {
        languageColors[name] ?? subtitle
    }
}
