//
//  RoutingPathTests.swift
//

import XCTest
@testable import Echeveria

class RoutingPathTests: XCTestCase {

    func testStatic() throws {
        do {
            let result = RoutingPath("/home").test(path: "/home")
            XCTAssertNotNil(result)
        }
        do {
            let result = RoutingPath("/home").test(path: "/another")
            XCTAssertNil(result)
        }
    }

    func testParameter() throws {
        do {
            let result = RoutingPath("/users/:id").test(path: "/users/1")
            XCTAssertEqual(result!.info["id"], "1")
        }
        do {
            let result = RoutingPath("users/:id").test(path: "/users/1")
            XCTAssertEqual(result!.info["id"], "1")
        }
        do {
            let result = RoutingPath("/users/:id").test(path: "users/1")
            XCTAssertEqual(result!.info["id"], "1")
        }
    }
}
