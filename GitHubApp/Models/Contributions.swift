//
//  Contributions.swift
//  GitPulse
//

import Foundation

struct ContributionsResponse: Codable {
    let total: [String: Int]?
    let contributions: [ContributionDay]
}

struct ContributionDay: Codable, Hashable, Identifiable {
    /// Formato "yyyy-MM-dd", em ordem cronológica na resposta da API.
    let date: String
    let count: Int
    let level: Int

    var id: String { date }
}

enum ContributionRange: String, CaseIterable, Identifiable {
    case lastYear
    case twoYears
    case all

    var id: String { rawValue }

    var title: String {
        switch self {
        case .lastYear: "Último ano"
        case .twoYears: "2 anos"
        case .all: "Todos"
        }
    }
}

enum ContributionDates {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func parse(_ day: String) -> Date? {
        formatter.date(from: day)
    }

    static let shortMonths = ["jan", "fev", "mar", "abr", "mai", "jun",
                              "jul", "ago", "set", "out", "nov", "dez"]

    static let shortWeekdays = ["Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom"]

    static let fullWeekdays = ["segunda-feira", "terça-feira", "quarta-feira",
                               "quinta-feira", "sexta-feira", "sábado", "domingo"]

    /// Índice 0 = segunda ... 6 = domingo, a partir do weekday do Calendar (1 = domingo).
    static func mondayFirstIndex(of date: Date) -> Int {
        (calendar.component(.weekday, from: date) + 5) % 7
    }
}
