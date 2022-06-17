//
//  RoutingManager.swift
//

import Combine

class RoutingManager: ObservableObject {

    private var nodes: Dictionary<String, Node> = [
        "/": Root(path: "/"),
    ]
    private var activeNodeRoot: String = "/"
    private var firstLauncherPath: String? = nil

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

    func push(path: String) {

        if nodes.keys.contains(path) {
            if activeNodeRoot != path {
                objectWillChange.send()
                activeNodeRoot = path
            }
            return
        }

        guard let node = nodes[activeNodeRoot] else { return assertionFailure() }
        objectWillChange.send()
        nodes[activeNodeRoot] = Stalk(root: node, path: path)
    }

    @discardableResult
    func pop() -> Bool {
        guard let stalk = nodes[activeNodeRoot] as? Stalk else { return false }
        nodes[activeNodeRoot] = stalk.root
        return true
    }

    func registerRoot(path: String) {
        assert(!nodes.keys.contains(path), "Warning: Multiple registrations are deprecated.")
        nodes[path] = Root(path: path)
    }

    var current: String { nodes[activeNodeRoot]?.path ?? "/" }
}

private protocol Node {
    var path: String { get }
    var rootPath: String { get }
}

private struct Root: Node {
    let path: String
    var rootPath: String { path }
}

private struct Stalk: Node {
    let root: Node
    let path: String

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
