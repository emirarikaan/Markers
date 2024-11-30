//
//  ViewModel.swift
//  Markers
//
//  Created by Emir Arıkan on 29.11.2024.
//

import Foundation
import CoreLocation
import MapKit

protocol MapViewModelDelegate: AnyObject {
    func didUpdateMarkers()
}

class MapViewModel {
    
    private let geocoder = CLGeocoder()
    private(set) var markers: [Markers] = CurrentUserDefaults.markers
    
    weak var delegate: MapViewModelDelegate?
    
    func checkLocationPermission() {
        if LocationManager.shared.currentLocation == nil {
            PermissionManager.default.hasLocationPermission { hasPermission in
                if !hasPermission {
                    let permissionConfiguration = LocationPermissionConfiguration(desiredAccuracy: kCLLocationAccuracyBest)
                    PermissionManager.default.requestPermission(of: .location(configuration: permissionConfiguration))
                }
            }
        }
    }
    
    func addMarker(location: CLLocation) {
        if markers.contains(where: { $0.location.distance(from: location) < 10 }) {
            return
        }
        
        reverseGeocode(location: location) { [weak self] address in
            guard let self = self else { return }
            let newMarker = Markers(location: location, address: address)
            self.markers.append(newMarker)
            CurrentUserDefaults.markers = self.markers
            self.delegate?.didUpdateMarkers()
        }
    }
    
    func loadSavedMarkers() -> [MKPointAnnotation] {
        return markers.map { marker in
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: marker.latitude, longitude: marker.longitude)
            annotation.title = marker.address
            return annotation
        }
    }
    
    func clearMarkers() {
        markers.removeAll()
        CurrentUserDefaults.markers = []
        delegate?.didUpdateMarkers()
    }
    
    func getPolyline() -> MKPolyline? {
        let coordinates = markers.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        guard coordinates.count > 1 else { return nil }
        return MKPolyline(coordinates: coordinates, count: coordinates.count)
    }
    
    private func reverseGeocode(location: CLLocation, completion: @escaping (String) -> Void) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let _ = error {
                completion("Address not found")
                return
            }
            
            let address = placemarks?.first?.name ?? "Unknown Address"
            completion(address)
        }
    }
}
