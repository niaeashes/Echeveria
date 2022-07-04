import XCTest
@testable import Echeveria

class RoutingInfoTests: XCTestCase {

    func testJoin() {
        let base = RoutingInfo(path: "/home", params: [:], query: [:], errors: [])
        XCTAssertEqual(base.join("/next"), "/home/next")
        XCTAssertEqual(base.join("./next"), "/home/next")
        XCTAssertEqual(base.join("../next"), "/next")
        XCTAssertEqual(base.join("../../next"), "/next")
    }
}
