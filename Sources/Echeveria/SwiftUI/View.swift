//
//  View.swift
//

import SwiftUI

// MARK: - Router as environment value

struct RouterKey: EnvironmentKey {
    static var defaultValue: Router = Router(routes: [:])
}

extension EnvironmentValues {

    public var router: Router {
        get { self[RouterKey.self] }
        set { self[RouterKey.self] = newValue }
    }
}

extension View {

    public func routing(@RouterBuilder router: () -> Router) -> some View {
        environment(\.router, router())
    }
}

// MARK: - Global view modifier

extension View {

    public func routing<Modifier>(modifier: @escaping (RoutingInfo) -> Modifier, @RouterBuilder router: () -> Router) -> some View where Modifier: ViewModifier {
        let baseRouter = router()
        return environment(\.router, .init(
            routes: baseRouter.routes.mapValues { resolver in
                .init { info in AnyView(try resolver.resolver(info).modifier(modifier(info))) }
            }))
    }
}

// MARK: - Full Screen Cover

extension View {

    public func fullScreenCover(path: Binding<String?>) -> some View {
        fullScreenCover(
            isPresented: .init(
                get: { path.wrappedValue != nil },
                set: { if $0 == false { path.wrappedValue = nil } }
            ),
            content: { RouteView(path: path.wrappedValue ?? "") }
        )
    }

    public func fullScreenCover<Modifier>(path: Binding<String?>, modifier: Modifier) -> some View where Modifier: ViewModifier {
        fullScreenCover(
            isPresented: .init(
                get: { path.wrappedValue != nil },
                set: { if $0 == false { path.wrappedValue = nil } }
            ),
            content: { RouteView(path: path.wrappedValue ?? "").modifier(modifier) }
        )
    }
}

// MARK: - Sheet

extension View {

    public func sheet(path: Binding<String?>) -> some View {
        sheet(
            isPresented: .init(
                get: { path.wrappedValue != nil },
                set: { if $0 == false { path.wrappedValue = nil } }
            ),
            content: { RouteView(path: path.wrappedValue ?? "") }
        )
    }

    public func sheet<Modifier>(path: Binding<String?>, modifier: Modifier) -> some View where Modifier: ViewModifier {
        sheet(
            isPresented: .init(
                get: { path.wrappedValue != nil },
                set: { if $0 == false { path.wrappedValue = nil } }
            ),
            content: { RouteView(path: path.wrappedValue ?? "").modifier(modifier) }
        )
    }
}
