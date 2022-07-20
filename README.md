# Echeveria

Echeveria is path based view rendering system use with SwiftUI

# Installation

In Xcode add the dependency to your project via File > Add Packages > Search or Enter Package URL and use the following url:

```
https://github.com/niaeashes/Echeveria.git
```

```swift
import Echeveria
```

# Usage

## Define Router

**Router is passed through `@Environment`.** Define your router with `.routing` method and `Route`.
`.routing` method set a new router with `.environment` view modifier.
`RouteView` resolve the path with referencing `Router` and finds View to render.

```swift
@main
struct SampleApp: App {

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView {
                    RouteView(path: "/todos")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem { Label("Todo", systemImage: "list.triangle") }
                RouteView(path: "/setting")
                    .tabItem { Label("Setting", systemImage: "gear") }
            }
            .routing {

                Route("/todos") { TodoListView() }
                Route("setting") { SettingView() }

                Route("/todos/:id", parseBy: TodoParameterResolver()) { TodoView(id: $0.id) }

                Route("/help") { HelpView() }
            }
        }
    }
}
```

## Parameter and Parameter Resolver

**Path definition contains parameter.** For example, `/todos/:id` path contains `:id` parameter.
The first argument of block passed to `Route` is of type `RoutingInfo`.
`RoutingInfo` keeps path-parameter information in `.params` member variable.

```swift
Route("/todos/:id") { routingInfo in
    TodoView(id: routingInfo.params["id"]!) // id: String
}
```

- [RoutingInfo](./Sources/Echeveria/Routing/RoutingInfo.swift)

If you inject custom parameter resolver via `parseBy:` argument, the first argument of block is type of `Param` in that parameter resolver, instead `RoutingInfo`.

```swift
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
```

- **InvalidPathFieldError / RoutingMismatchError:** Standard error for parameter resolver. It's meaning "this route is not matching."

# Demo

- [iOS Example](./Examples/Echeveria%20iOS%20Example)

# License

[MIT License](LICENSE).
