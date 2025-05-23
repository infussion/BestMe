//
//  BestMeApp.swift
//  BestMe
//
//  Created by Todd Maiorano on 5/22/25.
//

import SwiftUI

@main
struct BestMeApp: App {
    @StateObject var viewModel = EntryViewModel()

    var body: some Scene {
        WindowGroup {
            TabView {
                DashboardView(viewModel: viewModel)
                    .tabItem {
                        Label("Dashboard", systemImage: "house.fill")
                    }

                CalendarView(viewModel: viewModel)
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                TrendView(viewModel: viewModel)
                    .tabItem {
                        Label("Trends", systemImage: "graph")
                    }
            }
        }
    }
}

