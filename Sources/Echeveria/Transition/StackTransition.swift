//
//  PushAndPopTransition.swift
//  
//
//  Created by shota-nagasaki on 2022/06/16.
//

import UIKit

// MARK: - Configuration

private let TRANSITION_WIDTH_DIVISOR: CGFloat = 3
private let TRANSITION_DURATION: TimeInterval = 0.3

protocol TransitionOwner: AnyObject {
    var view: UIView! { get }
    func addChild(_ childController: UIViewController)
    func transitionComplete(liveActor: TransitionActor, dropActor: TransitionActor)
}

protocol TransitionActor: AnyObject {
    func prepare(parentViewController: UIViewController)
    func updateAnimation(value: CGFloat)
    func drop()
}

class BlankTransitionActor: TransitionActor {
    init() {}
    func prepare(parentViewController: UIViewController) {}
    func updateAnimation(value: CGFloat) {}
    func drop() {}
}

class StackTransitionActor: TransitionActor {

    let viewController: UIViewController
    let role: Role

    enum Role {
        case source, distination
    }

    private var animationConstraint: NSLayoutConstraint! = nil

    init(_ viewController: UIViewController, role: Role) {
        self.viewController = viewController
        self.role = role
    }

    func prepare(parentViewController: UIViewController) {

        if viewController.parent == nil {
            parentViewController.addChild(viewController)
        }

        guard let transitionView = viewController.view, let parentView = parentViewController.view else { return assertionFailure() }

        if transitionView.superview == nil {
            transitionView.translatesAutoresizingMaskIntoConstraints = false
            switch role {
            case .source:
                parentView.insertSubview(transitionView, at: 0)
            case .distination:
                parentView.insertSubview(transitionView, at: 1)
            }

            let centerX = transitionView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor)
            NSLayoutConstraint.deactivate(transitionView.constraints)
            NSLayoutConstraint.activate([
                transitionView.topAnchor.constraint(equalTo: parentView.topAnchor),
                transitionView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
                transitionView.widthAnchor.constraint(equalTo: parentView.widthAnchor),
                centerX,
            ])
            animationConstraint = centerX
        } else {
            animationConstraint = parentView.constraints
                .first { $0.firstAttribute == .centerX && $0.secondAttribute == .centerX && $0.firstItem === transitionView }
        }
    }

    func updateAnimation(value: CGFloat) {
        if role == .source {
            viewController.view.alpha = (value / viewController.view.frame.width) * 0.3 + 0.7
        }
        animationConstraint?.constant = value
    }

    func drop() {
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
}

class StackTransition {

    weak var owner: TransitionOwner! = nil

    var animationDistance: CGFloat {
        owner.view.frame.width
    }

    let source: TransitionActor
    let distination: TransitionActor

    init(source: TransitionActor, distination: TransitionActor) {
        self.source = source
        self.distination = distination
    }

    func begin(viewController: UIViewController) {
        if owner == nil, viewController is TransitionOwner {
            self.owner = viewController as? TransitionOwner
        }
        source.prepare(parentViewController: viewController)
        distination.prepare(parentViewController: viewController)
    }

    /// @param value is from 0.0 to 1.0
    func updateTransition(value: CGFloat) {

        source
            .updateAnimation(value: -animationDistance * value / TRANSITION_WIDTH_DIVISOR)
        distination
            .updateAnimation(value: animationDistance * (1 - value))
    }

    func completeSource() {
        owner.view.layoutIfNeeded()
        UIView.animate(withDuration: TRANSITION_DURATION * 0.7, animations: {
            self.source
                .updateAnimation(value: 0)
            self.distination
                .updateAnimation(value: self.animationDistance)
            self.owner.view.layoutIfNeeded()
        }, completion: { _ in
            self.distination.drop()
            self.owner.transitionComplete(liveActor: self.source, dropActor: self.distination)
        })
    }

    func completeDistination() {
        owner.view.layoutIfNeeded()
        UIView.animate(withDuration: TRANSITION_DURATION * 0.7, animations: {
            self.source
                .updateAnimation(value: -self.animationDistance / TRANSITION_WIDTH_DIVISOR)
            self.distination
                .updateAnimation(value: 0)
            self.owner.view.layoutIfNeeded()
        }, completion: { _ in
            self.source.drop()
            self.owner.transitionComplete(liveActor: self.distination, dropActor: self.source)
        })
    }

    /// Alias of completeSource
    func completePop() {
        completeSource()
    }

    /// Alias of completeDistination
    func cancelPop() {
        completeDistination()
    }

    /// Alias of completeDistination
    func completePush() {
        completeDistination()
    }

    /// Alias of completeSource
    func cancelPush() {
        completeSource()
    }
}
