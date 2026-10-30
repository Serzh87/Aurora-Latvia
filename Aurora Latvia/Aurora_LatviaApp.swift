//
//  Aurora_LatviaApp.swift
//  Aurora Latvia
//
//  Created by Sergey Klus on 18/10/2026.
//

import SwiftUI
import SwiftData

@main
struct Aurora_LatviaApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            TabView {
                TodayDetailsView()
                    .tabItem {
                        Label("Today", systemImage: "square.grid.2x2")
                    }
                
                ForecastView()
                    .tabItem {
                        Label("Forecast", systemImage: "chart.bar.xaxis")
                    }
                
                WindView()
                    .tabItem {
                        Label("Wind", systemImage: "wind")
                    }
                
                SunView()
                    .tabItem {
                        Label("Sun", systemImage: "sun.max")
                    }
            }
//            .tint(.selectedTabItem)
        }
//        .modelContainer(sharedModelContainer)
    }
}
