//
//  View.swift
//

import SwiftUI

// MARK: - Router as environment value

struct RouterKey: EnvironmentKey {
    static var defaultValue: Router = Router(leaves: [], routes: [:])
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
            leaves: baseRouter.leaves,
            routes: baseRouter.routes.mapValues { resolver in
                .init { info in AnyView(resolver.resolver(info).modifier(modifier(info))) }
            }))
    }
}
