//
//  LocationPermission.swift
//  Markers
//
//  Created by Emir Arıkan on 27.11.2024.
//

import CoreLocation

struct LocationPermissionConfiguration {
    let desiredAccuracy: CLLocationAccuracy
}

class LocationPermission: NSObject, PermissionProtocol {
    let configuration: LocationPermissionConfiguration
    let locationManager = LocationManager.shared

    init(configuration: LocationPermissionConfiguration) {
        self.configuration = configuration
    }

    func requestPermission() {
        locationManager.requestLocationPermissionIfNeeded()
    }
}

extension LocationPermission: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_: CLLocationManager) {}
}
