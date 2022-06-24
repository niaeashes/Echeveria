//
//  RouteView.swift
//

import SwiftUI

public struct RouteView: UIViewControllerRepresentable {

    /// Initial and root path
    let path: String

    @Environment(\.router) var router

    public init(path: String) {
        self.path = path
    }

    public func makeUIViewController(context: Context) -> ViewController {
        let vc = ViewController()
        router.resolve(path: path, delegate: vc)
        return vc
    }

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        router.resolve(path: path, delegate: uiViewController)
    }

    public class ViewController: UIViewController, RouterDelegate {

        var currentContentViewController: UIViewController? = nil {
            willSet {
                guard let vc = currentContentViewController else { return }
                vc.removeFromParent()
                vc.view.removeFromSuperview()
            }
            didSet {
                guard let vc = currentContentViewController else { return }
                if vc.parent != self {
                    addChild(vc)
                }
                if vc.view.superview != view {
                    view.insertSubview(vc.view, at: 0)
                }
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

        func present<V>(transition: SceneTransition?, content: V) where V : View {
            currentContentViewController = UIHostingController(rootView: content)
        }

        func transition(_ transition: SceneTransition, owner: SoilController, viewController: UIViewController) {
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

    struct SoilModifier: ViewModifier {

        let state: RoutingState

        @Environment(\.soilController) var soilController
        @Environment(\.navigator) var navigator

        func body(content: Content) -> some View {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    if state.hasBack {
                        Button(action: { navigator.moveToBack() }) {
                            Image(systemName: "chevron.backward")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                                .padding(14)
                                .compositingGroup()
                        }
                    } else {
                        Spacer()
                    }
                    Spacer()
                    Spacer()
                }
                .frame(height: 44)
                .padding(.horizontal, 8)
                .overlay(Text(state.title).bold())
                .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.top))
                content
                    .frame(maxHeight: .infinity)
            }
        }
    }
}
