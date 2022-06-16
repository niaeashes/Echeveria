//
//  Cover.swift
//

import SwiftUI

public struct Cover<Content: View>: Route, RoutingElement {

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
        let stacker = Stacker(rootPath: path, router: router, content: { content(transition).stack(backIcon: .init(systemName: "xmark")) })
            .ignoresSafeArea()
        delegate.transition(with: transition.convert(type: .cover), view: stacker)
    }
}

// MARK: - Extension

extension Launcher {

    init<Content: View>(title: LocalizedStringKey, systemImage: String, route: () -> Cover<Content>) where RouteObject == Cover<Content> {
        self.title = title
        self.icon = .init(systemName: systemImage)
        self.path = route().path
        self.route = route()
    }
}
