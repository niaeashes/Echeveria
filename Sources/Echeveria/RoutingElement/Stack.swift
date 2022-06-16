//
//  Stack.swift
//

import SwiftUI
import Combine

// MARK: - Configuration

private let TRANSITION_WIDTH_DIVISOR: CGFloat = 3
private let TRANSITION_DURATION: TimeInterval = 0.3

// MARK: - Stacker View

struct Stacker<Content: View>: UIViewControllerRepresentable {

    let router: Router
    let rootPath: String
    let content: () -> Content

    @Environment(\.navigator) var baseNavigator

    init(rootPath: String, router: Router, @ViewBuilder content: @escaping () -> Content) {
        self.router = router
        self.rootPath = rootPath
        self.content = content
    }

    func makeUIViewController(context: Context) -> StackViewController {
        .init()
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        context.coordinator.baseNavigator = baseNavigator
        context.coordinator.router = router
        context.coordinator.viewController = uiViewController
        context.coordinator.setupRoot(rootPath: rootPath, view: content())
    }

    func makeCoordinator() -> StackCoordinator {
        .init(router: router)
    }
}

class StackViewController: UIViewController, TransitionOwner {

    weak var currentViewController: UIViewController? = nil

    var pushAndPop: StackTransition? = nil

    var edgeSwipeGesture: UIScreenEdgePanGestureRecognizer

    init() {
        self.edgeSwipeGesture = .init()
        super.init(nibName: nil, bundle: nil)

        self.edgeSwipeGesture.edges = .left

        view.addGestureRecognizer(edgeSwipeGesture)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func push(viewController: UIViewController, animated: Bool = true) {

        let source: TransitionActor = currentViewController.map { StackTransitionActor($0, role: .source) } ?? BlankTransitionActor()

        let transition = StackTransition(
            source: source,
            distination: StackTransitionActor(viewController, role: .distination))

        transition.begin(viewController: self)

        if animated {
            transition.updateTransition(value: 0)
            view.layoutIfNeeded()
            UIView.animate(withDuration: TRANSITION_DURATION, delay: 0, options: .curveEaseOut, animations: {
                transition.updateTransition(value: 1)
                self.view.layoutIfNeeded()
            }, completion: { _ in
                transition.completePush()
            })
        } else {
            transition.updateTransition(value: 1)
            transition.completePush()
        }
    }

    func pop(to viewController: UIViewController, animated: Bool = true) {

        let distination: TransitionActor = currentViewController.map { StackTransitionActor($0, role: .distination) } ?? BlankTransitionActor()

        let transition = StackTransition(
            source: StackTransitionActor(viewController, role: .source),
            distination: distination)

        transition.begin(viewController: self)

        if animated {
            transition.updateTransition(value: 1)
            view.layoutIfNeeded()
            UIView.animate(withDuration: TRANSITION_DURATION, delay: 0, options: .curveEaseOut, animations: {
                transition.updateTransition(value: 0)
                self.view.layoutIfNeeded()
            }, completion: { _ in
                transition.completePop()
            })
        } else {
            transition.updateTransition(value: 0)
            transition.completePop()
        }
    }

    func transitionComplete(liveActor: TransitionActor, dropActor: TransitionActor) {
        guard let liveViewController = (liveActor as? StackTransitionActor)?.viewController else { return assertionFailure() }
        currentViewController = liveViewController
    }
}

// MARK: - Coordinator

class StackCoordinator: RouterDelegate, Navigator, StackNavigator {

    var router: Router
    var stacks: Array<StackState> = []

    weak var baseNavigator: Navigator? = nil

    struct StackState {
        let path: String
        let viewController: UIViewController
    }

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

    func dismiss() {
        baseNavigator?.dismiss()
    }

    func roopback() {
    }

    func setupRoot<Content>(rootPath: String, view: Content) where Content : View {

        guard stacks.count == 0 else { return }

        let vc = UIHostingController(rootView: view.modifier(StackModifier(navigator: self)))
        let nextStack = StackState(path: rootPath, viewController: vc)
        stacks.append(nextStack)

        viewController?.push(viewController: nextStack.viewController, animated: false)
    }

    func transition<Content>(with transition: RoutingTransition, view: Content) where Content : View {

        if transition.type == .cover {
            baseNavigator?.move(to: transition.to)
            return
        }

        let vc = UIHostingController(rootView: view.modifier(StackModifier(navigator: self, backIcon: .init(systemName: "chevron.backward"))))
        let nextStack = StackState(path: transition.to, viewController: vc)
        stacks.append(nextStack)

        #if DEBUG
        nextStack.viewController.accessibilityLabel = "Path: \(transition.to)"
        #endif

        viewController?.push(viewController: nextStack.viewController)
    }

