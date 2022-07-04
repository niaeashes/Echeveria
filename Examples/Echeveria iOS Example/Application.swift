//
//  Application.swift
//  Echeveria iOS Example (iOS)
//

import SwiftUI
import Echeveria

struct TodoListView: View {

    @State var nextPathInput: String = ""
    @State var nextPath: String? = nil

    var body: some View {
        VStack {
            NavigationLink(path: $nextPath.except(HelpView.PATH))
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
            Button(action: { withAnimation { nextPath = HelpView.PATH } }) {
                Text("Open Help")
            }
        }
        .sheet(path: $nextPath.only(HelpView.PATH))
    }
}

struct TodoView: View {

    let id: Int

    @Environment(\.route) var route
    @State var nextPath: String? = nil

    init(id: Int) {
        self.id = id
    }

    @Namespace var scrollSpace

    var body: some View {
        GeometryReader { geometry in
            NavigationLink(path: $nextPath)
            ZStack {
                ScrollView {
                    Rectangle()
                        .frame(height: 180 + geometry.safeAreaInsets.top)
                    Text("Todo Item View \(id)")
                    Text("Path: \(route.path)")
                    Button(action: { nextPath = route.join("./comments") }) {
                        Text("Comments")
                    }
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

    static let PATH = "/help"

    var body: some View {
        Text("Help")
    }
}
