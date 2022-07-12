//
//  Router.swift
//

import SwiftUI

let PATH_SEPARATOR: Character = "/"
let QUERY_STARTER: Character = "?"
let QUERY_PAIR_CHARACTER: Character = "="
let QUERY_SEPARATOR: Character = "&"
let FEATURE_PATH_PREFIX: Character = "!"
let CURRENT_PATH_ALIAS: Character = "."
let RELATIVE_PATH_PREFIX = CURRENT_PATH_ALIAS

let BLANK_FEATURE_PATH = "\(FEATURE_PATH_PREFIX)blank"
let NOT_FOUND_FEATURE_PATH = "\(FEATURE_PATH_PREFIX)not-found"
let PARENT_PATH_ALIAS = ".."

public struct Router {

    let routes: Dictionary<RoutingPath, RoutingResolver>

    init(routes: Dictionary<RoutingPath, RoutingResolver>) {
        self.routes = routes
    }

    func resolve(path: String) -> AnyView {

        var errors: Array<Error> = []

        for routingPath in routes.keys {
            guard let info = routingPath.test(path: path), let route = routes[routingPath] else { continue }
            do {
                return try route.resolver(info)
            } catch {
                errors.append(error)
            }
        }

        return resolveNotFound(originalPath: path, errors: errors)
    }

    func resolveNotFound(originalPath: String, errors: Array<Error>) -> AnyView {
        let info = RoutingInfo(path: originalPath, params: [:], query: [:], errors: errors)
        return (try? routes[.init(NOT_FOUND_FEATURE_PATH)]?.resolver(info)) ?? AnyView(DefaultNotFoundView(info: info))
    }

    public func test(path: String) -> RoutingInfo? {

        for routingPath in routes.keys {
            guard let info = routingPath.test(path: path) else { continue }
            return info
        }

        return nil
    }
}

// MARK: - Utilities

struct RouteInfoKey: EnvironmentKey {
    static var defaultValue: RoutingInfo = .init(path: BLANK_FEATURE_PATH, params: [:], query: [:], errors: [])
}

extension EnvironmentValues {

    public var route: RoutingInfo {
        get { self[RouteInfoKey.self] }
        set { self[RouteInfoKey.self] = newValue }
    }
}

struct RoutingResolver {
    let resolver: (RoutingInfo) throws -> AnyView
}

// MARK: - Router Builder

@resultBuilder
public class RouterBuilder {

    private init() {
        routes[.init("\(PATH_SEPARATOR)")] = .init { info in
            AnyView(EmptyView())
        }
    }

    private var routes: Dictionary<RoutingPath, RoutingResolver> = [:]

    func add<V>(path: String, content: @escaping (RoutingInfo) throws -> V) where V: View {
        routes[.init(path)] = .init { info in
            AnyView(try content(info).environment(\.route, info))
        }
    }

    func build() -> Router {
        .init(routes: routes)
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
