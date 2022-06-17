//
//  Soil.swift
//

import SwiftUI

public struct Soil: View {

    let router: Router
    let manager = RoutingManager()
    @StateObject var viewModel = ViewModel()

    public init(@RouterBuilder router: () -> Router) {
        self.router = router()
    }

    public var body: some View {
        ZStack {
            Representable(router: router, manager: manager)
            Overlay(router.leaves)
        }
        #if DEBUG
        .environmentObject(manager)
        #endif
    }

    struct Representable: UIViewControllerRepresentable {

        let router: Router
        let manager: RoutingManager

        public func makeUIViewController(context: Context) -> SoilViewController {
            .init()
        }

        public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            context.coordinator.viewController = uiViewController
        }

        public func makeCoordinator() -> Coordinator {
            .init(router: router, manager: manager)
        }
    }

    public class Coordinator: RouterDelegate {

        let router: Router
        let manager: RoutingManager

        weak var viewController: SoilViewController? = nil {
            didSet { prepare() }
        }

        init(router: Router, manager: RoutingManager) {
            self.router = router
            self.manager = manager
        }

        func prepare() {
            router.leaves.forEach {
                manager.registerRoot(path: $0.path)
            }
            router.resolve(path: manager.current, delegate: self)
        }

        func present<V>(transition: ScreenTransition?, content: V) where V : View {
            viewController?.currentContentViewController = UIHostingController(rootView: content)
        }
    }

    class ViewModel: ObservableObject {
        @Published var safeAreaInsets: UIEdgeInsets = .zero
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
}
