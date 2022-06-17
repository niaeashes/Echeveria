//
//  Soil.swift
//

import SwiftUI

public struct Soil: UIViewControllerRepresentable {

    let router: Router

    public init(@RouterBuilder router: () -> Router) {
        self.router = router()
    }

    public func makeUIViewController(context: Context) -> SoilViewController {
        .init()
    }

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        context.coordinator.viewController = uiViewController
        router.resolve(path: context.coordinator.manager.current, delegate: context.coordinator)
    }

    public func makeCoordinator() -> Coordinator {
        .init(router: router)
    }

    public class Coordinator: RouterDelegate {

        let router: Router
        let manager = RoutingManager()

        weak var viewController: SoilViewController? = nil

        init(router: Router) {
            self.router = router
        }

        func present<V>(transition: ScreenTransition?, content: V) where V : View {
            viewController?.currentContentViewController = UIHostingController(rootView: content)
        }
    }
}

public class SoilViewController: UIViewController {

    var currentContentViewController: UIViewController? = nil {
        willSet {
            guard let vc = currentContentViewController else { return }
            vc.removeFromParent()
            vc.view.removeFromSuperview()
        }
        didSet {
            guard let vc = currentContentViewController else { return }
            addChild(vc)
            view.addSubview(vc.view)
            tryLayoutContent()
        }
    }

    var overlayViewController: UIViewController? = nil {
        willSet {
            guard let vc = overlayViewController else { return }
            vc.removeFromParent()
            vc.view.removeFromSuperview()
        }
        didSet {
            guard let vc = overlayViewController else { return }
            addChild(vc)
            view.addSubview(vc.view)
            tryLayoutOverlay()
        }
    }

    public override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if let parent = parent {
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.deactivate(view.constraints)
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalTo: parent.view.widthAnchor),
                view.centerXAnchor.constraint(equalTo: parent.view.centerXAnchor),
                view.topAnchor.constraint(equalTo: parent.view.topAnchor),
                view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor),
            ])
        }
        tryLayoutContent()
        tryLayoutOverlay()
    }

    private func tryLayoutContent() {
        guard let parent = parent, let content = currentContentViewController else { return }

        content.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.deactivate(content.view.constraints)
        NSLayoutConstraint.activate([
            content.view.widthAnchor.constraint(equalTo: parent.view.widthAnchor),
            content.view.centerXAnchor.constraint(equalTo: parent.view.centerXAnchor),
            content.view.topAnchor.constraint(equalTo: parent.view.topAnchor),
            content.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor),
        ])
    }

    private func tryLayoutOverlay() {

    }
}
