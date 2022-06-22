//
//  Application.swift
//  Echeveria iOS Example (iOS)
//
//  Created by shota-nagasaki on 2022/06/17.
//

import SwiftUI
import Echeveria

struct TodoListView: View {

    @Environment(\.navigator) var navigator
    @Environment(\.sceneOwner) var sceneOwner

    var body: some View {
        VStack {
            Text("Todo List")
            Button(action: { sceneOwner.hideLauncher() }) {
                Text("Hide Launcher")
            }
            Button(action: { sceneOwner.showLauncher() }) {
                Text("Show Launcher")
            }
            Button(action: { navigator.move(to: "/help") }) {
                Text("Open Help")
            }
        }
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

struct HelpView: View {
    var body: some View {
        Text("Help")
    }
}
