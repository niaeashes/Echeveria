//
//  File.swift
//  
//
//  Created by shota-nagasaki on 2022/06/25.
//

import SwiftUI

public struct RouteView: View {

    let path: String

    @Environment(\.router) var router

    public init(path: String) {
        self.path = path
    }

    public var body: AnyView {
        router.resolve(path: path)
    }
}
