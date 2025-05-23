//
//  CalendarView.swift
//  BestMe
//
//  Created by Todd Maiorano on 5/22/25.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: EntryViewModel
    @State private var selectedDate: Date?
    
    var body: some View {
        ScrollView {
            VStack {
                // Month and Year Header
                Text(currentMonthYear())
                    .font(.title2)
                    .padding()
                
                // Days of the Week
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                    ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                
                // Calendar Days
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                    ForEach(daysInMonth(), id: \.self) { date in
                        if let date = date {
                            let record = viewModel.records.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
                            Button(action: {
                                selectedDate = date
                            }) {
                                Text(record != nil ? averageMood(for: record!).emoji : " ")
                                    .font(.system(size: 20))
                                    .frame(width: 40, height: 40)
                                    .background(record != nil ? Color.blue.opacity(0.1) : Color.clear)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                            }
                            .disabled(record == nil) // Disable buttons for days without records
                        } else {
                            Text("")
                                .frame(width: 40, height: 40)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Detail View for Selected Date
                if let selectedDate = selectedDate,
                   let record = viewModel.records.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Details for \(formattedDate(selectedDate))")
                            .font(.headline)
                            .padding(.top)
                        ForEach(record.entries) { entry in
                            HStack {
                                Text("\(entry.icon) \(entry.name)")
                                    .font(.subheadline)
                                Spacer()
                                Text(entry.selectedMood?.emoji ?? "❔")
                                    .font(.system(size: 20))
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.bottom)
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: date)
    }
    
    func averageMood(for record: DailyRecord) -> MoodEmoji {
        let values = record.entries.compactMap { $0.selectedMood?.rawValue }
        let avg = values.isEmpty ? 0.0 : Double(values.reduce(0, +)) / Double(values.count)
        switch avg {
        case 1.5...2.0:
            return .happy
        case 0.5..<1.5:
            return .content
        default:
            return .angry
        }
    }
    
    private func currentMonthYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }
    
    private func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        let today = Date()
        guard let _ = calendar.dateInterval(of: .month, for: today),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) else {
            return []
        }
        
        let daysInMonth = calendar.range(of: .day, in: .month, for: today)?.count ?? 0
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        return days
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(viewModel: EntryViewModel())
    }
}
