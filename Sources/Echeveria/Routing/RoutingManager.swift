//
//  RoutingManager.swift
//

import Combine
import SwiftUI

struct RoutingTransition {
    let path: String
    let transition: SceneTransition?
}

class RoutingManager: ObservableObject {

    private var nodes: Dictionary<String, Node> = [
        "/": Root(path: "/"),
    ]
    private var activeNodeRoot: String = "/"
    private var firstLauncherPath: String? = nil

    private let transitionSubject: PassthroughSubject<RoutingTransition, Never> = .init()
    var transition: AnyPublisher<RoutingTransition, Never> {
        transitionSubject.eraseToAnyPublisher()
    }

    var current: String { nodes[activeNodeRoot]?.path ?? "/" }
    var depth: Int { nodes[activeNodeRoot]?.depth ?? 0 }
    init() {}

    init(with router: Router) {
        router.leaves.forEach {
            registerRoot(path: $0.path)
            if $0.placement == .launcher, firstLauncherPath == nil {
                firstLauncherPath = $0.path
                push(path: $0.path)
            }
        }
    }

    func push(path: String, transition: SceneTransition? = nil) {

        if nodes.keys.contains(path) {
            if activeNodeRoot != path {
                objectWillChange.send()
                activeNodeRoot = path
                transitionSubject.send(.init(path: current, transition: transition))
            }
            return
        }

        guard let node = nodes[activeNodeRoot] else { return assertionFailure() }
        objectWillChange.send()
        let stalk = Stalk(root: node, path: path, transition: transition)
        nodes[activeNodeRoot] = stalk
        print(stalk.transition)
        transitionSubject.send(.init(path: current, transition: stalk.transition))
    }

    @discardableResult
    func pop(transition: SceneTransition? = nil) -> Bool {
        guard let stalk = nodes[activeNodeRoot] as? Stalk else { return false }
        objectWillChange.send()
        nodes[activeNodeRoot] = stalk.root
        print(stalk.path, stalk.transition)
        transitionSubject.send(.init(path: current, transition: transition ?? stalk.transition?.backTransition))
        return true
    }

    func registerRoot(path: String) {
        assert(!nodes.keys.contains(path), "Warning: Multiple registrations are deprecated.")
        nodes[path] = Root(path: path)
    }
}

private protocol Node {
    var path: String { get }
    var rootPath: String { get }
    var depth: Int { get }
}

private struct Root: Node {
    let path: String
    var rootPath: String { path }
    let depth: Int = 0
}

private struct Stalk: Node {
    let root: Node
    let path: String
    var depth: Int { root.depth + 1 }
    var transition: SceneTransition?

    var rootPath: String { root.path }
}

// MARK: - for Debug

extension RoutingManager: CustomDebugStringConvertible {
    var debugDescription: String {
        nodes
            .compactMap { ($0.value as? CustomDebugStringConvertible)?.debugDescription }
            .joined(separator: "\n")
    }
}

extension Stalk: CustomDebugStringConvertible {

    var debugDescription: String {
        if let rootDebugDescription = (root as? CustomDebugStringConvertible)?.debugDescription {
            return "\(rootDebugDescription) > \(path)"
        } else {
            return "> \(path)"
        }
    }
}

extension Root: CustomDebugStringConvertible {
    var debugDescription: String {
        return "+ \(path)"
    }
}
