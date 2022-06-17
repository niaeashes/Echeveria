//
//  Soil.swift
//

import SwiftUI
import Combine

public struct Soil: View {

    let router: Router
    let manager: RoutingManager
    let navigator = PassthroughNavigator()
    @StateObject var viewModel = ViewModel()

    public init(@RouterBuilder router: () -> Router) {
        self.router = router()
        self.manager = .init(with: self.router)
    }

    public var body: some View {
        ZStack {
            Representable(router: router, manager: manager, navigator: navigator)
            Overlay(router.leaves)
        }
        .environment(\.navigator, navigator)
        #if DEBUG
        .environmentObject(manager)
        #endif
    }

    struct Representable: UIViewControllerRepresentable {

        let router: Router
        @ObservedObject var manager: RoutingManager
        let navigator: PassthroughNavigator

        init(router: Router, manager: RoutingManager, navigator: PassthroughNavigator) {
            self.router = router
            self.manager = manager
            self.navigator = navigator
        }

        public func makeUIViewController(context: Context) -> SoilViewController {
            let vc = SoilViewController()
            context.coordinator.viewController = vc
            navigator.rootNavigator = context.coordinator
            router.resolve(path: manager.current, delegate: context.coordinator)
            return vc
        }

        public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            router.resolve(path: manager.current, delegate: context.coordinator)
        }

        public func makeCoordinator() -> Coordinator {
            .init(manager: manager)
        }
    }

    public class Coordinator: RouterDelegate, Navigator {

        let manager: RoutingManager

        weak var viewController: SoilViewController? = nil

        init(manager: RoutingManager) {
            self.manager = manager
        }

        func present<V>(transition: SceneTransition?, content: V) where V : View {
            viewController?.currentContentViewController = UIHostingController(rootView: content)
        }

        public func present(path: String) {
            manager.push(path: path)
        }

        public func present<T>(path: String, with transition: T.Type) where T : SceneTransition {
            manager.push(path: path)
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
