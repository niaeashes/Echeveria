//
//  Application.swift
//  Echeveria iOS Example (iOS)
//

import SwiftUI
import Echeveria

struct TodoListView: View {

    @State var isOpenHelp = false
    @State var nextPathInput: String = ""
    @State var nextPath: String? = nil

    var body: some View {
        VStack {
            NavigationLink(path: $nextPath)
            NavigationLink("Todo Item", destination: RouteView(path: "/todos/1"))
            NavigationLink("Todo Item", destination: RouteView(path: "/todos/2"))
            NavigationLink("Todo Item", destination: RouteView(path: "/todos/3"))
            NavigationLink("Todo Item", destination: RouteView(path: "/todos/4"))
            Divider()
            TextField("Goto", text: $nextPathInput)
            Button(action: { withAnimation { nextPath = nextPathInput }}) {
                Text("GO")
            }
            Divider()
            Button(action: { withAnimation { isOpenHelp = true } }) {
                Text("Open Help")
            }
        }
        .sheet(isPresented: $isOpenHelp) { RouteView(path: "/help") }
    }
}

struct TodoView: View {

    let id: Int

    @Environment(\.route) var route

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
                    Text("Path: \(route.path)")
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
        guard let idValue = info.params["id"], let id = Int(idValue) else {
            throw InvalidPathFieldError(path: info.path)
        }
        return .init(id: id)
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
