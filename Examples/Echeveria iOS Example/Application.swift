//
//  Application.swift
//  Echeveria iOS Example (iOS)
//
//  Created by shota-nagasaki on 2022/06/17.
//

import SwiftUI
import Echeveria

struct TodoListView: View {
    var body: some View {
        Text("Todo List")
    }
}

struct TodoView: View {

    init(id: Int) {

    }

    var body: some View {
        Text("Todo Item View")
    }
}

struct TodoParameterResolver: RoutingParamParser {

    struct Param {
        let id: Int
    }

    func parse(info: RoutingInfo) throws -> Param {
        .init(id: .init(info["id"]!)!)
    }
}

struct SettingView: View {

    var body: some View {
        Text("Setting")
    }
}
