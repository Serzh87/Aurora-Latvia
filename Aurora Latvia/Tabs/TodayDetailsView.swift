//
//  TodayDetailsView.swift
//  Aurora Latvia
//
//  Created by Sergey Klus on 18/10/2026.
//

import SwiftUI
import WeatherKit
import Charts

struct TodayDetailsView: View {
    @State private var kpIndex: KpItem?
    @State private var tonightKpIndexes: [KpItem] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea(.all)
                ScrollView {
                    KpIndexCardView(kpIndex: kpIndex, tonightKpIndexes: tonightKpIndexes)
                }
            }
            .task {
                Task {
                    let result = await NetworkManager.getKp()
                    kpIndex = result.getCurrentKpIndex()
                    tonightKpIndexes = result.getIndexesForCurrentNight()
//                    print(result)
//                    print(result.getIndexesForCurrentNight())
//                    print(kpIndex)
                }
            }
            .navigationBarTitle("Today", displayMode: .large)
        }
    }

    private func getCurrentWeatherAsync() {
        Task {
            await getCurrentWeather()
        }
    }
    
    private func getCurrentWeather() async {
        do {
            let currentWeather = try await WeatherService.shared.weather(for: CLLocation(latitude: .init(floatLiteral: 56.9463), longitude: .init(floatLiteral: 24.1051)))
            print(currentWeather)
        } catch {
            print(error)
        }
    }
}

#Preview {
    TabView {
        TodayDetailsView()
            .tabItem {
                Label("Today", systemImage: "square.grid.2x2")
            }
    }
    .tint(.selectedTabItem)
}
