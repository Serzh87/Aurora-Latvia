//
//  WeatherManager.swift
//  Aurora Latvia
//
//  Created by Sergey Klus on 03/11/2026.
//

import Foundation
import WeatherKit
import CoreLocation

@Observable
final class WeatherManager {
    private(set) var currentWeather: Weather?
    
    func getCurrentWeather(for location: CLLocation) async {
        do {
            currentWeather = try await WeatherService.shared.weather(for: location)
        } catch {
            print(error)
        }
    }
    
    func getTonightCloudCover() -> [CloudCover] {
        guard let currentWeather else {
            return []
        }
        
        let startOfToday = Calendar.current.startOfDay(for: .now)
        let startDateTime = Calendar.current.date(byAdding: .hour, value: 17, to: startOfToday)!
        let endDateTime = Calendar.current.date(byAdding: .hour, value: 24 + 7, to: startOfToday)!
        let startEndDateTimeInterval = (startDateTime...endDateTime)
        
        var result: [CloudCover] = []
        currentWeather.hourlyForecast.forEach {
            if startEndDateTimeInterval.contains($0.date) {
                result.append(CloudCover(date: $0.date, cover: $0.cloudCover))
            }
        }
        
        return result
    }
}

struct CloudCover: Identifiable {
    let id = UUID()
    let date: Date
    let cover: Double
}
