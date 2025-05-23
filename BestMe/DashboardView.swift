//
//  DashboardView.swift
//  BestMe
//
//  Created by Todd Maiorano on 5/22/25.
//


import SwiftUI
import PhotosUI

struct DashboardView: View {
    @ObservedObject var viewModel: EntryViewModel
    @State private var isEditingCategory: Bool = false
    @State private var editingEntry: Entry?
    @State private var newCategoryName: String = ""
    @State private var selectedIcon: String = "➕"
    @State private var showIconPicker: Bool = false
    @State private var showMoodPicker: Bool = false
    @State private var selectedMoodValue: Double = 0.0
    @State private var moodEntry: Entry?
    @State private var notes: String = "" // For the notes field
    @State private var selectedMedia: [PhotosPickerItem] = [] // For media picking

    private let availableIcons = [
        "🍽", "🏋️‍♂️", "⚖️", "⚡️", "👨‍👩‍👧‍👦", "💼", "🚬", "🧠",
        "❤️", "🏠", "😴", "🎨", "📚", "🎵", "✈️", "👯", "🐾", "🐶", "🐱", "🎮", "🧘", "📖", "💻", "📈", "💰", "🩺", "🙏", "🌱", "🍳", "🍰", "⚽", "🏃", "🏊", "📺", "🛍️", "🌳", "🏞️", "🧹", "📦"
    ]

