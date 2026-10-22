//
//  NetworkManager.swift
//  Aurora Latvia
//
//  Created by Sergey Klus on 21/10/2026.
//

import Foundation

struct NetworkManager {
    private init() { }
    
    private static let kpURL = URL(string: "https://services.swpc.noaa.gov/products/noaa-planetary-k-index-forecast.json")!
    
    static func getKp() async -> [KpItem] {
        do {
            let (data, response) = try await URLSession.shared.data(from: kpURL)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                return []
            }
            return try JSONDecoder().decode([KpItem].self, from: data)
        } catch {
            print("Failed to load Kp forecast: \(error)")
            return []
        }
    }
}

struct KpItem: Identifiable {
    enum Observation: String {
        case observed = "observed"
        case estimated = "estimated"
        case predicted = "predicted"
    }
    
    let id = UUID()
    
    let date: Date
    let kp: Float
    let observation: Observation
}

//    "time_tag":"2026-10-14T00:00:00","kp":2.33,"observed":"observed","noaa_scale":null
extension KpItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case time_tag
        case kp
        case observed
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let timeTag = try values.decode(String.self, forKey: .time_tag)
        // NOAA timestamps have no time zone suffix (e.g. "2026-10-14T00:00:00") and are in UTC,
        // so list the fields explicitly to leave out the time zone the default style expects.
        let strategy = Date.ISO8601FormatStyle(timeZone: TimeZone(secondsFromGMT: 0)!)
            .year().month().day()
            .dateSeparator(.dash)
            .dateTimeSeparator(.standard)
            .time(includingFractionalSeconds: false)
            .timeSeparator(.colon)
        date = try Date(timeTag, strategy: strategy)
        kp = try values.decode(Float.self, forKey: .kp)
        observation = Observation(rawValue: try values.decode(String.self, forKey: .observed))!
    }
}

extension Array where Element == KpItem {
    func getCurrentKpIndex() -> KpItem? {
        guard count > 2 else {
            return nil
        }
        
        let lastIndex = count - 1
        let now: Date = .now
        for (index, item) in enumerated() {
            if index >= lastIndex - 1 {
                break
            }
            
            let nextItem = self[index + 1]
            if now >= item.date && now < nextItem.date {
                return item
            }
        }
        
        return nil
    }
    
    func getIndexesForCurrentNight() -> [KpItem] {
        var result: [KpItem] = []
        
        let startOfToday = Calendar.current.startOfDay(for: .now)
        let startDateTime = Calendar.current.date(byAdding: .hour, value: 18, to: startOfToday)!
        let endDateTime = Calendar.current.date(byAdding: .hour, value: 24 + 6, to: startOfToday)!
        let startEndDateTimeInterval = (startDateTime...endDateTime)
        
        self.forEach {
            if startEndDateTimeInterval.contains($0.date) {
                result.append($0)
            }
        }
        
        return result
    }
}
