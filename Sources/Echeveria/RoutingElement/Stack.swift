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
        .init(rootView: content().modifier(NavigatorModifier(navigator: context.coordinator)))
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

        private var reloadNotificaitonCancellable: AnyCancellable! = nil

        weak var viewController: StackViewController? = nil {
            didSet {
                viewController?.edgeSwipeGesture
                    .addTarget(self, action: #selector(self.onEdgePan(_:)))
            }
        }

        init(router: Router) {
            self.router = router
            self.reloadNotificaitonCancellable = NotificationCenter.echeveria
                .publisher(for: .RetapLauncher)
                .filter { ($0.userInfo?["path"] as? String) == self.stacks.first?.path }
                .sink { [weak self] _ in
                    self?.popToRoot()
                }
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
        }

        func transition<Content>(with transition: RoutingTransition, view: Content) where Content : View {

            let nextStack = StackState(path: transition.to, viewController: UIHostingController(rootView: view.modifier(NavigatorModifier(navigator: self))))
            stacks.append(nextStack)

            #if DEBUG
            nextStack.viewController.accessibilityLabel = "Path: \(transition.to)"
            #endif

            viewController?.push(viewController: nextStack.viewController)
        }

        func popToRoot() {
            guard stacks.count > 1, let stack = stacks.first else { return }
            stacks = [stack]
            viewController?.pop(to: stack.viewController)
        }

        @objc func onEdgePan(_ sender: UIScreenEdgePanGestureRecognizer) {

            guard stacks.count > 1, let stacker = viewController else { return }

            let prevStack = stacks[stacks.count - 2]

            switch sender.state {
            case .began:
                stacker.beginPop(prevViewController: prevStack.viewController)
                stacker.updatePopTransition(value: sender.translation(in: stacker.view).x / stacker.view.frame.width)
            case .changed:
                stacker.updatePopTransition(value: sender.translation(in: stacker.view).x / stacker.view.frame.width)
            case .ended:
                let velocity = sender.velocity(in: stacker.view)
                let translation = sender.translation(in: stacker.view)
                let result = (translation.x + velocity.x) / stacker.view.frame.width
                if result < 0.5 {
                    viewController?.cancelPop()
                } else {
                    _ = stacks.popLast()
                    viewController?.completePop()
                }
            default:
                break
            }
        }
    }

    struct StackState {
        let path: String
        let viewController: UIViewController
    }

    class StackViewController: UIViewController {

        weak var currentViewController: UIViewController? = nil
        var currentCenterX: NSLayoutConstraint? = nil

        weak var transitionViewController: UIViewController? = nil
        var transitionCenterX: NSLayoutConstraint? = nil

        var edgeSwipeGesture: UIScreenEdgePanGestureRecognizer

        init(rootView: ModifiedContent<Content, NavigatorModifier>) {
            self.edgeSwipeGesture = .init()
            super.init(nibName: nil, bundle: nil)
            show(vc: UIHostingController(rootView: rootView))

            self.edgeSwipeGesture.edges = .left

            view.addGestureRecognizer(edgeSwipeGesture)
        }

        required init?(coder: NSCoder) {
            fatalError()
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
                self.transitionViewController?.view.removeFromSuperview()
                self.transitionViewController?.removeFromParent()
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
                self.transitionViewController?.view.removeFromSuperview()
                self.transitionViewController?.removeFromParent()
                self.completeTransition()
            })
        }

        private func show(vc: UIViewController, at index: Int? = nil) {

            addChild(vc)

            vc.view.translatesAutoresizingMaskIntoConstraints = false
            vc.additionalSafeAreaInsets.top = 44

            if let index = index {
                view.insertSubview(vc.view, at: index)
            } else {
                view.addSubview(vc.view)
            }

            currentViewController = vc

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
    }
}
// MARK: - Interactive Pop View Controller

extension Stacker.StackViewController {

    func beginPop(prevViewController vc: UIViewController) {

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

    /// @param value is from 0.0 to 1.0
    func updatePopTransition(value: CGFloat) {

        currentCenterX?.constant = view.frame.width * value
        transitionCenterX?.constant = -view.frame.width * (1 - value) / TRANSITION_WIDTH_DIVISOR
    }

    func completePop() {
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
        })
    }

    func cancelPop() {
        currentCenterX?.constant = 0
        transitionCenterX?.constant = -view.frame.width / TRANSITION_WIDTH_DIVISOR
        UIView.animate(withDuration: 0.22, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.transitionViewController?.removeFromParent()
            self.transitionViewController?.view.removeFromSuperview()
            self.transitionViewController = nil
            self.transitionCenterX = nil
        })
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
        let stacker = Stacker(rootPath: path, router: router, content: { content(transition) })
            .ignoresSafeArea()
        delegate.transition(with: transition, view: stacker)
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
