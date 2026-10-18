//
//  TodayView.swift
//  Aurora Latvia
//
//  Created by Sergey Klus on 18/10/2026.
//

import SwiftUI
import WeatherKit

struct TodayView: View {
    var body: some View {
        Text("Today")
            .onAppear {
                getCurrentWeather()
            }
    }

    private func getCurrentWeather() {
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
    TodayView()
}
