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
    @State private var locationManager = LocationManager()
    
    @State private var kpIndex: KpItem? = nil
    @State private var tonightKpIndexes: [KpItem] = []
    @State private var currentWindMagnitude: CurrentRTSWWindMagnitude?
    @State private var currentWindSpeed: CurrentRTSWWindSpped?
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea(.all)
                ScrollView {
                    VStack(spacing: 12) {
                        KpIndexCardView(kpIndex: kpIndex, tonightKpIndexes: tonightKpIndexes)
                            
                        SolarWindCardView(currentWindMagnitude: currentWindMagnitude, currentWindSpeed: currentWindSpeed)
                    }
                    .padding()
                }
            }
            .task {
                Task {
                    await reloadData()
                }
            }
            // Re-runs every time LocationManager publishes a new location.
            .task(id: locationManager.location) {
                guard let location = locationManager.location else { return }
                await getCurrentWeather(for: location)
            }
            .navigationBarTitle("Today")
            .toolbar {
                ToolbarItem {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Refresh", systemImage: "arrow.trianglehead.clockwise.rotate.90") {
                            Task {
                                await reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func reloadData() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        // Weather is loaded by .task(id:) once the new location arrives.
        locationManager.requestLocation()
        
//        let kpResult = await NetworkManager.getKp()
//        kpIndex = kpResult.getCurrentKpIndex()
//        tonightKpIndexes = kpResult.getIndexesForCurrentNight()
//        
//        let magResult = await NetworkManager.getRtswMagnitude()
//        currentWindMagnitude = magResult.getCurrentMagnitude()
//        
//        let windResult = await NetworkManager.getRtswWind()
//        currentWindSpeed = windResult.getCurrentSpeedAndDensity()
    }

    private func getCurrentWeather(for location: CLLocation) async {
        do {
            let currentWeather = try await WeatherService.shared.weather(for: location)
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
