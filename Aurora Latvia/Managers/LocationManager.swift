//
//  LocationManager.swift
//  Aurora Latvia
//
//  Created by Sergey Klus on 01/11/2026.
//

import Foundation
import CoreLocation
import Combine

@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {
    @ObservationIgnored private let manager = CLLocationManager()
    
    var location: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func requestLocation() {
        // If permission isn't decided yet, ask for it; the location is requested once authorization changes.
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            manager.requestLocation()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
    
    // Required when using requestLocation(), otherwise CLLocationManager raises an exception.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("** Failed to get location: \(error)")
    }
}
