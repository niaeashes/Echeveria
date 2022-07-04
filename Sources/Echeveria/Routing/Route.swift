//
//  Route.swift
//

import SwiftUI

// MARK: - Routing Elements

public protocol RoutingElement {}

protocol RoutingRegistry {
    func resolve(builder: RouterBuilder)
}

public struct Route<Scene: View>: RoutingElement, RoutingRegistry {

    let path: String
    let scene: (RoutingInfo) throws -> Scene

    public init(_ path: String, view: @escaping () -> Scene) {
        self.init(path: path) { _ in view() }
    }

    public init(_ path: String, view: @escaping (RoutingInfo) -> Scene) {
        self.init(path: path, view: view)
    }

    public init<P>(_ path: String, parseBy parameterParser: P, view: @escaping (P.Param) -> Scene) where P: RoutingParamParser {
        self.init(path: path) {
            let params = try parameterParser.parse(info: $0)
            return view(params)
        }
    }

    private init(path: String, view: @escaping (RoutingInfo) throws -> Scene) {
        assert(path[path.startIndex] != FEATURE_PATH_PREFIX, "'\(FEATURE_PATH_PREFIX)' cannot be used as the first letter of path.")
        var path = path
        if path[path.startIndex] != "/" {
            path = "/\(path)"
        }
        self.path = path
        self.scene = view
    }

    func resolve(builder: RouterBuilder) {
        builder.add(path: path, content: scene)
    }
}
