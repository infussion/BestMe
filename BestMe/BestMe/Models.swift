//
//  Models.swift
//  BestMe
//
//  Created by Todd Maiorano on 5/22/25.
//

import Foundation

struct Entry: Identifiable, Codable {
    var id = UUID()
    var name: String
    var icon: String
    var selectedMood: MoodEmoji?
}

struct DailyRecord: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var entries: [Entry]
}
