import XCTest
import SwiftUI
@testable import Echeveria

class BindingOptionalStringTests: XCTestCase {

    func testExcept() {
        var value: String? = nil
        let base = Binding<String?>(get: { value }, set: { value = $0 })
        let excepted = Binding<String?>(base, except: ["/except"])

        XCTAssertNil(excepted.wrappedValue)

        value = "/home"
        XCTAssertEqual(excepted.wrappedValue, "/home")

        value = "/except"
        XCTAssertNil(excepted.wrappedValue)
    }

    func testOnly() {
        var value: String? = nil
        let base = Binding<String?>(get: { value }, set: { value = $0 })
        let excepted = Binding<String?>(base, only: ["/only"])

        XCTAssertNil(excepted.wrappedValue)

        value = "/home"
        XCTAssertNil(excepted.wrappedValue)

        value = "/only"
        XCTAssertEqual(excepted.wrappedValue, "/only")
    }
}
