//  EntryViewModel.swift
//  BestMe
//
//  Created by Todd Maiorano on 5/22/25.
//

import Foundation
import SwiftUI

class EntryViewModel: ObservableObject {
    @Published var entries: [Entry] = [
        Entry(name: "Diet", icon: "🍽"),
        Entry(name: "Fitness", icon: "🏋️‍♂️"),
        Entry(name: "Weight", icon: "⚖️"),
        Entry(name: "Energy", icon: "⚡️"),
        Entry(name: "Family", icon: "👨‍👩‍👧‍👦"),
        Entry(name: "Business", icon: "💼"),
        Entry(name: "Vices", icon: "🚬"),
        Entry(name: "Mood", icon: "🙂"),
        Entry(name: "Custom", icon: "✍️")
    ]

    @Published var records: [DailyRecord] = []
    @Published var currentDate = Date()
    @Published var selectedRange: DateRange = .month
    @Published var selectedCategories: Set<String> = []

    enum DateRange: String, CaseIterable, Identifiable {
        case week = "Week"
        case month = "Month"
        case threeMonths = "3 Months"
        case sixMonths = "6 Months"
        case year = "1 Year"
        case all = "All"

        var id: String { rawValue }

        func startDate(from endDate: Date = Date()) -> Date {
            switch self {
            case .week: return Calendar.current.date(byAdding: .day, value: -7, to: endDate)!
            case .month: return Calendar.current.date(byAdding: .month, value: -1, to: endDate)!
            case .threeMonths: return Calendar.current.date(byAdding: .month, value: -3, to: endDate)!
            case .sixMonths: return Calendar.current.date(byAdding: .month, value: -6, to: endDate)!
            case .year: return Calendar.current.date(byAdding: .year, value: -1, to: endDate)!
            case .all: return Date.distantPast
            }
        }
    }

    var filteredRecords: [DailyRecord] {
        records.filter {
            $0.date >= selectedRange.startDate()
        }
    }

    func emojiScore(_ emoji: String) -> Int {
        switch emoji {
        case "😊": return 2
        case "😐": return 1
        case "😞": return 0
        default: return -1
        }
    }
}
