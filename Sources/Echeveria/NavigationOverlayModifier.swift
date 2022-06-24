//
//  NavigationOverlayModifier.swift
//

import SwiftUI

struct NavigationOverlayModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
    }
}

public struct RouteView: UIViewControllerRepresentable {

    let path: String

    @Environment(\.router) var router

    public init(path: String) {
        self.path = path
    }

    public func makeUIViewController(context: Context) -> UIViewController {
        let builder = RouterViewControllerBuilder()
        router.resolve(path: path, delegate: builder)
        return builder.viewController ?? UIViewController()
    }

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        let updater = RouterViewUpdater(target: uiViewController)
        router.resolve(path: path, delegate: updater)
    }

    class RouterViewControllerBuilder: RouterDelegate {

        var viewController: UIViewController? = nil
        var transition: SceneTransition? = nil

        func present<V>(transition: SceneTransition?, content: V) where V : View {
            self.viewController = UIHostingController(rootView: content)
            self.transition = transition
        }
    }

    class RouterViewUpdater: RouterDelegate {

        var viewController: UIViewController
        var transition: SceneTransition? = nil

        init(target viewController: UIViewController) {
            self.viewController = viewController
        }

        func present<V>(transition: SceneTransition?, content: V) where V : View {
            if let hostingController = viewController as? UIHostingController<V> {
                hostingController.rootView = content
            } else {
                assertionFailure()
            }
            self.transition = transition
        }
    }
}

extension View {

    public func routing(@RouterBuilder router: () -> Router) -> some View {
        environment(\.router, router())
    }
}
