//
//  CoverTransition.swift
//

import UIKit

public class CoverTransition: SceneTransition {

    weak var owner: (UIViewController & SceneOwner)? = nil

    public func prepare(owner: UIViewController & SceneOwner, distination: UIViewController) {
        owner.addChild(distination)
        owner.view.addSubview(distination.view)

        distination.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.deactivate(distination.view.constraints)
        NSLayoutConstraint.activate([
            distination.view.topAnchor.constraint(equalTo: owner.view.topAnchor),
            distination.view.bottomAnchor.constraint(equalTo: owner.view.bottomAnchor),
            distination.view.leadingAnchor.constraint(equalTo: owner.view.leadingAnchor),
            distination.view.trailingAnchor.constraint(equalTo: owner.view.trailingAnchor),
        ])
    }

    public func update(_ percentComplete: CGFloat) {
    }

    public func cancel() {
    }

    public func finish() {
    }
}
