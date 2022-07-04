//
//  RoutingPath.swift
//

import Foundation

struct RoutingPath {

    let definition: String
    private let tokens: Array<Token>

    init(_ definition: String) {
        self.definition = definition
        if definition[definition.startIndex] == FEATURE_PATH_PREFIX {
            self.tokens = []
        } else {
            self.tokens = definition
                .split(separator: PATH_SEPARATOR)
                .map {
                    if $0[$0.startIndex] == ":" {
                        return .matcher($0[$0.index($0.startIndex, offsetBy: 1)..<$0.endIndex])
                    } else {
                        return .solid($0)
                    }
                }
        }
    }

    enum Token {
        case solid(CustomStringConvertible)
        case matcher(CustomStringConvertible)
    }

    func test(path: String) -> RoutingInfo? {

        if tokens.count == 0 {
            return path == definition ? .init(path: path, info: [:], errors: []) : nil
        }

        let elements = path.split(separator: PATH_SEPARATOR)

        guard elements.count == tokens.count else { return nil }

        var info: Dictionary<String, String> = [:]

        for index in elements.indices {
            let element = elements[index].description
            let token = tokens[index]
            switch token {
            case .solid(let const):
                if element != const.description { return nil }
            case .matcher(let name):
                info[name.description] = element
            }
        }

        return .init(path: path, info: info, errors: [])
    }
}

extension RoutingPath: Equatable {

    static func == (lhs: RoutingPath, rhs: RoutingPath) -> Bool {
        lhs.definition == rhs.definition
    }
}

extension RoutingPath: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(definition)
    }
}
