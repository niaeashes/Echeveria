//
//  Echeveria_iOS_ExampleApp.swift
//  Shared
//
//  Created by shota-nagasaki on 2022/06/17.
//

import SwiftUI
import Echeveria

@main
struct Echeveria_iOS_ExampleApp: App {

    init() {
        UITabBar.appearance().backgroundColor = UIColor.white
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                RouteView(path: "/notfound")
                    .tabItem {
                        Label("Todo", systemImage: "list.triangle")
                    }
                RouteView(path: "/setting")
                    .tabItem {
                        Label("Setting", systemImage: "gear")
                    }
            }
            .routing {
                // Route("/") { Text("Soil") }
                Route("/todos") { _ in TodoListView() }
                    .leaf(text: "Todos", systemImage: "list.triangle", placement: .launcher)
                Route("setting") { _ in SettingView() }
                    .leaf(text: "Setting", systemImage: "gear", placement: .launcher)

                Route("/todos/:id", parseBy: TodoParameterResolver()) { TodoView(id: $0.id) }
                Route("/help", transition: CoverTransition()) { _ in HelpView() }

                NotFoundRoute {
                    Text("Not Found")
                }
            }
        }
    }
}
