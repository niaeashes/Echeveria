//
//  RoutingInfo.swift
//

public struct RoutingInfo {
    public let path: String
    public let params: Dictionary<String, String>
    public let query: Dictionary<String, String>
    public let errors: Array<Error>
}

extension RoutingInfo {

    public func join(_ path: String) -> String {
        let currentPath = self.path.split(separator: PATH_SEPARATOR).filter { !$0.isEmpty }
        return PATH_SEPARATOR.description + (currentPath + path.split(separator: PATH_SEPARATOR).filter { !$0.isEmpty })
            .reduce([]) { result, token in
                var result = result
                if token.description == PARENT_PATH_ALIAS {
                    if result.count > 0 {
                        result.removeLast()
                    }
                    return result
                }
                if token.description != CURRENT_PATH_ALIAS.description {
                    return result + [token.description]
                }
                return result
            }
            .joined(separator: PATH_SEPARATOR.description)
    }
}