    var body: some View {
        VStack {
            DatePicker("Select Date", selection: $viewModel.currentDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .padding(.horizontal)
                .onChange(of: viewModel.currentDate) { oldDate, newDate in
                    viewModel.loadEntriesForDate(newDate)
                }

            VStack(spacing: 4) {
                Text("Daily Status: \(viewModel.dailyStatusEmoji())")
                    .font(.largeTitle)

                RoundedRectangle(cornerRadius: 4)
                    .fill(viewModel.dailyStatusColor())
                    .frame(height: 10)
                    .padding(.horizontal, 50)
            }
            .padding(.bottom, 16)

            ScrollView {
                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: 16) {
                    ForEach(viewModel.entries) { entry in
                        VStack {
                            Text(entry.icon)
                                .font(.system(size: 30))
                                .frame(width: 40, height: 40)
                            Text(entry.name)
                                .font(.caption)
                                .onTapGesture {
                                    editingEntry = entry
                                    newCategoryName = entry.name
                                    selectedIcon = entry.icon
                                    isEditingCategory = true
                                    showIconPicker = false
                                }
                            Text(MoodEmojiMapper.emoji(for: entry.selectedMood))
                                .font(.system(size: 40))
                                .frame(width: 50, height: 50)
                                .onTapGesture {
                                    moodEntry = entry
                                    selectedMoodValue = Double(entry.selectedMood ?? 0)
                                    notes = entry.notes // Load existing notes
                                    showMoodPicker = true
                                }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).stroke())
                    }
                }
            }

            Button("Save Today's Entry") {
                viewModel.saveTodayRecord()
            }
            .padding()
        }
        .padding()
        .onAppear {
            viewModel.loadEntriesForDate(viewModel.currentDate)
        }
        .sheet(isPresented: $isEditingCategory) {
            VStack {
                Text("Edit Category Name")
                    .font(.headline)
                    .padding()
                
                TextField("Category Name", text: $newCategoryName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                if showIconPicker {
                    Text("Choose an Icon")
                        .font(.subheadline)
                        .padding(.top)
                    
                    ScrollView(.horizontal) {
                        LazyHGrid(rows: [GridItem(.fixed(40))], spacing: 10) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Text(icon)
                                    .font(.system(size: 30))
                                    .padding(5)
                                    .background(selectedIcon == icon ? Color.gray.opacity(0.3) : Color.clear)
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        selectedIcon = icon
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 60)
                }

                HStack {
                    Button("Cancel") {
                        isEditingCategory = false
                        newCategoryName = ""
                        editingEntry = nil
                        showIconPicker = false
                        selectedIcon = "➕"
                    }
                    .padding()
                    
                    Button("Save") {
                        if let entry = editingEntry,
                           let index = viewModel.entries.firstIndex(where: { $0.id == entry.id }),
                           !newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty {
                            viewModel.entries[index].name = newCategoryName
                            if !showIconPicker {
                                showIconPicker = true
                            } else {
                                viewModel.entries[index].icon = selectedIcon
                                viewModel.saveEntries()
                                isEditingCategory = false
                                newCategoryName = ""
                                editingEntry = nil
                                showIconPicker = false
                                selectedIcon = "➕"
                            }
                        }
                    }
                    .padding()
                }
            }
            .padding()
        }
        .sheet(isPresented: $showMoodPicker) {
            VStack {
                Text("Set Mood for \(moodEntry?.name ?? "")")
                    .font(.headline)
                    .padding()

                // Mood Slider
                Text(MoodEmojiMapper.emoji(for: Int(selectedMoodValue)))
                    .font(.system(size: 50))
                    .padding()

                Slider(value: $selectedMoodValue, in: 0...10, step: 1) {
                    Text("Mood")
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text("10")
                }
                .padding()

                // Notes Field
                Text("Notes")
                    .font(.subheadline)
                    .padding(.top)
                TextEditor(text: $notes)
                    .frame(height: 100)
                    .padding(4)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))

                // Media Upload
                PhotosPicker(
                    selection: $selectedMedia,
                    maxSelectionCount: 10,
                    matching: .any(of: [.images, .videos])
                ) {
                    Text("Add Photos or Videos")
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                .onChange(of: selectedMedia) { newSelection in
                    Task {
                        for item in newSelection {
                            if let data = try? await item.loadTransferable(type: Data.self) {
                                // Determine file extension based on media type
                                let fileExtension = item.supportedContentTypes.first?.preferredFilenameExtension ?? ".dat"
                                if let entry = moodEntry {
                                    _ = viewModel.addMedia(for: entry, mediaData: data, fileExtension: ".\(fileExtension)")
                                }
                            }
                        }
                        selectedMedia = [] // Clear selection after upload
                    }
                }

                // Media Gallery
                if let entry = moodEntry, !entry.mediaURLs.isEmpty {
                    Text("Media Gallery")
                        .font(.subheadline)
                        .padding(.top)
                    ScrollView(.horizontal) {
                        LazyHGrid(rows: [GridItem(.fixed(100))], spacing: 10) {
                            ForEach(entry.mediaURLs, id: \.self) { url in
                                MediaThumbnailView(url: url)
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 120)
                }

                // Buttons
                HStack {
                    Button("Cancel") {
                        showMoodPicker = false
                        moodEntry = nil
                        selectedMoodValue = 0.0
                        notes = ""
                        selectedMedia = []
                    }
                    .padding()

                    Button("Save") {
                        if let entry = moodEntry {
                            let moodValue = Int(selectedMoodValue)
                            viewModel.setMood(for: entry, mood: moodValue == 0 ? nil : moodValue)
                            viewModel.setNotes(for: entry, notes: notes)
                        }
                        showMoodPicker = false
                        moodEntry = nil
                        selectedMoodValue = 0.0
                        notes = ""
                        selectedMedia = []
                    }
                    .padding()
                }
            }
            .padding()
        }
    }
}

// Custom view to display media thumbnails
struct MediaThumbnailView: View {
    let url: URL
    @State private var thumbnail: UIImage? = nil

    var body: some View {
        Group {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.gray.opacity(0.3)
                    .overlay(Text("Loading..."))
            }
        }
        .onAppear {
            loadThumbnail()
        }
    }

    private func loadThumbnail() {
        Task {
            if url.pathExtension.lowercased() == "mov" || url.pathExtension.lowercased() == "mp4" {
                // Generate thumbnail for video
                let asset = AVAsset(url: url)
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                if let cgImage = try? generator.copyCGImage(at: .zero, actualTime: nil) {
                    thumbnail = UIImage(cgImage: cgImage)
                }
            } else {
                // Load image
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    thumbnail = image
                }
            }
        }
    }
}
