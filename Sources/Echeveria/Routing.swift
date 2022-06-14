//
//  Routing.swift
//  Conductor
//

import SwiftUI

private let ROOT_PATH = "/"

class ConcreteRouter: Router {

    private(set) var tabs: Array<RouteAccessor> = []
    private var routes: Dictionary<RoutingPath, Route> = [:]

    private(set) var path: String = ""

    var hasTabs: Bool { tabs.count > 0 }

    init(source: RoutingElement) {
        source.apply(router: self)
        path = "/"
    }

    func register(route: Route) {
        routes[.init(route.path)] = route
    }

    func registerTab(accessor: RouteAccessor) {
        tabs.append(accessor)
    }

    func prepare(path: String, delegate: RouterDelegate) {
        guard let key = routes.keys.first(where: { $0.test(path) }), let route = routes[key] else { return }
        let transition: RoutingTransition = .init(
            from: ROOT_PATH,
            to: path,
            type: .prepare,
            info: key.parse(path)
        )
        route.resolve(router: self, transition: transition, delegate: delegate)
    }

    func resolve(from currentPath: String, to nextPath: String, delegate: RouterDelegate) {

        guard let key = routes.keys.first(where: { $0.test(nextPath) }), let route = routes[key] else { return }

        var transitionType: RoutingTransition.Transition = .none

        if nextPath == currentPath {
            delegate.roopback()
            return
        }

        do {
            let tabPaths = tabs.map { $0.path }
            if let currentOrder = tabPaths.firstIndex(of: currentPath), let nextOrder = tabPaths.firstIndex(of: nextPath) {
                if currentOrder < nextOrder {
                    transitionType = .slideToRight
                }
                if currentOrder > nextOrder {
                    transitionType = .slideToLeft
                }
            }
        }

        let transition: RoutingTransition = .init(
            from: currentPath,
            to: nextPath,
            type: transitionType,
            info: key.parse(nextPath)
        )
        route.resolve(router: self, transition: transition, delegate: delegate)
        self.path = route.path
    }
}

public protocol Router {
    func register(route: Route)
    func registerTab(accessor: RouteAccessor)
    func resolve(from: String, to: String, delegate: RouterDelegate)
}

public protocol RouterDelegate {
    func roopback()
    func transition<Content>(with: RoutingTransition, view: Content) where Content: View
}

public protocol Route {
    var path: String { get }
    func resolve(router: Router, transition: RoutingTransition, delegate: RouterDelegate)
}

public struct RouteAccessor {
    let title: LocalizedStringKey
    let image: Image
    let path: String
}

public struct RoutingTransition {
    let from: String
    let to: String
    let type: Transition
    let info: Dictionary<String, String>

    enum Transition {
        case none, slideToLeft, slideToRight, stack, cover, prepare
    }

    func convert(type: Transition) -> RoutingTransition {
        .init(from: from, to: to, type: type, info: info)
    }
}

// MARK: - Path

struct RoutingPath: Hashable {

    static func == (lhs: RoutingPath, rhs: RoutingPath) -> Bool {
        lhs.definition.body == rhs.definition.body
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(definition.body)
    }

    let definition: Meta

    init(_ definition: String) {
        self.definition = .init(definition)
    }

    func test(_ body: String) -> Bool {
        let sample = Meta(body)
        if definition.length != sample.length { return false }

        for i in 0..<sample.length {
            let def = definition.tokens[i]
            let sam = sample.tokens[i]
            if def.isField {
                continue
            }
            if def.body != sam.body {
                return false
            }
        }

        return true
    }

    func parse(_ body: String) -> Dictionary<String, String> {
        guard test(body) else { return [:] }

        let sample = Meta(body)

        var result: Dictionary<String, String> = [:]

        for i in 0..<sample.length {
            let def = definition.tokens[i]
            let sam = sample.tokens[i]
            if let name = def.name {
                result[name] = sam.body
            }
        }

        return result
    }

    struct Meta {
        let body: String
        let tokens: Array<PathToken>

        var length: Int { tokens.count }

        init(_ body: String) {
            self.body = body
            self.tokens = body.split(separator: "/").filter { !$0.isEmpty }.map { .init($0.description) }
        }
    }

    struct PathToken {
        let body: String
        let name: String?

        var isField: Bool { name != nil }

        init(_ body: String) {
            self.body = body
            if body[body.startIndex] == ":" {
                self.name = String(body.dropFirst())
            } else {
                self.name = nil
            }
        }
    }
}

// MARK: - Routing Elements & DSL

public protocol RoutingElement {
    func apply(router: Router)
}

public struct Page<Content: View>: Route, RoutingElement {

    public init(path: String, @ViewBuilder content: @escaping (RoutingTransition) -> Content) {
        self.path = path
        self.content = content
    }

    public var path: String
    let content: (RoutingTransition) -> Content

    public func apply(router: Router) {
        router.register(route: self)
    }

    public func resolve(router: Router, transition: RoutingTransition, delegate: RouterDelegate) {
        delegate.transition(with: transition, view: content(transition))
    }
}

struct Cover<Content: View>: Route, RoutingElement {

    init(path: String, @ViewBuilder content: @escaping (RoutingTransition) -> Content) {
        self.path = path
        self.content = content
    }

    var path: String
    let content: (RoutingTransition) -> Content

    func apply(router: Router) {
        router.register(route: self)
    }

    func resolve(router: Router, transition: RoutingTransition, delegate: RouterDelegate) {
        delegate.transition(with: transition.convert(type: .cover), view: content(transition))
    }
}

struct Namespace: RoutingElement {

    let path: String
    let elements: Array<RoutingElement>

    init(path: String, @RoutingBuilder routings: () -> RoutingCollection) {
        self.path = path
        self.elements = routings().elements
    }

    func apply(router: Router) {
        elements.forEach { $0.apply(router: WrapperRouter(namespace: self, base: router)) }
    }

    struct WrapperRouter: Router {
        let namespace: Namespace
        let base: Router

        func register(route: Route) {
            base.register(route: NamespacedRoute(namespace: namespace.path, base: route))
        }

        func registerTab(accessor: RouteAccessor) {
            base.registerTab(accessor: accessor)
        }

        func resolve(from: String, to: String, delegate: RouterDelegate) {
            base.resolve(from: from, to: to, delegate: delegate)
        }
    }

    struct NamespacedRoute: Route {

        let namespace: String
        let base: Route

        var path: String {
            if base.path == "/" {
                return "\(namespace)".replacingOccurrences(of: "//", with: "/")
            } else {
                return "\(namespace)/\(base.path)".replacingOccurrences(of: "//", with: "/")
            }
        }

        func resolve(router: Router, transition: RoutingTransition, delegate: RouterDelegate) {
            base.resolve(router: router, transition: transition, delegate: delegate)
        }
    }
}

public struct RoutingCollection: RoutingElement {
    let elements: Array<RoutingElement>

    public func apply(router: Router) {
        elements.forEach { $0.apply(router: router) }
    }
}

@resultBuilder
public struct RoutingBuilder {
    public static func buildBlock(_ components: RoutingElement...) -> RoutingCollection {
        .init(elements: components)
    }
}

// MARK: - Extensions for Debug

extension ConcreteRouter: CustomDebugStringConvertible {

    var debugDescription: String {
        routes.map { "\($0)\n\t\($1)" }.joined(separator: "\n")
    }
}
