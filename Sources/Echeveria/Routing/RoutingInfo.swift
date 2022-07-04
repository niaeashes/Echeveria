//
//  RoutingInfo.swift
//

public struct RoutingInfo {
    public let path: String
    let info: Dictionary<String, String>
    public let errors: Array<Error>

    public subscript(_ name: String) -> String? {
        info[name]
    }
}