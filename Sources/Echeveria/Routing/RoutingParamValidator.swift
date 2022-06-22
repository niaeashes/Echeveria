//
//  RoutingParamValidator.swift
//

import Foundation

public protocol RoutingParamParser {
    associatedtype Param
    func parse(info: RoutingInfo) throws -> Param
}
