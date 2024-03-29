//
//  Echeveria_iOS_ExampleApp.swift
//  Shared
//

import SwiftUI
import Echeveria

@main
struct Echeveria_iOS_ExampleApp: App {

    init() {
        do {
            let appearance = UIBarAppearance()
            appearance.backgroundColor = .clear
            appearance.backgroundEffect = UIBlurEffect(style: .regular)
            appearance.shadowColor = nil
            UINavigationBar.appearance().standardAppearance = .init(barAppearance: appearance)
        }
        do {
            let appearance = UIBarAppearance()
            appearance.backgroundColor = .clear
            appearance.backgroundEffect = .none
            UINavigationBar.appearance().scrollEdgeAppearance = .init(barAppearance: appearance)
        }
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView {
                    RouteView(path: "/todos")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    Label("Todo", systemImage: "list.triangle")
                }
                RouteView(path: "/setting")
                    .tabItem {
                        Label("Setting", systemImage: "gear")
                    }
            }
            .routing(modifier: { _ in RedFrameModifier() }) {

                Route("/todos") { TodoListView() }
                Route("setting") { SettingView() }

                Route("/todos/:id", parseBy: TodoParameterResolver()) { TodoView(id: $0.id) }

                Route("/help") { HelpView() }

                NotFoundRoute { info in
                    VStack {
                        Text("Not Found")
                        Text(info.path)
                            .font(.caption)
                    }
                }
            }
        }
    }
}

struct RedFrameModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .border(Color.red)
            .padding()
            .background(Color.gray.opacity(0.1).ignoresSafeArea())
    }
}
