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
        self.path = path
        self.scene = { _ in view() }
    }

    public init(_ path: String, view: @escaping (RoutingInfo) -> Scene) {
        self.path = path
        self.scene = view
    }

    public init<P>(_ path: String, parseBy parameterParser: P, view: @escaping (P.Param) -> Scene) where P: RoutingParamParser {
        self.path = path
        self.scene = {
            let params = try parameterParser.parse(info: $0)
            return view(params)
        }
    }

    func resolve(builder: RouterBuilder) {
        builder.add(path: path, content: scene)
    }
}

struct LeafRoute<Element: RoutingElement>: RoutingElement, RoutingRegistry {

    let element: Element
    let leaf: Leaf

    func resolve(builder: RouterBuilder) {
        builder.add(leaf: leaf)
        (element as? RoutingRegistry)?.resolve(builder: builder)
    }
}

extension RoutingElement {

    public func leaf(text: LocalizedStringKey, icon: String, placement: Leaf.Placement? = nil, bundle: Bundle? = nil) -> some RoutingElement {
        LeafRoute(element: self, leaf: .init(text: .init(text, bundle: bundle), icon: .init(icon, bundle: bundle), placement: placement))
    }

    public func leaf(text: String, icon: String, placement: Leaf.Placement? = nil, bundle: Bundle? = nil) -> some RoutingElement {
        LeafRoute(element: self, leaf: .init(text: .init(text), icon: .init(icon, bundle: bundle), placement: placement))
    }

    public func leaf(text: LocalizedStringKey, systemImage: String, placement: Leaf.Placement? = nil, bundle: Bundle? = nil) -> some RoutingElement {
        LeafRoute(element: self, leaf: .init(text: .init(text, bundle: bundle), icon: .init(systemName: systemImage), placement: placement))
    }

    public func leaf(text: String, systemImage: String, placement: Leaf.Placement? = nil) -> some RoutingElement {
        LeafRoute(element: self, leaf: .init(text: .init(text), icon: .init(systemName: systemImage), placement: placement))
    }
}
