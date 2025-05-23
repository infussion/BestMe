//  EntryViewModel.swift
//  BestMe
//
//  Created by Todd Maiorano on 5/22/25.
//

import Foundation
import SwiftUI
import PhotosUI

class EntryViewModel: ObservableObject {
    @Published var currentDate = Date()
    @Published var entries: [Entry] = []
    @Published var records: [DailyRecord] = []

    let defaultsKey = "SavedRecords"
    let entriesKey = "SavedEntries"

    init() {
        loadEntries()
        loadRecords()
    }

    func loadEntries() {
        let decoder = JSONDecoder()
        if let savedData = UserDefaults.standard.data(forKey: entriesKey),
           let loadedEntries = try? decoder.decode([Entry].self, from: savedData) {
            entries = loadedEntries
        } else {
            loadDefaultEntries()
        }
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
            Entry(name: "Custom", icon: "➕"),
            Entry(name: "Custom 2", icon: "➕"),
            Entry(name: "Custom 3", icon: "➕"),
            Entry(name: "Custom 4", icon: "➕")
        ]
        saveEntries()
    }

    func saveEntries() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(entries) {
            UserDefaults.standard.set(encoded, forKey: entriesKey)
        }
    }

    func loadEntriesForDate(_ date: Date) {
        if let record = getRecord(for: date) {
            for (index, entry) in entries.enumerated() {
                if let savedEntry = record.entries.first(where: { $0.name == entry.name }) {
                    entries[index].selectedMood = savedEntry.selectedMood
                    entries[index].notes = savedEntry.notes
                    entries[index].mediaURLs = savedEntry.mediaURLs
                } else {
                    entries[index].selectedMood = nil
                    entries[index].notes = ""
                    entries[index].mediaURLs = []
                }
            }
        } else {
            for index in entries.indices {
                entries[index].selectedMood = nil
                entries[index].notes = ""
                entries[index].mediaURLs = []
            }
        }
    }

    func setMood(for entry: Entry, mood: Int?) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index].selectedMood = mood
        }
    }

    func setNotes(for entry: Entry, notes: String) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index].notes = notes
        }
    }

    func addMedia(for entry: Entry, mediaData: Data, fileExtension: String) -> Bool {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else { return false }

        // Get the document directory
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return false }

        // Create a unique file name
        let fileName = UUID().uuidString + fileExtension
        let fileURL = documentsURL.appendingPathComponent(fileName)

        // Save the media data to the file
        do {
            try mediaData.write(to: fileURL)
            entries[index].mediaURLs.append(fileURL)
            saveEntries()
            return true
        } catch {
            print("Error saving media: \(error)")
            return false
        }
    }

    func dailyStatusEmoji() -> String {
        let moods = entries.compactMap { $0.selectedMood }.filter { $0 != 0 }
        guard !moods.isEmpty else { return "❓" }

        let average = Double(moods.reduce(0, +)) / Double(moods.count)
        let roundedAverage = Int(round(average))
        return MoodEmojiMapper.emoji(for: roundedAverage)
    }

    func dailyStatusColor() -> Color {
        let moods = entries.compactMap { $0.selectedMood }.filter { $0 != 0 }
        guard !moods.isEmpty else { return .gray }

        let average = Double(moods.reduce(0, +)) / Double(moods.count)

        switch average {
        case 1..<4:
            return .red
        case 4..<7:
            return .yellow
        case 7...10:
            return .green
        default:
            return .gray
        }
    }

    func saveTodayRecord() {
        let newRecord = DailyRecord(date: currentDate, entries: entries)
        if let index = records.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: currentDate) }) {
            records[index] = newRecord
        } else {
            records.append(newRecord)
        }
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
