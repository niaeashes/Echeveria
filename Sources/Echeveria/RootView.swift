
import SwiftUI

struct RootView: UIViewControllerRepresentable {

    let routings: RoutingCollection

    init(@RoutingBuilder routings: () -> RoutingCollection) {
        self.routings = routings()
    }

    func makeUIViewController(context: Context) -> ViewController {
        context.coordinator.containerViewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        .init(routes: routings)
    }

    class Coordinator: RouterDelegate, Navigator {

        var router: ConcreteRouter
        var currentPath = "/"
        var pathBinding: Binding<String> {
            .init(
                get: { [router] in router.path },
                set: { [weak self] in self?.move(to: $0) }
            )
        }

        init(routes: RoutingElement) {
            router = .init(source: routes)

            containerViewController.hasTabBar = router.hasTabs
            containerViewController.tabViewController.rootView = .init(accessors: router.tabs, path: pathBinding)

            router.tabs.forEach { router.prepare(path: $0.path, delegate: self) }

            router.resolve(from: "/", to: router.tabs.first?.path ?? "/", delegate: self)
        }

        var containerViewController = ViewController()
        private let contentPool = ContentViewControllerPool()

        func roopback() {
            print("roopback")
        }

        func transition<Content>(with transition: RoutingTransition, view: Content) where Content: View {

            print(transition)

            defer { currentPath = transition.to }

            let viewController: UIHostingController<ModifiedContent<Content, NavigatorModifier>> = contentPool.restore(path: transition.to) {
                .init(rootView: view.modifier(NavigatorModifier(navigator: self)))
            }

            switch transition.type {
            case .prepare:
                contentPool.store(path: transition.to, content: viewController)
            case .slideToRight:
                containerViewController.switchContent(viewController: viewController, transition: transition)
            case .slideToLeft:
                containerViewController.switchContent(viewController: viewController, transition: transition)
            default:
                if transition.from == "/" {
                    containerViewController.switchContent(viewController: viewController)
                } else {
                    containerViewController.openCover(viewController: viewController)
                }
            }
        }

        func move(to path: String) {
            router.resolve(from: currentPath, to: path, delegate: self)
        }
    }

    class ViewController: UIViewController { // , TransitionCallback {

        weak var contentViewController: UIViewController? = nil {
            didSet { refreshContent(oldViewController: oldValue) }
        }
        weak var coverViewController: UIViewController? = nil

//        private var transitionRunner: AnimationRunner? = nil
//        private var transition: TransitionContainer? = nil

        var hasTabBar: Bool = false
        var tabViewController = ContentViewController<ConductorTabView>(rootView: .init(accessors: [], path: .constant("")))
        var containerView = UIView()
        var contentCenterX: NSLayoutConstraint? = nil

        override func viewDidLoad() {
            super.viewDidLoad()
            view.translatesAutoresizingMaskIntoConstraints = false
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.accessibilityLabel = "Container View"

            view.addSubview(containerView)

            // MARK: setup tab view controller
            tabViewController.view.translatesAutoresizingMaskIntoConstraints = false
            addChild(tabViewController)
            containerView.addSubview(tabViewController.view)
        }

        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            if let parent = parent {
                NSLayoutConstraint.deactivate(tabViewController.view.constraints)
                NSLayoutConstraint.activate([
                    tabViewController.view.topAnchor.constraint(equalTo: parent.view.safeAreaLayoutGuide.bottomAnchor, constant: -49),
                    tabViewController.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor),
                    tabViewController.view.leadingAnchor.constraint(equalTo: parent.view.safeAreaLayoutGuide.leadingAnchor),
                    tabViewController.view.trailingAnchor.constraint(equalTo: parent.view.safeAreaLayoutGuide.trailingAnchor),
                ])
            }
            tryLayoutContainer()
            tryLayoutContent()
        }

        func switchContent<Content>(viewController vc: UIHostingController<Content>, transition: RoutingTransition? = nil) where Content: View {

            logger.info("Switch Content: \(Content.self)")

            if let oldViewController = contentViewController, let oldConstant = contentCenterX {

                // Prepare

                contentViewController = vc

                var directionSign: CGFloat = 1 // +1 means content slide to left
                if transition?.type == .slideToRight { directionSign = -1 }

                let slideWidth: CGFloat = view.frame.width / 8

                vc.view.layer.opacity = 0

                contentCenterX?.constant = -directionSign * slideWidth
                containerView.insertSubview(oldViewController.view, at: 0)
                view.layoutIfNeeded()

                // Animate

                contentCenterX?.constant = 0
                oldConstant.constant = directionSign * slideWidth

                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: { [weak view] in
                    view?.layoutIfNeeded()
                    vc.view.layer.opacity = 1
                }, completion: { _ in
                    oldViewController.removeFromParent()
                    oldViewController.view.removeFromSuperview()
                })

            } else {
                contentViewController?.removeFromParent()
                contentViewController?.view.removeFromSuperview()
                contentViewController = vc
            }
        }

        func openCover<Content>(viewController vc: UIHostingController<Content>) where Content: View {
//            let transition = TransitionContainer(from: containerView, to: vc.view, duration: 0.5, animator: CoverAnimator())
//            DispatchQueue.main.async {
//                transition.start()
//            }
//            self.transition = transition
//
//            view.addSubview(transition.containerView)
//            NSLayoutConstraint.activate([
//                transition.containerView.topAnchor.constraint(equalTo: view.topAnchor),
//                transition.containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//                transition.containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//                transition.containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            ])
        }

        override func viewWillLayoutSubviews() {
            super.viewWillLayoutSubviews()
            tabViewController.view.isHidden = !hasTabBar
        }

        private func refreshContent(oldViewController: UIViewController?) {

            tryLayoutContent()
        }

