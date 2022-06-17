//
//  Router.swift
//

import SwiftUI

public struct Router {
    let leaves: Array<Leaf>
    let routes: Dictionary<RoutingPath, RoutingResolver>

    func resolve(path: String, delegate: RouterDelegate) {
        for routingPath in routes.keys {
            guard let info = routingPath.test(path: path), let route = routes[routingPath] else { continue }
            route.resolver(info, delegate)
        }
    }
}

protocol ScreenTransition {}

protocol RouterDelegate {
    func present<V>(transition: ScreenTransition?, content: V) where V: View
}

public struct Leaf {
    public let text: Text
    public let icon: Image
    public let placement: Placement?

    public enum Placement {
        case launcher, switcher, drawer, inspector
    }
}

// MARK: - Router Builder

struct RoutingResolver {
    let resolver: (RoutingInfo, RouterDelegate) -> Void
}

@resultBuilder
public class RouterBuilder {

    private init() {
        routes[.init("/")] = .init { info, delegate in
            delegate.present(transition: nil, content: WelcomeView())
        }
    }

    private var leaves: Array<Leaf> = []
    private var routes: Dictionary<RoutingPath, RoutingResolver> = [:]

    func add(leaf: Leaf) {
        leaves.append(leaf)
    }

    func add<V>(path: String, content: @escaping (RoutingInfo) throws -> V) where V: View {
        var path = path
        if path[path.startIndex] != "/" {
            path = "/\(path)"
        }
        routes[.init(path)] = .init() { info, delegate in
            do {
                delegate.present(transition: nil, content: try content(info))
            } catch {
                // TODO: Handle Error
            }
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
