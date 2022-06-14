//
//  Navigator.swift
//  Conductor
//

import SwiftUI

// MARK: - Navigator Protocol

protocol Navigator {
    func move(to: String)
}

// MARK: - View Modifiers

struct NavigatorModifier: ViewModifier {

    let navigator: Navigator

    func body(content: Content) -> some View {
        content
            .environment(\.navigator, navigator)
    }
}

struct NavigateModifier: ViewModifier {

    let path: String

    @Environment(\.navigator) var navigator

    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .onTapGesture { navigator?.move(to: path) }
    }
}

extension View {
    func navigate(to path: String) -> some View {
        modifier(NavigateModifier(path: path))
    }
}

// MARK: - Environment Values

struct NavigatorKey: EnvironmentKey {
    static var defaultValue: Navigator? = nil
}

extension EnvironmentValues {
    var navigator: Navigator? {
        get { self[NavigatorKey.self] }
        set { self[NavigatorKey.self] = newValue }
    }
}
