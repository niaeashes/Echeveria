# Echeveria

> Alternative navigation to UIKit and path based routing.

# Sample Code

```swift
@main
struct EcheveriaTestApp: App {
    var body: some Scene {
        WindowGroup {
            RootView {
                Launcher(title: "Main", systemImage: "circle") {
                    Stack(path: "/main") { _ in MainContentView() }
                }
                Launcher(title: "Sub", systemImage: "circle") {
                    Stack(path: "/sub") { _ in SubContentView() }
                }
                Cover(path: "/cover") { _ in CoverView() }
                Page(path: "/article/:id"){ routing in ArticleView(id: routing.info["id"]) }
            }
        }
    }
}
```

# Elements

## RootView

It's root.

## Launcher

Launcher works like UITabBarItem. It's wrapper an another routing element.

RootView captures Launchers on routing table, and render it as tab bar items.

## Page

Simple routing element. It map single path to single SwiftUI view.

## Stack

Stack works like UINavigationController.

## Cover

Cover is custom routing element, its view is opened as a screen cover modal from anywhere.

# License

[MIT License](LICENSE).
