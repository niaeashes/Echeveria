//
//  PushTransition.swift
//

import UIKit
import SwiftUI

private var CONSTRAINT_IDENTIFIER = "CoverTransition_AnimationConstraint"

public struct PushTransition: SceneTransition {

    public init() {}

    public var backTransition: SceneTransition? { PopTransition() }

    public func prepare(context: SceneTransitionContext) {

        let parent = context.container
        let distination = context.distination

        parent.addChild(distination)
        parent.view.addSubview(distination.view)

        distination.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.deactivate(distination.view.constraints)
        let animationConstraint = distination.view.topAnchor.constraint(equalTo: parent.view.topAnchor)
        animationConstraint.identifier = CONSTRAINT_IDENTIFIER
        NSLayoutConstraint.activate([
            animationConstraint,
            distination.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor),
            distination.view.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor),
            distination.view.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor),
        ])

        distination.view.layoutIfNeeded()

        update(0, context: context)
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

        do {
            let animation = CASpringAnimation(keyPath: "position")

            animation.fromValue = calcDistinationPosition(percentComplete: 0, context: context)
            animation.toValue = calcDistinationPosition(percentComplete: 1, context: context)
            setupSpring(animation)

            CATransaction.setCompletionBlock {
                context.owner.transitionFinish(context: context)
            }

            context.distination.view.layer.add(animation, forKey: "position")
        }

        do {
            let animation = CASpringAnimation(keyPath: "position")

            animation.fromValue = calcSourcePosition(percentComplete: 0, context: context)
            animation.toValue = calcSourcePosition(percentComplete: 1, context: context)
            setupSpring(animation)

            context.source.view.layer.add(animation, forKey: "position")
        }

        do {
            let animation = CASpringAnimation(keyPath: "opacity")

            animation.fromValue = 1
            animation.toValue = 0.8
            setupSpring(animation)

            context.source.view.layer.add(animation, forKey: "opacity")
        }

        CATransaction.commit()
    }

    private func calcDistinationPosition(percentComplete: CGFloat, context: SceneTransitionContext) -> CGPoint {
        .init(
            x: context.distination.view.frame.width * (1.5 - min(1, max(0, percentComplete))),
            y: context.distination.view.layer.position.y
        )
    }

    private func calcSourcePosition(percentComplete: CGFloat, context: SceneTransitionContext) -> CGPoint {
        .init(
            x: context.source.view.frame.width * (0.5 - min(1, max(0, percentComplete)) / 2),
            y: context.source.view.layer.position.y
        )
    }

    private func setupSpring(_ animation: CASpringAnimation) {
        animation.initialVelocity = 0
        animation.damping = 500
        animation.stiffness = 1000
        animation.mass = 3
        animation.duration = 0.5
    }
}
