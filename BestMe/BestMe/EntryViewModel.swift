//
//  EntryViewModel.swift
//  BestMe
//
//  Created by Todd Maiorano on 5/22/25.
//


import Foundation
import SwiftUI

class EntryViewModel: ObservableObject {
    @Published var currentDate = Date()
    @Published var entries: [Entry] = []
    @Published var records: [DailyRecord] = []

    let defaultsKey = "SavedRecords"

    init() {
        loadDefaultEntries()
        loadRecords()
    }

    func loadDefaultEntries() {
        entries = [
            Entry(name: "Diet", icon: "🍽"),
            Entry(name: "Fitness", icon: "🏋️‍♂️"),
            Entry(name: "Weight", icon: "⚖️"),
            Entry(name: "Energy", icon: "⚡️"),
            Entry(name: "Family", icon: "👨‍👩‍👧‍👦"),
            Entry(name: "Business", icon: "💼"),
            Entry(name: "Vices", icon: "🚬"),
            Entry(name: "Mood", icon: "🧠"),
            Entry(name: "Custom", icon: "➕")
        ]
    }

    func setMood(for entry: Entry, mood: MoodEmoji) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index].selectedMood = mood
        }
    }

    func dailyStatusEmoji() -> String {
        let moods = entries.compactMap { $0.selectedMood?.rawValue }
        guard !moods.isEmpty else { return "❓" }

        let average = Double(moods.reduce(0, +)) / Double(moods.count)

        switch average {
        case 1.5...2.0:
            return MoodEmoji.happy.emoji
        case 0.5..<1.5:
            return MoodEmoji.content.emoji
        default:
            return MoodEmoji.angry.emoji
        }
    }

    func dailyStatusColor() -> Color {
        let moods = entries.compactMap { $0.selectedMood?.rawValue }
        guard !moods.isEmpty else { return .gray }

        let average = Double(moods.reduce(0, +)) / Double(moods.count)

        switch average {
        case 1.5...2.0:
            return .green
        case 0.5..<1.5:
            return .yellow
        default:
            return .red
        }
    }

    func saveTodayRecord() {
        let record = DailyRecord(date: currentDate, entries: entries)
        records.append(record)
        saveRecords()
    }

    func getRecord(for date: Date) -> DailyRecord? {
        return records.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })
    }

    func saveRecords() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(records) {
            UserDefaults.standard.set(encoded, forKey: defaultsKey)
        }
    }

    func loadRecords() {
        let decoder = JSONDecoder()
        if let savedData = UserDefaults.standard.data(forKey: defaultsKey),
           let loaded = try? decoder.decode([DailyRecord].self, from: savedData) {
            records = loaded
        }
    }
}
