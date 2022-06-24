//
//  ScreenTransition.swift
//

import SwiftUI

public struct SceneTransitionContext {
    public let owner: SoilController
    public let container: UIViewController
    public let source: UIViewController
    public let distination: UIViewController
}

public protocol SceneTransition {

    var backTransition: SceneTransition? { get }

    func prepare(context: SceneTransitionContext)
    func update(_ percentComplete: CGFloat, context: SceneTransitionContext)
    func cancel(context: SceneTransitionContext)
    func finish(context: SceneTransitionContext)
}
