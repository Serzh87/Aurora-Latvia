//
//  TodayView.swift
//  Aurora Latvia
//
//  Created by Sergey Klus on 18/10/2026.
//

import SwiftUI
import WeatherKit

struct TodayView: View {
    @State private var kpIndex: KpItem? = KpItem(date: .now, kp: 5.624, observation: .estimated)
    
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
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea(.all)
                ScrollView {
                    
                    VStack {
                        HStack(spacing: 10) {
                            Image(systemName: "rays")
                                .foregroundStyle(Color.kpIndex)
                                .frame(width: 30, height: 30)
                                .background(.kpIndexBackground)
                                .cornerRadius(12)
                            
                            Text("Geomagnetic activity")
                                .font(.system(size: 15))
                                .foregroundStyle(Color.cardText)
                            
                            Spacer()
                            
                            if let kpIndex {
                                Text("Kp \(kpIndex.kp.formatted(.number.precision(.fractionLength(0...2))))")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(kpValueColor)
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
//                    print(result)
                    kpIndex = result.getCurrentKpIndex()
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
        TodayView()
            .tabItem {
                Label("Today", systemImage: "square.grid.2x2")
            }
    }
    .tint(.selectedTabItem)
}
