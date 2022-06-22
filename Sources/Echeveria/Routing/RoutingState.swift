//
//  RoutingState.swift
//

public struct RoutingState {

    let title: String
    let backTransition: SceneTransition?

    var hasBack: Bool { backTransition != nil }
}
