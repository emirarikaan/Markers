//
//  NotificationExtension.swift
//  Markers
//
//  Created by Emir Arıkan on 30.11.2024.
//

import Foundation

enum NotificationName: String {
    case startUpdatingLocation = "startUpdatingLocation"
    case locationUpdated = "locationUpdated"

    var notification: Notification.Name {
        return Notification.Name(rawValue: self.rawValue)
    }
}

extension NSNotification.Name {
    static let startUpdatingLocation = Notification.Name("startUpdatingLocation")
    static let locationUpdated = Notification.Name("locationUpdated")
}