    func pop() {
        guard stacks.count > 1, let stacker = viewController else {
            baseNavigator?.dismiss()
            return
        }

        let prevStack = stacks[stacks.count - 2]
        stacker.pop(to: prevStack.viewController)
        _ = stacks.popLast()
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

            guard let viewController = viewController, let currentViewController = viewController.currentViewController else { return assertionFailure() }

            let transition = StackTransition(
                source: StackTransitionActor(prevStack.viewController, role: .source),
                distination: StackTransitionActor(currentViewController, role: .distination))
            transition.owner = viewController
            transition.begin(viewController: viewController)
            transition.updateTransition(value: 1 - sender.translation(in: stacker.view).x / stacker.view.frame.width)

            viewController.pushAndPop = transition

        case .changed:

            guard let transition = viewController?.pushAndPop else { return }
            transition.updateTransition(value: 1 - sender.translation(in: stacker.view).x / stacker.view.frame.width)

        case .ended:

            guard let transition = viewController?.pushAndPop else { return }
            let velocity = sender.velocity(in: stacker.view)
            let translation = sender.translation(in: stacker.view)
            let result = (translation.x + velocity.x) / stacker.view.frame.width
            if result < 0.5 {
                transition.cancelPop()
            } else {
                _ = stacks.popLast()
                transition.completePop()
            }
            viewController?.pushAndPop = nil

        case .cancelled:

            guard let transition = viewController?.pushAndPop else { return }
            transition.cancelPop()
            viewController?.pushAndPop = nil

        default:
            break
        }
    }
}

// MARK: - Stacked content basic look & feel

private protocol StackNavigator {

    func pop()
}

private let CONTROL_ICON_SIZE: CGFloat = 16

private struct StackModifier: ViewModifier {

    let navigator: Navigator & StackNavigator

    @State var backIcon: Image? = nil
    @State var title: LocalizedStringKey? = nil

    var titleView: some View {
        (title.map { Text($0) } ?? Text(""))
            .bold()
    }

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    if let backIcon = backIcon {
                        Button(action: { navigator.pop() }) {
                            backIcon
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: CONTROL_ICON_SIZE, height: CONTROL_ICON_SIZE)
                                .padding((44 - CONTROL_ICON_SIZE) / 2)
                                .compositingGroup()
                        }
                    } else {
                        Spacer()
                            .frame(width: 44)
                    }

                    Spacer()

                    Spacer()
                        .frame(width: 44)
                }
                .overlay(titleView.lineLimit(1).padding(.horizontal, 44))
                .padding(.horizontal, 8)
                .frame(height: 44)
                .padding(.top, geometry.safeAreaInsets.top)
                .background(Color(UIColor.systemBackground).opacity(0.5))
                content
                    .onPreferenceChange(StackTitleKey.self) { title = $0 }
                    .onPreferenceChange(StackBackIconKey.self) { backIcon = $0 }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .modifier(NavigatorModifier(navigator: navigator))
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
}

private struct StackTitleKey: PreferenceKey {
    static var defaultValue: LocalizedStringKey? = nil

    static func reduce(value: inout LocalizedStringKey?, nextValue: () -> LocalizedStringKey?) {
        value = nextValue()
    }
}

private struct StackBackIconKey: PreferenceKey {
    static var defaultValue: Image? = nil

    static func reduce(value: inout Image?, nextValue: () -> Image?) {
        value = nextValue()
    }
}

extension View {

    public func stack(title: LocalizedStringKey) -> some View {
        preference(key: StackTitleKey.self, value: title)
    }

    public func stack(backIcon: Image) -> some View {
        preference(key: StackBackIconKey.self, value: backIcon)
    }

    public func stack(title: LocalizedStringKey, backIcon: Image) -> some View {
        preference(key: StackTitleKey.self, value: title)
            .preference(key: StackBackIconKey.self, value: backIcon)
    }
}

struct StackModifier_Previews: PreviewProvider {

    class MockNavigator: Navigator, StackNavigator {
        func move(to: String) {}
        func dismiss() {}
        func pop() {}
    }

    static var previews: some View {
        Text("Sample")
            .modifier(StackModifier(navigator: MockNavigator()))
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
