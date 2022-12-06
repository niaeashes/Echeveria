//
//  NotFoundRoute.swift
//

import SwiftUI

public struct NotFoundRoute<Scene: View>: RoutingElement, RoutingRegistry {

    let scene: (RoutingInfo) -> Scene

    public init(view: @escaping () -> Scene) {
        self.scene = { _ in view() }
    }

    public init(view: @escaping (RoutingInfo) -> Scene) {
        self.scene = view
    }

    func resolve(builder: RouterBuilder) {
        builder.add(path: NOT_FOUND_FEATURE_PATH, content: scene)
    }
}
