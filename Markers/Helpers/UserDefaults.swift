//
//  UserDefaults.swift
//  Markers
//
//  Created by Emir Arıkan on 29.11.2024.
//

import Foundation

@propertyWrapper
public struct Storage<T: Codable> {
    private let key: String
    private let defaultValue: T

    public init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

   public var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.object(forKey: key) as? Data else {
                return defaultValue
            }

            let value = try? JSONDecoder().decode(T.self, from: data)
            return value ?? defaultValue
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: key)
            print("Storage set for key: \(key)")
        }
    }
}

enum CurrentUserDefaults {
    enum Keys: String {
        case markers
    }
    
    @Storage(key: Keys.markers.rawValue, defaultValue: [])
    static var markers: [Markers]
    
}

