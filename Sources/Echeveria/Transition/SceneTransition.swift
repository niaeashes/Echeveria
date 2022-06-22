//
//  ScreenTransition.swift
//

import SwiftUI

public protocol SceneOwner: AnyObject {

    var currentViewController: UIViewController? { get }

    func hideLauncher()
    func showLauncher()
    func transitionCancel()
    func transitionFinish(context: SceneTransitionContext)
}

public struct SceneTransitionContext {
    public let owner: SceneOwner
    public let container: UIViewController
    public let source: UIViewController
    public let distination: UIViewController
}

private class BlankSceneOwner: SceneOwner {

    var currentViewController: UIViewController? { nil }

    func hideLauncher() {
        assertionFailure()
    }

    func showLauncher() {
        assertionFailure()
    }

    func transitionCancel() {
        assertionFailure()
    }

    func transitionFinish(context: SceneTransitionContext) {
        assertionFailure()
    }
}

struct SceneOwnerKey: EnvironmentKey {
    static var defaultValue: SceneOwner = BlankSceneOwner()
}

extension EnvironmentValues {
    public var sceneOwner: SceneOwner {
        get { self[SceneOwnerKey.self] }
        set { self[SceneOwnerKey.self] = newValue }
    }
}

public protocol SceneTransition {
    func prepare(context: SceneTransitionContext)
    func update(_ percentComplete: CGFloat, context: SceneTransitionContext)
    func cancel(context: SceneTransitionContext)
    func finish(context: SceneTransitionContext)
}
