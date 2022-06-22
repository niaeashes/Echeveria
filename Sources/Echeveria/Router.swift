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

    func resolve(path: String, delegate: RouterDelegate) {
        for routingPath in routes.keys {
            guard let info = routingPath.test(path: path), let route = routes[routingPath] else { continue }
            route.resolver(info, delegate)
        }
    }

    func resolve(transition routing: RoutingTransition, delegate: RouterDelegate) {
        guard let transition = routing.transition else {
            return resolve(path: routing.path, delegate: delegate)
        }
        for routingPath in routes.keys {
            guard let info = routingPath.test(path: routing.path), let route = routes[routingPath] else { continue }
            route.resolver(info, TransitionModifier(next: delegate, transition: transition))
        }
    }

    class TransitionModifier: RouterDelegate {

        let next: RouterDelegate
        let transition: SceneTransition

        init(next: RouterDelegate, transition: SceneTransition) {
            self.next = next
            self.transition = transition
        }

        func present<V>(transition: SceneTransition?, content: V) where V : View {
            next.present(transition: transition ?? self.transition, content: content)
        }
    }
}

private struct RoutingResolver {
    let resolver: (RoutingInfo, RouterDelegate) -> Void
}

protocol RouterDelegate: AnyObject {
    func present<V>(transition: SceneTransition?, content: V) where V: View
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
        routes[.init("/")] = .init { info, delegate in
            delegate.present(transition: nil, content: WelcomeView())
        }
    }

    private var leaves: Array<Leaf> = []
    private var routes: Dictionary<RoutingPath, RoutingResolver> = [:]

    func add(leaf: Leaf) {
        leaves.append(leaf)
    }

    func add<V>(path: String, transition: SceneTransition?, content: @escaping (RoutingInfo) throws -> V) where V: View {
        routes[.init(path)] = .init() { info, delegate in
            do {
                delegate.present(transition: transition, content: try content(info))
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
