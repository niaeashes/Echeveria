//
//  Application.swift
//  Echeveria iOS Example (iOS)
//
//  Created by shota-nagasaki on 2022/06/17.
//

import SwiftUI
import Echeveria

struct TodoListView: View {

    @State var isOpenHelp = false

    var body: some View {
        VStack {
            NavigationLink("Todo Item", destination: RouteView(path: "/todos/1"))
            NavigationLink("Todo Item", destination: RouteView(path: "/todos/2"))
            NavigationLink("Todo Item", destination: RouteView(path: "/todos/3"))
            NavigationLink("Todo Item", destination: RouteView(path: "/todos/4"))
            Button(action: { withAnimation { isOpenHelp = true } }) {
                Text("Open Help")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .border(Color.red)
        .padding()
        .background(Color.gray.opacity(0.25).ignoresSafeArea())
        .sheet(isPresented: $isOpenHelp) { RouteView(path: "/help") }
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
