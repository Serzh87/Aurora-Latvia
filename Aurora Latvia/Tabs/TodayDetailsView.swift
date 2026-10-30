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
                            
                        VStack(spacing: 10) {
                            HStack(spacing: 10) {
                                Image(systemName: "wind")
                                    .foregroundStyle(.mainOrange)
                                    .frame(width: 30, height: 30)
                                    .background(.secondaryOrange, in: .rect(cornerRadius: 12))
                                
                                Text("Solar Wind now")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(.cardText)
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 8) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Bz")
                                        .font(.system(size: 12))
                                    
                                    if let currentWindMagnitude {
                                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                                            Text(currentWindMagnitude.bz.formatted(.number.precision(.fractionLength(0...1)))).font(.system(size: 28, weight: .bold))
                                                .foregroundStyle(currentWindMagnitude.windTone.valueColor)
                                            Text("nT").font(.system(size: 14, weight: .semibold))
                                        }
                                        
                                        Text(currentWindMagnitude.info)
                                            .font(.system(size: 12))
                                    } else {
                                        Text("-").font(.system(size: 28, weight: .bold))
                                            .foregroundStyle(.mainGray)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                .background(currentWindMagnitude?.windTone.backgroundColor ?? .secondaryGray, in: .rect(corners: .concentric(minimum: .fixed(12))))
                                .foregroundStyle(currentWindMagnitude?.windTone.textColor ?? .mainGrayLight)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Speed")
                                        .font(.system(size: 12))
                                    
                                    if let currentWindSpeed {
                                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                                            Text(currentWindSpeed.speed.formatted(.number.precision(.fractionLength(0)))).font(.system(size: 28, weight: .bold))
                                                .foregroundStyle(currentWindSpeed.windTone.valueColor)
                                            Text("km/s").font(.system(size: 14, weight: .semibold))
                                        }
                                        
                                        Text(currentWindSpeed.info)
                                            .font(.system(size: 12))
                                    } else {
                                        Text("-").font(.system(size: 28, weight: .bold))
                                            .foregroundStyle(.mainGray)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                .background(currentWindSpeed?.windTone.backgroundColor ?? .secondaryGray, in: .rect(corners: .concentric(minimum: .fixed(12))))
                                .foregroundStyle(currentWindSpeed?.windTone.textColor ?? .mainGrayLight)
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            
                            if let density = currentWindSpeed?.density, density >= 15 {
                                HStack {
                                    Image(systemName: "bolt")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.bolt)
                                        .frame(width: 16, height: 16)
                                    
                                    Text("Dense flow \(density.formatted(.number.precision(.fractionLength(0...1)))) p/cm³ - aurora may be brighter")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.secondaryCardText)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(.secondaryCardBackground, in: .rect(corners: .concentric(minimum: .fixed(12))))
                            }
                        }
                        .padding()
                        .background(.cardBackground, in: .rect(corners: .concentric(minimum: .fixed(24))))
                    }
                    .padding()
                }
            }
            .task {
                Task {
                    await reloadData()
                }
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

        let kpResult = await NetworkManager.getKp()
        kpIndex = kpResult.getCurrentKpIndex()
        tonightKpIndexes = kpResult.getIndexesForCurrentNight()
        
        let magResult = await NetworkManager.getRtswMagnitude()
        currentWindMagnitude = magResult.getCurrentMagnitude()
        
        let windResult = await NetworkManager.getRtswWind()
        currentWindSpeed = windResult.getCurrentSpeedAndDensity()
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
