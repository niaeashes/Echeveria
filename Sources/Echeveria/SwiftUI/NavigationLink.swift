//
//  NavigationLink.swift
//

import SwiftUI

extension NavigationLink {

    public init(path: Binding<String?>) where Destination == RouteView, Label == EmptyView {
        self.init(
            isActive: .init(
                get: { path.wrappedValue != nil },
                set: { if $0 == false { path.wrappedValue = nil } }
            ),
            destination: { RouteView(path: path.wrappedValue ?? NOT_FOUND_FEATURE_PATH) },
            label: { EmptyView() }
        )
    }
}
