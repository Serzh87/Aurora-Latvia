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
    @State private var kpIndex: KpItem? = KpItem(date: .now, kp: 5.624, observation: .estimated)
    @State private var tonightKpIndexes: [KpItem] = []
    
    private var kpValueColor: Color {
        guard let kpIndex else {
            return .mainValueGray
        }
        
        if kpIndex.kp >= 5 {
            return .mainValueGreen
        }
        
        if kpIndex.kp >= 4 && kpIndex.kp < 5 {
            return .mainValueOrange
        }
        
        return .mainValueGray
    }
    
    private func getKpValueColor(from kp: Float) -> Color {
        if kp >= 5 {
            return .mainValueGreen
        }
        
        if kp >= 4 && kp < 5 {
            return .mainValueOrange
        }
        
        return .mainValueGray
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea(.all)
                ScrollView {
                    
                    VStack(spacing: 20) {
                        HStack(spacing: 10) {
                            Image(systemName: "rays")
                                .foregroundStyle(Color.kpIndex)
                                .frame(width: 30, height: 30)
                                .background(.kpIndexBackground)
                                .cornerRadius(12)
                            
                            VStack(alignment: .leading) {
                                Text("Geomagnetic activity")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color.cardText)
                                
                                Text("Threshold: 5")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.cardTextSecondary)
                            }
                            
                            Spacer()
                            
                            if let kpIndex {
                                Text("Kp \(kpIndex.kp.formatted(.number.precision(.fractionLength(0...2))))")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(kpValueColor)
                            } else {
                                Text("Kp -")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(kpValueColor)
                            }
                        }
                        
                        if !tonightKpIndexes.isEmpty {
                            Chart {
                                RuleMark(y: .value("Threshold", 5))
                                    .foregroundStyle(.cardTextSecondary)
                                    .lineStyle(.init(lineWidth: 1, dash: [5]))
                                    .accessibilityHidden(true)
                                
                                ForEach(tonightKpIndexes) { kpItem in
                                    // NOAA Kp values cover 3-hour windows, so each bar spans its full window
                                    // (minus a small gap of 20 minutes) and rises from 0 up to the Kp value.
                                    RectangleMark(
                                        xStart: .value("Start", kpItem.date),
                                        xEnd: .value("End", kpItem.date.addingTimeInterval(3 * 3600 - 1200)),
                                        yStart: .value("Base", 0.0),
                                        yEnd: .value("Kp Index", kpItem.kp)
                                    )
                                    .foregroundStyle(getKpValueColor(from: kpItem.kp))
                                    .cornerRadius(3)
                                }
                            }
                            .chartXAxis {
                                AxisMarks {
                                    AxisValueLabel(format: .dateTime.hour())
                                        .foregroundStyle(.cardTextSecondary)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(.cardBackground)
                    .cornerRadius(26)
                    .padding()
                }
            }
            .onAppear {
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
