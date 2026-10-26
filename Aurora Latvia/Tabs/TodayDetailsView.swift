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
                    VStack(spacing: 12) {
                        KpIndexCardView(kpIndex: kpIndex, tonightKpIndexes: tonightKpIndexes)
                            
                        VStack(spacing: 20) {
                            HStack(spacing: 10) {
                                Image(systemName: "wind")
                                    .foregroundStyle(.mainOrange)
                                    .frame(width: 30, height: 30)
                                    .background(.secondaryOrange)
                                    .cornerRadius(12)
                                
                                Text("Solar Wind now")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(.cardText)
                                
                                Spacer()
                            }
                        }
                        .padding()
                        .background(.cardBackground)
                        .cornerRadius(26)
                    }
                    .padding()
                }
            }
            .task {
                Task {
                    let kpResult = await NetworkManager.getKp()
                    kpIndex = kpResult.getCurrentKpIndex()
                    tonightKpIndexes = kpResult.getIndexesForCurrentNight()
                    
                    let magResult = await NetworkManager.getRtswMagnitude()
                    print(magResult.filter(\.isActive))
                    
                    let windResult = await NetworkManager.getRtswWind()
                    print(windResult.filter(\.isActive))
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
