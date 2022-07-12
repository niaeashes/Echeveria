//
//  RouterTests.swift
//

import XCTest
import SwiftUI
@testable import Echeveria

class RouterTests: XCTestCase {

    func testExample() throws {
        let router = Router(routes: [
            RoutingPath("/home"): .init(resolver: { _ in AnyView(EmptyView()) }),
        ])
        XCTAssertNotNil(router.test(path: "/home"))
    }
}
