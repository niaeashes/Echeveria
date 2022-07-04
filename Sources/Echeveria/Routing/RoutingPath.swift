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

    func test(path pathString: String) -> RoutingInfo? {

        if tokens.count == 0 {
            return pathString == definition ? .init(path: pathString, params: [:], query: [:], errors: []) : nil
        }

        let splitedPath = pathString.split(separator: QUERY_STARTER, maxSplits: 2)
        let path = splitedPath[0]
        let queryStrings = (splitedPath.indices.contains(1) ? splitedPath[1] : "").split(separator: QUERY_SEPARATOR)

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

        var query: Dictionary<String, String> = [:]

        for queryString in queryStrings {
            let splited = queryString.split(separator: QUERY_PAIR_CHARACTER, maxSplits: 2)
            if splited.count == 1 {
                query[splited[0].description] = ""
            }
            if splited.count == 2 {
                query[splited[0].description] = splited[1].description
            }
        }

        return .init(path: path.description, params: info, query: query, errors: [])
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
