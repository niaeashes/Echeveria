//
//  RoutingInfo.swift
//

public struct RoutingInfo {
    public let path: String
    public let params: Dictionary<String, String>
    public let query: Dictionary<String, String>
    public let errors: Array<Error>
}
