//
//  Router.swift
//

import SwiftUI

public struct Router {
    let leaves: Array<Leaf>
    let routes: Dictionary<RoutingPath, RoutingResolver>

    init(leaves: Array<Leaf>, routes: Dictionary<RoutingPath, RoutingResolver>) {
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

struct RoutingResolver {
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
            AnyView(EmptyView())
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

private struct BlankViewModifier: ViewModifier {
    func body(content: Content) -> Content { content }
}
