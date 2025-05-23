//
//  MoodEmoji.swift
//  BestMe
//
//  Created by Todd Maiorano on 5/22/25.
//


import Foundation

enum MoodEmoji: Int, Codable, CaseIterable {
    case happy = 2
    case content = 1
    case angry = 0

    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .content: return "😐"
        case .angry: return "😠"
        }
    }
}
