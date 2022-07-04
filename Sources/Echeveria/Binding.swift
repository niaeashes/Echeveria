//
//  PathController.swift
//

import Combine
import SwiftUI

extension Binding where Value == Optional<String> {

    init(_ base: Binding<String?>, except: Array<RoutingPath>) {
        self.init(
            get: {
                guard let current = base.wrappedValue else { return nil }
                for path in except {
                    if path.test(path: current) != nil { return nil }
                }
                return current
            },
            set: { base.wrappedValue = $0 }
        )
    }

    public init(_ base: Binding<String?>, except: Array<String>) {
        self.init(base, except: except.map { RoutingPath($0) })
    }

    init(_ base: Binding<String?>, only: Array<RoutingPath>) {
        self.init(
            get: {
                guard let current = base.wrappedValue else { return nil }
                for path in only {
                    if path.test(path: current) != nil { return current }
                }
                return nil
            },
            set: { base.wrappedValue = $0 }
        )
    }

    public init(_ base: Binding<String?>, only: Array<String>) {
        self.init(base, only: only.map { RoutingPath($0) })
    }

    public func except(_ paths: Array<String>) -> Binding<Optional<String>> {
        .init(self, except: paths)
    }

    public func except(_ path: String) -> Binding<Optional<String>> {
        .init(self, except: [path])
    }

    public func only(_ paths: Array<String>) -> Binding<Optional<String>> {
        .init(self, only: paths)
    }

    public func only(_ path: String) -> Binding<Optional<String>> {
        .init(self, only: [path])
    }
}
