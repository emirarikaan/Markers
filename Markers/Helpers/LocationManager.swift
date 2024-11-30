//
//  LocationManager.swift
//  Markers
//
//  Created by Emir Arıkan on 27.11.2024.
//

import Foundation
import CoreLocation

protocol LocationManagerProtocol {
    var currentLocation: CLLocation? { get }
    func startTracking()
    func stopTracking()
    func requestLocationPermissionIfNeeded()
}

final class LocationManager: NSObject, LocationManagerProtocol {
    static let shared: LocationManagerProtocol = LocationManager()
    
    private let locationManager = CLLocationManager()
    private(set) var currentLocation: CLLocation?
    private var isFirstLocation = true
    private var distanceThreshold: Double = 100
    private var previousLocation: CLLocation?
    
    override private init() {
        super.init()
        configure()
    }
    
    private func configure() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = distanceThreshold
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func startTracking() {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    func requestLocationPermissionIfNeeded() {
        DispatchQueue.global().async {
            guard CLLocationManager.locationServicesEnabled()  else { return }
            
            let status = self.locationManager.authorizationStatus
            
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                self.startTracking()
                self.isFirstLocation = true
            case .notDetermined:
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.requestAlwaysAuthorization()
            case .denied, .restricted:
                print("Location permission denied or restricted")
            @unknown default:
                fatalError("Unknown location authorization status")
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        currentLocation = location
        
        if isFirstLocation {
            NotificationCenter.default.post(name: .startUpdatingLocation, object: nil)
            isFirstLocation = false
        }
        
        if let previous = previousLocation, location.distance(from: previous) >= distanceThreshold {
            NotificationCenter.default.post(name: .locationUpdated, object: location)
        }
        
        previousLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            startTracking()
        case .denied, .restricted:
            print("Location permissions denied or restricted")
        default:
            break
        }
    }
}
