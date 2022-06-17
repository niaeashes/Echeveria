//
//  RouterTests.swift
//

import XCTest
import SwiftUI
@testable import Echeveria

class RouterTests: XCTestCase {

    struct RouterHolder {
        let router: Router
        init(@RouterBuilder router: () -> Router) {
            self.router = router()
        }
    }

    struct Tester<Expected: View & Equatable>: RouterDelegate {
        let expect: XCTestExpectation
        let expectedView: Expected
        func present<V>(transition: SceneTransition?, content: V) where V : View {
            if let test = content as? Expected {
                XCTAssertEqual(test, expectedView)
            } else {
                XCTFail()
            }
            expect.fulfill()
        }
    }

    func testEmptyRouter() throws {

        let holder = RouterHolder() {}
        XCTAssertEqual(holder.router.leaves.count, 0)
    }

    func testSingleRoute() {
        let expectedRootView = Text("Root")
        let expect = expectation(description: "call RouterDelegate.refresh")

        let holder = RouterHolder() {
            Route("/") { _ in expectedRootView }
        }

        // XCTAssertEqual(holder.router.leaves.count, 1)
        holder.router.resolve(path: "/", delegate: Tester(expect: expect, expectedView: expectedRootView))
        wait(for: [expect], timeout: 1)
    }

    func testSolidRoute() {
        let expectedPersonView = Image(systemName: "person")
        let expect = expectation(description: "call RouterDelegate.refresh")

        let holder = RouterHolder() {
            Route("/root") { _ in Text("Root") }
            Route("/person") { _ in expectedPersonView }
        }

        XCTAssertEqual(holder.router.leaves.count, 0)
        holder.router.resolve(path: "/person", delegate: Tester(expect: expect, expectedView: expectedPersonView))
        wait(for: [expect], timeout: 1)
    }

    func testParameterizedRoute() {
        let expectedPersonView = Text("Article")
        let expect = expectation(description: "call RouterDelegate.refresh")

        let holder = RouterHolder() {
            Route("/article/:id") { info -> Text in
                XCTAssertEqual(info["id"], "1")
                return Text("Article")
            }
        }

        XCTAssertEqual(holder.router.leaves.count, 0)
        holder.router.resolve(path: "/article/1", delegate: Tester(expect: expect, expectedView: expectedPersonView))
        wait(for: [expect], timeout: 1)
    }
}
