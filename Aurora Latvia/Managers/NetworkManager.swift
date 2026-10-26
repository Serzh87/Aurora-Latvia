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
    private static let rtswWindURL = URL(string: "https://services.swpc.noaa.gov/json/rtsw/rtsw_wind_1m.json")!
    private static let rtswMagnitudeURL = URL(string: "https://services.swpc.noaa.gov/json/rtsw/rtsw_mag_1m.json")!
    
    private static func getArray<T: Decodable>(of type: T.Type, from url: URL) async -> [T] {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                print("** Failed to load \(url):")
                print(response)
                return []
            }
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            print("** Failed to load \(url):")
            print(error)
            return []
        }
    }
    
    static func getKp() async -> [KpItem] {
        await getArray(of: KpItem.self, from: kpURL)
    }
    
    static func getRtswWind() async -> [RTSWWind] {
        await getArray(of: RTSWWind.self, from: rtswWindURL)
    }
    
    static func getRtswMagnitude() async -> [RTSWMag] {
        await getArray(of: RTSWMag.self, from: rtswMagnitudeURL)
    }
}

// MARK: - KpItem
struct RTSWWind: Identifiable {
    let id = UUID()
    let timeTag: Date
    let isActive: Bool
    let source: String
    let protonSpeed: Double?
    let protonDensity: Double?
}

extension RTSWWind: Decodable {
    enum CodingKeys: String, CodingKey {
        case time_tag
        case active
        case source
        case proton_speed
        case proton_density
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let timeTag = try values.decode(String.self, forKey: .time_tag)
        self.timeTag = try Date(timeTag, strategy: Date.NOAAFormatStrategy)
        isActive = try values.decode(Bool.self, forKey: .active)
        source = try values.decode(String.self, forKey: .source)
        protonSpeed = try values.decodeIfPresent(Double.self, forKey: .proton_speed)
        protonDensity = try values.decodeIfPresent(Double.self, forKey: .proton_density)
    }
}

// MARK: - KpItem
struct RTSWMag: Identifiable {
    let id = UUID()
    let timeTag: Date
    let isActive: Bool
    let source: String
    let bt: Double?
    let bzGsm: Double?
}

extension RTSWMag: Decodable {
    enum CodingKeys: String, CodingKey {
        case time_tag
        case active
        case source
        case bt
        case bz_gsm
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let timeTag = try values.decode(String.self, forKey: .time_tag)
        self.timeTag = try Date(timeTag, strategy: Date.NOAAFormatStrategy)
        isActive = try values.decode(Bool.self, forKey: .active)
        source = try values.decode(String.self, forKey: .source)
        bt = try values.decodeIfPresent(Double.self, forKey: .bt)
        bzGsm = try values.decodeIfPresent(Double.self, forKey: .bz_gsm)
    }
}

// MARK: - KpItem
struct KpItem: Identifiable {
    enum Observation: String {
        case observed = "observed"
        case estimated = "estimated"
        case predicted = "predicted"
    }
    
    let id = UUID()
    let timeTag: Date
    let kp: Double
    let observation: Observation
}

extension KpItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case time_tag
        case kp
        case observed
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let timeTag = try values.decode(String.self, forKey: .time_tag)
        self.timeTag = try Date(timeTag, strategy: Date.NOAAFormatStrategy)
        kp = try values.decode(Double.self, forKey: .kp)
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
            if now >= item.timeTag && now < nextItem.timeTag {
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
            if startEndDateTimeInterval.contains($0.timeTag) {
                result.append($0)
            }
        }
        
        return result
    }
}

// MARK: - Date NOAA extension
extension Date {
    /// NOAA timestamps have no time zone suffix (e.g. "2026-10-14T00:00:00") and are in UTC, so list the fields explicitly to leave out the time zone the default style expects.
    static var NOAAFormatStrategy: Date.ISO8601FormatStyle {
        Date.ISO8601FormatStyle(timeZone: TimeZone(secondsFromGMT: 0)!)
            .year().month().day()
            .dateSeparator(.dash)
            .dateTimeSeparator(.standard)
            .time(includingFractionalSeconds: false)
            .timeSeparator(.colon)
    }
}
