//
//  Soil.swift
//

import SwiftUI

public struct Soil: View {

    let router: Router

    public init(@RouterBuilder router: () -> Router) {
        self.router = router()
    }

    public var body: some View {
        Text("Soil")
    }
}
