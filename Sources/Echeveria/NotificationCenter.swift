//
//  File.swift
//  
//
//  Created by shota-nagasaki on 2022/06/15.
//

import Foundation

extension NotificationCenter {
    public static let echeveria = NotificationCenter()
}

extension Notification.Name {
    public static let RetapLauncher: Notification.Name = .init("Echeveria.RetapLauncher.Notification")
}
