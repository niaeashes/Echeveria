//
//  CoverTransition.swift
//

import UIKit
import SwiftUI

private var CONSTRAINT_IDENTIFIER = "CoverTransition_AnimationConstraint"

public class CoverTransition: SceneTransition {

    public init() {}

    public func prepare(context: SceneTransitionContext) {

        let owner = context.owner
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

        owner.hideLauncher()
    }

    public func update(_ percentComplete: CGFloat, context: SceneTransitionContext) {
        let animationConstraint = context.container.view.constraints
            .first { $0.identifier == CONSTRAINT_IDENTIFIER }
        animationConstraint?.constant = (1 - max(0, min(1, percentComplete))) * context.distination.view.frame.height
    }

    public func cancel(context: SceneTransitionContext) {
        update(0, context: context)
    }

    public func finish(context: SceneTransitionContext) {
        context.container.view.layoutIfNeeded()
        update(1, context: context)
        UIView.animate(withDuration: 0.25, animations: {
            context.container.view.layoutIfNeeded()
        }, completion: { _ in
            context.owner.transitionFinish(context: context)
        })
    }
}
