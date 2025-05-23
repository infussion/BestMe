//
//  Models.swift
//  BestMe
//
//  Created by Todd Maiorano on 5/22/25.
//

import Foundation
import SwiftUI
import PhotosUI

struct Entry: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var icon: String
    var selectedMood: Int? // 0-10, where 0 is "❔"
    var notes: String // New field for custom notes
    var mediaURLs: [URL] // New field for storing media file URLs

    init(name: String, icon: String) {
        self.name = name
        self.icon = icon
        self.notes = ""
        self.mediaURLs = []
    }

    // Custom coding keys to handle Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, name, icon, selectedMood, notes, mediaURLs
    }
}

struct DailyRecord: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var entries: [Entry]
}

// Helper to map mood values (0-10) to emoji faces
struct MoodEmojiMapper {
    static func emoji(for value: Int?) -> String {
        guard let value = value else { return "❔" }
        switch value {
        case 0: return "❔"  // Unset/nil mood
        case 1: return "😭"  // Very sad
        case 2: return "😢"  // Sad
        case 3: return "😟"  // Worried
        case 4: return "😕"  // Slightly sad
        case 5: return "😐"  // Neutral
        case 6: return "🙂"  // Slightly happy
        case 7: return "😊"  // Happy
        case 8: return "😄"  // Very happy
        case 9: return "😁"  // Excited
        case 10: return "🤩" // Ecstatic
        default: return "❔"  // Fallback
        }
    }
}
