//
//  ScreenTransition.swift
//

import SwiftUI

public protocol SceneOwner {}

public protocol SceneTransition {
    func prepare(owner: UIViewController & SceneOwner, distination: UIViewController)
    func update(_ percentComplete: CGFloat)
    func cancel()
    func finish()
}
