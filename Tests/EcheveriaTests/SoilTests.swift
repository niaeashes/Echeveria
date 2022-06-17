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

    func testSafeAreaInsets() {
        let viewModel = Soil.ViewModel()
        let expect = expectation(description: "objectWillChange")
        let sub = viewModel.objectWillChange.sink { expect.fulfill() }
        defer { sub.cancel() }

        viewModel.safeAreaInsets.bottom = 44
        wait(for: [expect], timeout: 1)
    }
}
