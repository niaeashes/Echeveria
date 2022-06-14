//
//  Stack.swift
//

import SwiftUI
import Combine

// MARK: - Configuration

private let TRANSITION_WIDTH_DIVISOR: CGFloat = 3

// MARK: - Stacker View

struct Stacker<Content: View>: UIViewControllerRepresentable {

    let router: Router
    let rootPath: String
    let content: () -> Content

    init(rootPath: String, router: Router, @ViewBuilder content: @escaping () -> Content) {
        self.router = router
        self.rootPath = rootPath
        self.content = content
    }

    func makeUIViewController(context: Context) -> StackViewController {
        .init(rootPath: rootPath, rootView: content().modifier(NavigatorModifier(navigator: context.coordinator)))
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        context.coordinator.router = router
        context.coordinator.viewController = uiViewController
        context.coordinator.setupRoot(rootPath: rootPath, view: content().modifier(NavigatorModifier(navigator: context.coordinator)))
    }

    func makeCoordinator() -> Coordinator {
        .init(router: router)
    }

    class Coordinator: Navigator, RouterDelegate {

        var router: Router
        var stacks: Array<StackState> = []

        weak var viewController: StackViewController? = nil

        init(router: Router) {
            self.router = router
        }

        func move(to path: String) {
            router.resolve(from: stacks.last?.path ?? "/", to: path, delegate: self)
        }

        func roopback() {
        }

        func setupRoot<Content>(rootPath: String, view: Content) where Content : View {
            guard stacks.count == 0 else { return }
            let nextStack = StackState(path: rootPath, viewController: UIHostingController(rootView: view.modifier(NavigatorModifier(navigator: self))))
            stacks.append(nextStack)
            viewController?.push(viewController: nextStack.viewController)
        }

        func transition<Content>(with transition: RoutingTransition, view: Content) where Content : View {
            let nextStack = StackState(path: transition.to, viewController: UIHostingController(rootView: view.modifier(NavigatorModifier(navigator: self))))
            stacks.append(nextStack)
            viewController?.push(viewController: nextStack.viewController)
        }
    }

    struct StackState {
        let path: String
        let viewController: UIViewController
    }

    class StackViewController: UIViewController {

        let rootPath: String
        var stacks: Array<UIViewController> = []

        var rootView: ModifiedContent<Content, NavigatorModifier> {
            didSet { (stacks.first as? UIHostingController<ModifiedContent<Content, NavigatorModifier>>)?.rootView = rootView }
        }

        weak var currentViewController: UIViewController? = nil
        var currentCenterX: NSLayoutConstraint? = nil

        weak var transitionViewController: UIViewController? = nil
        var transitionCenterX: NSLayoutConstraint? = nil

        var edgeSwipeGesture: UIScreenEdgePanGestureRecognizer

        private var reloadNotificaitonCancellable: AnyCancellable! = nil

