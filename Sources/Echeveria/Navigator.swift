//
//  Navigator.swift
//

import Foundation
import SwiftUI

public protocol Navigator {
    func move(to path: String)
    func move(to path: String, with transition: SceneTransition)
    func moveToBack()
}

private struct BlankNavigator: Navigator {

    func move(to path: String) {
        assertionFailure("Uncaught path request: \(path)")
    }

    func move(to path: String, with transition: SceneTransition) {
        assertionFailure("Uncaught path request: \(path), with transition: \(transition)")
    }

    func moveToBack() {}
}

class PassthroughNavigator: Navigator {

    var rootNavigator: Navigator? = nil

    func move(to path: String) {
        guard let navigator = rootNavigator else { return assertionFailure() }
        navigator.move(to: path)
    }

    func move(to path: String, with transition: SceneTransition) {
        guard let navigator = rootNavigator else { return assertionFailure() }
        navigator.move(to: path, with: transition)
    }

    func moveToBack() {
        guard let navigator = rootNavigator else { return assertionFailure() }
        navigator.moveToBack()
    }

}

struct NavigatorKey: EnvironmentKey {
    static var defaultValue: Navigator = BlankNavigator()
}

extension EnvironmentValues {
    public var navigator: Navigator {
        get { self[NavigatorKey.self] }
        set { self[NavigatorKey.self] = newValue }
    }
}

extension View {

}

