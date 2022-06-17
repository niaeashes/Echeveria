//
//  RoutingManager.swift
//

import Foundation

class RoutingManager: ObservableObject {

    private var nodes: Dictionary<String, Node> = [
        "/": Root(path: "/"),
    ]
    private var activeNodeRoot: String = "/"

    func push(path: String) {

        if nodes.keys.contains(path) {
            if activeNodeRoot != path {
                activeNodeRoot = path
            }
            return
        }

        guard let node = nodes[activeNodeRoot] else { return assertionFailure() }
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
