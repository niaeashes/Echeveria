//
//  Navigator.swift
//  Conductor
//

import SwiftUI
import Combine

// MARK: - Navigator Protocol

// TODO: Rename
public protocol Navigator: AnyObject {
    func move(to: String)
    func dismiss()
}

public extension Navigator {

    func notification(for name: Notification.Name) -> AnyPublisher<Notification, Never> {
        NotificationCenter.echeveria
            .publisher(for: name)
            .eraseToAnyPublisher()
    }
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
    public func navigate(to path: String) -> some View {
        modifier(NavigateModifier(path: path))
    }
}

// MARK: - Environment Values

struct NavigatorKey: EnvironmentKey {
    static var defaultValue: Navigator? = nil
}

extension EnvironmentValues {
    public var navigator: Navigator? {
        get { self[NavigatorKey.self] }
        set { self[NavigatorKey.self] = newValue }
    }
}
