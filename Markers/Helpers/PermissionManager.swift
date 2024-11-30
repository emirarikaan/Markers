//
//  PermissionManager.swift
//  Markers
//
//  Created by Emir Arıkan on 27.11.2024.
//

import CoreLocation

protocol PermissionProtocol {
    func requestPermission()
}

enum PermissionType {
    case location(configuration: LocationPermissionConfiguration )
}

enum PermissionBuilder {
    static func build(with type: PermissionType) -> PermissionProtocol {
        switch type {
        case .location(let configuration):
            return LocationPermission(configuration: configuration)
        }
    }
}

class PermissionManager {
    static var `default`: PermissionManager = PermissionManager()
    var permissions: [PermissionProtocol] = []
    
    func requestPermission(of type: PermissionType) {
        let permission = PermissionBuilder.build(with: type)
        permission.requestPermission()
        permissions.append(permission)
    }
    
    func requestPermissions(of types: [PermissionType]) {
        types.forEach { type in
            requestPermission(of: type)
        }
    }
    
    func getPermission<T>(of _: T.Type) -> T? where T: PermissionProtocol {
        return permissions.first(where: { $0 is T }) as? T
    }
    
    func hasLocationPermission(completion: @escaping (Bool) -> ()) {
        DispatchQueue.main.async {
            switch CLLocationManager().authorizationStatus {
            case .notDetermined, .restricted, .denied:
                completion(false)
            case .authorizedAlways, .authorizedWhenInUse:
                completion(true)
            @unknown default:
                completion(false)
            }
        }
    }
}
