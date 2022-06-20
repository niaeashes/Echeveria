//
//  SoilTests.swift
//  
//
//  Created by shota-nagasaki on 2022/06/18.
//

import XCTest
@testable import Echeveria

class SoilTests: XCTestCase {

    // MARK: - View Model Tests

    struct RouterHolder {
        let router: Router
        init(@RouterBuilder router: () -> Router) {
            self.router = router()
        }
    }

    func testSafeAreaInsets() {
        let router = RouterHolder() {
        }.router
        let viewModel = Soil.ViewModel(router: router)
        let expect = expectation(description: "objectWillChange")
        let sub = viewModel.objectWillChange.sink { expect.fulfill() }
        defer { sub.cancel() }

        viewModel.safeAreaInsets.bottom = 44
        wait(for: [expect], timeout: 1)
    }
}