        init(rootPath: String, rootView: ModifiedContent<Content, NavigatorModifier>) {
            self.rootPath = rootPath
            self.rootView = rootView
            self.edgeSwipeGesture = .init()
            super.init(nibName: nil, bundle: nil)
            show(vc: UIHostingController(rootView: rootView))

            self.edgeSwipeGesture.addTarget(self, action: #selector(self.onEdgePan(_:)))
            self.edgeSwipeGesture.edges = .left

            view.addGestureRecognizer(edgeSwipeGesture)

//            self.reloadNotificaitonCancellable = NotificationCenter.echeveria
//                .publisher(for: .RetapLauncher)
//                .filter { ($0.userInfo?["path"] as? String) == rootPath }
//                .sink { [weak self] _ in
//                    print("reload!!!", rootPath)
//                    self?.popToRoot()
//                }
        }

        required init?(coder: NSCoder) {
            fatalError()
        }

        public override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            if let parent = parent {
                view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    view.topAnchor.constraint(equalTo: parent.view.topAnchor),
                    view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor),
                    view.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor),
                ])
            }
        }

        @objc func onEdgePan(_ sender: UIScreenEdgePanGestureRecognizer) {
            if stacks.count <= 1 { return }

            switch sender.state {
            case .began:
                if let vc = getPrevViewController() {
                    addChild(vc)
                    view.insertSubview(vc.view, at: 0)

                    vc.view.translatesAutoresizingMaskIntoConstraints = false

                    let centerX = vc.view.centerXAnchor.constraint(equalTo: view.centerXAnchor)
                    NSLayoutConstraint.activate([
                        vc.view.topAnchor.constraint(equalTo: view.topAnchor),
                        vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                        vc.view.widthAnchor.constraint(equalTo: view.widthAnchor),
                        centerX,
                    ])

                    transitionViewController = vc
                    transitionCenterX = centerX
                }
                currentCenterX?.constant = sender.translation(in: view).x
                transitionCenterX?.constant = -(view.frame.width - sender.translation(in: view).x) / TRANSITION_WIDTH_DIVISOR
            case .changed:
                currentCenterX?.constant = sender.translation(in: view).x
                transitionCenterX?.constant = -(view.frame.width - sender.translation(in: view).x) / TRANSITION_WIDTH_DIVISOR
            case .ended:
                let velocity = sender.velocity(in: view)
                let translation = sender.translation(in: view)

                let result = (translation.x + velocity.x) / view.frame.width

                if result < 0.5 {
                    // cancel
                    currentCenterX?.constant = 0
                    UIView.animate(withDuration: 0.22, animations: {
                        self.view.layoutIfNeeded()
                    }, completion: { _ in
                        self.transitionViewController?.removeFromParent()
                        self.transitionViewController?.view.removeFromSuperview()
                        self.transitionViewController = nil
                        self.transitionCenterX = nil
                    })
                } else {
                    // complete
                    currentCenterX?.constant = view.frame.width
                    transitionCenterX?.constant = 0
                    UIView.animate(withDuration: 0.2, animations: {
                        self.view.layoutIfNeeded()
                    }, completion: { _ in
                        self.currentViewController?.removeFromParent()
                        self.currentViewController?.view.removeFromSuperview()
                        self.currentViewController = self.transitionViewController
                        self.currentCenterX = self.transitionCenterX
                        self.completeTransition()
                        _ = self.stacks.popLast()
                    })
                }
            default:
                currentCenterX?.constant = 0
            }
        }

        func push(viewController: UIViewController) {

            let slideDistance = self.view.frame.width

            transitionViewController = currentViewController
            transitionCenterX = currentCenterX

            show(vc: viewController)

            currentCenterX?.constant = slideDistance
            self.view.layoutIfNeeded()

            currentCenterX?.constant = 0
            transitionCenterX?.constant = -slideDistance / TRANSITION_WIDTH_DIVISOR

            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.transitionViewController?.removeFromParent()
                self.transitionViewController?.view.removeFromSuperview()
                self.completeTransition()
            })
        }

        func pop(to viewController: UIViewController) {

            let slideDistance = self.view.frame.width

            transitionViewController = currentViewController
            transitionCenterX = currentCenterX

            show(vc: viewController, at: 0)

            currentCenterX?.constant = -slideDistance / TRANSITION_WIDTH_DIVISOR
            view.layoutIfNeeded()

            currentCenterX?.constant = 0
            transitionCenterX?.constant = slideDistance

            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.transitionViewController?.removeFromParent()
                self.transitionViewController?.view.removeFromSuperview()
                self.completeTransition()
            })
        }

        private func show(vc: UIViewController, at index: Int? = nil) {

            addChild(vc)
            if let index = index {
                view.insertSubview(vc.view, at: index)
            } else {
                view.addSubview(vc.view)
            }

            currentViewController = vc

            vc.view.translatesAutoresizingMaskIntoConstraints = false

            let centerX = vc.view.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            NSLayoutConstraint.activate([
                vc.view.topAnchor.constraint(equalTo: view.topAnchor),
                vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                vc.view.widthAnchor.constraint(equalTo: view.widthAnchor),
                centerX,
            ])
            currentCenterX = centerX
        }

        private func completeTransition() {
            transitionViewController = nil
            transitionCenterX = nil
        }

        func getPrevViewController() -> UIViewController? {
            if stacks.count <= 1 { return nil }
            return stacks[stacks.count - 2]
        }
    }
}

// MARK: - Stack route

public struct Stack<Content: View>: Route, RoutingElement {

    public init(path: String, @ViewBuilder content: @escaping (RoutingTransition) -> Content) {
        self.path = path
        self.content = content
    }

    public let path: String
    let content: (RoutingTransition) -> Content

    public func apply(router: Router) {
        router.register(route: self)
    }

    public func resolve(router: Router, transition: RoutingTransition, delegate: RouterDelegate) {
        delegate.transition(with: transition, view: Stacker(rootPath: path, router: router) { content(transition) })
    }
}

// MARK: - Extension

extension Launcher {

    public init<Content: View>(title: LocalizedStringKey, systemImage: String, route: () -> Stack<Content>) where RouteObject == Stack<Content> {
        self.title = title
        self.icon = .init(systemName: systemImage)
        self.path = route().path
        self.route = route()
    }
}
