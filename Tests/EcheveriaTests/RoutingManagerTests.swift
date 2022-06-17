//
//  RoutingManagerTests.swift
//

import XCTest
@testable import Echeveria

class RoutingManagerTests: XCTestCase {


    func testDefaultCurrentPath() {
        let manager = RoutingManager()
        XCTAssertEqual(manager.current, "/")
    }

    func testStoreCurrentPath() {
        let manager = RoutingManager()
        manager.push(path: "/todos")
        XCTAssertEqual(manager.current, "/todos")
    }

    func testTree() {
        let manager = RoutingManager()
        manager.registerRoot(path: "/home")
        manager.registerRoot(path: "/account")
    }

    func testStack() {
        let manager = RoutingManager()
        manager.push(path: "/first")
        XCTAssertEqual(manager.current, "/first")
        manager.push(path: "/second")
        XCTAssertEqual(manager.current, "/second")
        manager.pop()
        XCTAssertEqual(manager.current, "/first")
        manager.pop()
        XCTAssertEqual(manager.current, "/")
    }

    func testDebug() {
        do {
            let manager = RoutingManager()
            manager.push(path: "/first")
            manager.push(path: "/second")
            XCTAssertEqual(manager.debugDescription, "+ / > /first > /second")
        }
        do {
            let manager = RoutingManager()
            manager.registerRoot(path: "/home")
            manager.registerRoot(path: "/account")
            manager.push(path: "/home")
            manager.push(path: "/article/1")
            manager.push(path: "/account")
            manager.push(path: "/account/setting")
            XCTAssertEqual(manager.debugDescription.split(separator: "\n").count, 3)
        }
    }

    func testRootShift() {
        let manager = RoutingManager()
        manager.registerRoot(path: "/home")
        manager.registerRoot(path: "/account")
        manager.push(path: "/home")
        manager.push(path: "/article/1")
        manager.push(path: "/account")
        manager.push(path: "/account/setting")

        XCTAssertNotEqual(manager.current, "/article/1")
        manager.push(path: "/home")
        XCTAssertEqual(manager.current, "/article/1")
    }
}
