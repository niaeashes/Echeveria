//
//  Router.swift
//

import SwiftUI

public struct Router {
    let leaves: Array<Leaf>
    private let routes: Dictionary<RoutingPath, RoutingResolver>

    fileprivate init(leaves: Array<Leaf>, routes: Dictionary<RoutingPath, RoutingResolver>) {
        self.leaves = leaves
        self.routes = routes
    }

    func resolve(path: String) -> AnyView {
        for routingPath in routes.keys {
            guard let info = routingPath.test(path: path), let route = routes[routingPath] else { continue }
            return route.resolver(info)
        }

        // Hit Not Found Route
        if let notFoundRoute = routes[.init("!not-found")] {
            return notFoundRoute.resolver(.init(path: path, info: [:]))
        }

        return AnyView(Text("Not Found"))
    }
}

private struct RoutingResolver {
    let resolver: (RoutingInfo) -> AnyView
}

public struct Leaf {
    public let path: String
    public let text: Text
    public let icon: Image
    public let placement: Placement?

    public enum Placement {
        case launcher, switcher, drawer, inspector
    }
}

// MARK: - Router Builder

@resultBuilder
public class RouterBuilder {

    private init() {
        routes[.init("/")] = .init { info in
            AnyView(WelcomeView())
        }
    }

    private var leaves: Array<Leaf> = []
    private var routes: Dictionary<RoutingPath, RoutingResolver> = [:]

    func add(leaf: Leaf) {
        leaves.append(leaf)
    }

    func add<V>(path: String, content: @escaping (RoutingInfo) -> V) where V: View {
        routes[.init(path)] = .init { info in
            AnyView(content(info))
        }
    }

    func build() -> Router {
        .init(leaves: leaves, routes: routes)
    }

    public static func buildBlock(_ elements: RoutingElement...) -> Router {

        let builder = RouterBuilder()

        elements.forEach { ($0 as? RoutingRegistry)?.resolve(builder: builder) }

        return builder.build()
    }
}

// MARK: - Router Environment Value

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
