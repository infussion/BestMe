//
//  DashboardView.swift
//  BestMe
//
//  Created by Todd Maiorano on 5/22/25.
//


import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: EntryViewModel

    var body: some View {
        VStack {
            Text("🗓 \(formattedDate(viewModel.currentDate))")
                .font(.title)

            VStack(spacing: 4) {
                Text("Daily Status: \(viewModel.dailyStatusEmoji())")
                    .font(.largeTitle)

                RoundedRectangle(cornerRadius: 4)
                    .fill(viewModel.dailyStatusColor())
                    .frame(height: 10)
                    .padding(.horizontal, 50)
            }
            .padding(.bottom, 16)

            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                ForEach(viewModel.entries) { entry in
                    VStack {
                        Text(entry.icon)
                            .font(.largeTitle)
                        Text(entry.name)
                        Text(entry.selectedMood?.emoji ?? "❔")
                            .font(.system(size: 40))
                            .onTapGesture {
                                toggleMood(for: entry)
                            }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).stroke())
                }
            }

            Button("Save Today's Entry") {
                viewModel.saveTodayRecord()
            }
            .padding()
        }
        .padding()
    }

    func formattedDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: date)
    }

    func toggleMood(for entry: Entry) {
        guard let index = viewModel.entries.firstIndex(where: { $0.id == entry.id }) else { return }
        let current = viewModel.entries[index].selectedMood
        let allCases = MoodEmoji.allCases
        let nextIndex = (allCases.firstIndex(of: current ?? .angry) ?? -1) + 1
        let newMood = allCases[nextIndex % allCases.count]
        viewModel.setMood(for: entry, mood: newMood)
    }
}
