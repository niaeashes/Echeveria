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
            XCTAssertEqual(result!.params["id"], "1")
        }
        do {
            let result = RoutingPath("users/:id").test(path: "/users/1")
            XCTAssertEqual(result!.params["id"], "1")
        }
        do {
            let result = RoutingPath("/users/:id").test(path: "users/1")
            XCTAssertEqual(result!.params["id"], "1")
        }
    }

    func testQuery() throws {
        do {
            let result = RoutingPath("/users/:id").test(path: "/users/1?query=value")
            XCTAssertEqual(result!.params["id"], "1")
            XCTAssertEqual(result!.query["query"], "value")
        }
    }

    func testStringHitTest() {

        struct IdParser: RoutingParamParser {
            typealias Param = Int

            func parse(info: RoutingInfo) throws -> Param {
                guard let value = info.params["id"], let id = Int(value) else {
                    throw RoutingMismatchError(path: info.path)
                }
                return id
            }
        }

        let id = "/users/:id".test("/users/10", parsedBy: IdParser())
        XCTAssertEqual(id, 10)
    }
}