//        func transitionWillStart(container: TransitionContainer) {
//        }
//
//        func transitionDidFinish(container: TransitionContainer) {
//            if container.sourceView == containerView { // Container View is always in view
//                view.addSubview(containerView)
//                tryLayoutContainer()
//            }
//        }

        private func tryLayoutContainer() {

            guard let parent = parent else { return }

            NSLayoutConstraint.deactivate(view.constraints)
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: view.topAnchor),
                containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                view.topAnchor.constraint(equalTo: parent.view.topAnchor),
                view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor),
                view.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor),
            ])
        }

        private func tryLayoutContent() {

            guard let parent = parent, let content = contentViewController, view.superview != nil else { return }

            logger.info("Try layout conductor content view")
            if content.parent == nil {
                addChild(content)
            }
            if content.view.superview == nil {
                content.view.translatesAutoresizingMaskIntoConstraints = false
                containerView.insertSubview(content.view, at: 0)
                content.additionalSafeAreaInsets.bottom = hasTabBar ? 49 : 0
                let centerX = content.view.centerXAnchor.constraint(equalTo: parent.view.centerXAnchor)

                NSLayoutConstraint.activate([
                    content.view.topAnchor.constraint(equalTo: parent.view.topAnchor),
                    parent.view.bottomAnchor.constraint(equalTo: content.view.bottomAnchor),
                    content.view.widthAnchor.constraint(equalTo: parent.view.widthAnchor),
                    centerX
                ])

                contentCenterX = centerX
            }

            return
        }
    }

    struct ConductorTabView: View {

        let accessors: Array<RouteAccessor>
        @Binding var path: String

        var body: some View {
            HStack(alignment: .top, spacing: 0) {
                ForEach(accessors, id: \.path) { accessor in
                    VStack(spacing: 4) {
                        accessor.image
                        Text(accessor.title)
                            .font(.system(size: 9))
                    }
                    .frame(height: 49)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture { path = accessor.path }
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }

    class ContentViewController<Content: View>: UIHostingController<Content> {

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            view.invalidateIntrinsicContentSize()
        }
    }
}

struct CurrentPathEnvironmentKey: EnvironmentKey {
    static var defaultValue: String = "/"
}

extension EnvironmentValues {
    var path: String {
        get { self[CurrentPathEnvironmentKey.self] }
        set { self[CurrentPathEnvironmentKey.self] = newValue }
    }
}

// MARK: - Content View Controller Pool

private class ContentViewControllerPool {

    private var pool: Dictionary<String, UIViewController> = [:]

    func restore(path: String) -> UIViewController? {
        print("restore: \(path) \(pool.keys.contains(path) ? "Hit" : "Miss")")
        return pool[path]
    }

    func restore<VC>(path: String, initializer: () -> VC) -> VC where VC: UIViewController {
        (restore(path: path) as? VC) ?? initializer()
    }

    func store<VC>(path: String, content: VC) where VC: UIViewController {
        print("store: \(path)")
        pool[path] = content
    }
}

#if canImport(UIKit)

import UIKit

private extension UIViewController {

    func store(path: String, to pool: ContentViewControllerPool) -> Self {
        pool.store(path: path, content: self)
        return self
    }
}

#endif