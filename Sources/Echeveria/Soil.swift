//
//  Soil.swift
//

import SwiftUI
import Combine

public struct Soil: View {

    @StateObject var viewModel: ViewModel

    public init(@RouterBuilder router: @escaping () -> Router) {
        self._viewModel = StateObject(wrappedValue: .init(router: router()))
    }

    public var body: some View {
        ZStack {
            Representable(viewModel: viewModel)
            Overlay(viewModel.router.leaves, isShowLauncher: viewModel.isShowLauncher)
        }
        .environment(\.navigator, viewModel)
        .environment(\.sceneOwner, viewModel)
        #if DEBUG
        .environmentObject(viewModel.manager)
        #endif
    }

    struct Representable: UIViewControllerRepresentable {

        typealias Coordinator = ViewModel

        @ObservedObject var viewModel: ViewModel

        init(viewModel: ViewModel) {
            self.viewModel = viewModel
        }

        public func makeUIViewController(context: Context) -> SoilViewController {
            let vc = SoilViewController()
            context.coordinator.viewController = vc
            return vc
        }

        public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            /* Nothing to do */
        }

        public func makeCoordinator() -> Coordinator {
            viewModel
        }
    }

    public class ViewModel: ObservableObject, RouterDelegate, Navigator, SceneOwner {

        let router: Router
        let manager: RoutingManager
        var cancellables: Array<AnyCancellable> = []

        init(router: Router) {
            self.router = router
            self.manager = .init(with: self.router)

            manager
                .transition
                .sink { [weak self] transition in self?.queueTransition(transition) }
                .store(in: &cancellables)
        }

        @Published var safeAreaInsets: UIEdgeInsets = .zero
        @Published var isShowLauncher = true

        weak var viewController: SoilViewController? = nil {
            didSet {
                router.resolve(path: manager.current, delegate: self)
            }
        }

        public var currentViewController: UIViewController? {
            viewController?.currentContentViewController
        }

        public func showLauncher() {
            withAnimation { isShowLauncher = true }
        }

        public func hideLauncher() {
            withAnimation { isShowLauncher = false }
        }

        public func transitionCancel() {
        }

        public func transitionFinish(context: SceneTransitionContext) {
            self.viewController?.currentContentViewController = context.distination
        }

        private func queueTransition(_ transition: RoutingTransition) {
            DispatchQueue.main.async {
                self.router.resolve(transition: transition, delegate: self)
            }
        }

        func present<V>(transition: SceneTransition?, content: V) where V : View {

            guard let viewController = viewController else { return assertionFailure() }

            let vc = UIHostingController(rootView: content)

            if let transition = transition {
                viewController.transition(transition, owner: self, viewController: vc)
            } else {
                viewController.currentContentViewController = vc
            }
        }

        public func move(to path: String) {
            manager.push(path: path)
        }

        public func move(to path: String, with transition: SceneTransition) {
            manager.push(path: path)
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

    func transition(_ transition: SceneTransition, owner: SceneOwner, viewController: UIViewController) {
        guard let source = currentContentViewController else {
            currentContentViewController = viewController
            return
        }
        let context = SceneTransitionContext(owner: owner, container: self, source: source, distination: viewController)
        transition.prepare(context: context)
        transition.finish(context: context)
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
