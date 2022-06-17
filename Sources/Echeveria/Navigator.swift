//
//  Navigator.swift
//

import Foundation
import SwiftUI

public protocol Navigator {
    func present(path: String)
    func present<T>(path: String, with transition: T.Type) where T: SceneTransition
}

private struct BlankNavigator: Navigator {

    func present(path: String) {
        assertionFailure("Uncaught path request: \(path)")
    }

    func present<T>(path: String, with transition: T.Type) where T : SceneTransition {
        assertionFailure("Uncaught path request: \(path), with transition: \(T.self)")
    }
}

class PassthroughNavigator: Navigator {

    var rootNavigator: Navigator? = nil

    func present(path: String) {
        guard let navigator = rootNavigator else { return assertionFailure() }
        navigator.present(path: path)
    }

    func present<T>(path: String, with transition: T.Type) where T : SceneTransition {
        guard let navigator = rootNavigator else { return assertionFailure() }
        navigator.present(path: path, with: T.self)
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

