//
//  Markers.swift
//  Markers
//
//  Created by Emir Arıkan on 29.11.2024.
//

import Foundation
import CoreLocation

struct Markers: Codable {
    let latitude: Double
    let longitude: Double
    let address: String
    
    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
    
    init(location: CLLocation, address: String) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.address = address
    }
    
    init(latitude: Double, longitude: Double, address: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }
}
