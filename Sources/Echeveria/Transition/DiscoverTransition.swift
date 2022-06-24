//
//  DiscoverTransition.swift
//  

import UIKit
import SwiftUI

public class DiscoverTransition: SceneTransition {

    public init() {}

    public let backTransition: SceneTransition? = nil

    public func prepare(context: SceneTransitionContext) {

        let owner = context.owner
        let parent = context.container
        let distination = context.distination

        parent.addChild(distination)
        parent.view.addSubview(distination.view)

        distination.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.deactivate(distination.view.constraints)
        NSLayoutConstraint.activate([
            distination.view.topAnchor.constraint(equalTo: parent.view.topAnchor),
            distination.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor),
            distination.view.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor),
            distination.view.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor),
        ])

        distination.view.layoutIfNeeded()

        update(0, context: context)

        owner.showLauncher()
    }

    public func update(_ percentComplete: CGFloat, context: SceneTransitionContext) {
        context.distination.view.layer.position = calcDistinationPosition(percentComplete: percentComplete, context: context)
    }

    public func cancel(context: SceneTransitionContext) {
        update(0, context: context)
    }

    public func finish(context: SceneTransitionContext) {

        context.container.view.layoutIfNeeded()

        CATransaction.begin()

        let animation = CASpringAnimation(keyPath: "position")

        context.distination.view.layer.position = calcDistinationPosition(percentComplete: 1, context: context)

        animation.fromValue = calcDistinationPosition(percentComplete: 0, context: context)
        animation.toValue = context.distination.view.layer.position
        animation.initialVelocity = 0
        animation.damping = 500
        animation.stiffness = 1000
        animation.mass = 3
        animation.duration = 0.5

        context.distination.view.layer.add(animation, forKey: "position")

        CATransaction.setCompletionBlock {
            context.owner.transitionFinish(context: context)
        }
        CATransaction.commit()
    }

    private func calcDistinationPosition(percentComplete: CGFloat, context: SceneTransitionContext) -> CGPoint {
        .init(
            x: context.distination.view.layer.position.x,
            y: context.distination.view.frame.height * (0.5 + min(1, max(0, percentComplete)))
        )
    }
}
