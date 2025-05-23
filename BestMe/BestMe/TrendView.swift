//
//  TrendView.swift
//  BestMe
//
//  Created by Todd Maiorano on 5/22/25.
//

import SwiftUI
import Charts

struct TrendView: View {
    @ObservedObject var viewModel: EntryViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Trend View")
                .font(.largeTitle)
                .bold()

            Picker("Range", selection: $viewModel.selectedRange) {
                ForEach(EntryViewModel.DateRange.allCases) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.entries, id: \.name) { entry in
                        Button(action: {
                            if viewModel.selectedCategories.contains(entry.name) {
                                viewModel.selectedCategories.remove(entry.name)
                            } else {
                                viewModel.selectedCategories.insert(entry.name)
                            }
                        }) {
                            Text(entry.icon)
                                .font(.title)
                                .padding()
                                .background(viewModel.selectedCategories.contains(entry.name) ? Color.blue.opacity(0.7) : Color.gray.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal)
            }

            Chart {
                ForEach(viewModel.filteredRecords) { record in
                    ForEach(record.entries.filter { viewModel.selectedCategories.isEmpty || viewModel.selectedCategories.contains($0.name) }, id: \.name) { entry in
                        if let emoji = entry.emoji {
                            LineMark(
                                x: .value("Date", record.date),
                                y: .value("Score", viewModel.emojiScore(emoji))
                            )
                            .foregroundStyle(by: .value("Category", entry.name))
                            .interpolationMethod(.catmullRom)
                        }
                    }
                }
            }
            .frame(height: 250)
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .onAppear {
            if viewModel.selectedCategories.isEmpty {
                viewModel.selectedCategories = Set(viewModel.entries.map { $0.name })
            }
        }
    }
}




