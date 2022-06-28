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
    @Environment(\.soilController) var sceneOwner

    var body: some View {
        VStack {
            Text("ToDo Item")
                .onTapGesture { navigator.move(to: "/todos/1") }
            Text("ToDo Item")
                .onTapGesture { navigator.move(to: "/todos/2") }
            Text("ToDo Item")
                .onTapGesture { navigator.move(to: "/todos/3") }
            NavigationLink("Link", destination: RouteView(path: "/todos/4"))
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .border(Color.red)
        .padding()
        .background(Color.gray.opacity(0.25).ignoresSafeArea())
    }
}

struct TodoView: View {

    let id: Int

    init(id: Int) {
        self.id = id
    }

    @Namespace var scrollSpace

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScrollView {
                    Rectangle()
                        .frame(height: 180 + geometry.safeAreaInsets.top)
                    Text("Todo Item View \(id)")
                }
                .edgesIgnoringSafeArea(.top)
            }
        }
        .coordinateSpace(name: scrollSpace)
    }
}

struct TodoParameterResolver: RoutingParamParser {

    struct Param {
        let id: Int
    }

    func parse(info: RoutingInfo) throws -> Param {
        .init(id: .init(info["id"] ?? "0") ?? 0)
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