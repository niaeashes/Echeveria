//
//  RoutingParamParser.swift
//

public protocol RoutingParamParser {
    associatedtype Param
    func parse(info: RoutingInfo) throws -> Param
}

public struct RoutingMismatchError: Error {
    public let path: String

    public init(path: String) {
        self.path = path
    }
}

public struct InvalidPathFieldError: Error {
    public let path: String

    public init(path: String) {
        self.path = path
    }
}
