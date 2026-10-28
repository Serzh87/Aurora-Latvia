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
                                    
                                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                                        Text("-8").font(.system(size: 28, weight: .bold))
                                            .foregroundStyle(.mainGray)
                                        Text("nT").font(.system(size: 14, weight: .semibold))
                                    }
                                    
                                    Text("южный — хорошо")
                                        .font(.system(size: 12))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                .background(.secondaryGray, in: .rect(corners: .concentric(minimum: .fixed(12))))
                                .foregroundStyle(.mainGrayLight)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Speed")
                                        .font(.system(size: 12))
                                    
                                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                                        Text("520").font(.system(size: 28, weight: .bold))
                                            .foregroundStyle(.mainOrange)
                                        Text("km/s").font(.system(size: 14, weight: .semibold))
                                    }
                                    
                                    Text("быстрый — выше 500")
                                        .font(.system(size: 12))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                .background(.secondaryOrange, in: .rect(corners: .concentric(minimum: .fixed(12))))
                                .foregroundStyle(.mainOrangeLight)
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            
                            HStack {
                                Image(systemName: "bolt")
                                    .foregroundStyle(.bolt)
                                    .frame(width: 16, height: 16)
                                
                                Text("Dense flow \(18) p/cm³ - aurora may be brighter")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondaryCardText)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(.secondaryCardBackground, in: .rect(corners: .concentric(minimum: .fixed(12))))
                        }
                        .padding()
                        .background(.cardBackground, in: .rect(corners: .concentric(minimum: .fixed(24))))
                    }
                    .padding()
                }
            }
            .task {
                Task {
                    let kpResult = await NetworkManager.getKp()
                    kpIndex = kpResult.getCurrentKpIndex()
                    tonightKpIndexes = kpResult.getIndexesForCurrentNight()
//                    
//                    let magResult = await NetworkManager.getRtswMagnitude()
//                    print(magResult.filter(\.isActive))
//                    
//                    let windResult = await NetworkManager.getRtswWind()
//                    print(windResult.filter(\.isActive))
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

enum WindTone { case quiet, watch, good }

#Preview {
    TabView {
        TodayDetailsView()
            .tabItem {
                Label("Today", systemImage: "square.grid.2x2")
            }
    }
    .tint(.selectedTabItem)
}
