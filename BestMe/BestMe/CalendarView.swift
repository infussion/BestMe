//
//  CalendarView.swift
//  BestMe
//
//  Created by Todd Maiorano on 5/22/25.
//


import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: EntryViewModel

    var body: some View {
        List(viewModel.records) { record in
            HStack {
                Text(formattedDate(record.date))
                Spacer()
                let avgMood = averageMood(for: record)
                Text(avgMood.emoji)
            }
        }
    }

    func formattedDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: date)
    }

    func averageMood(for record: DailyRecord) -> MoodEmoji {
        let values = record.entries.compactMap { $0.selectedMood?.rawValue }
        let avg = values.reduce(0, +) / max(values.count, 1)
        return MoodEmoji(rawValue: avg) ?? .content
    }
}