//
//  WelcomeView.swift
//

import SwiftUI

#if DEBUG

private let ROOT_VIEW_SAMPLE = """
Soil {
  Route("/") { YourFirstView() }
}
"""

private let LAUNCHER_VIEW_SAMPLE = """
Soil {
  Route("/first") { _ in FirstView() }
    .leaf(text: "First", systemImage: "die.face.1", placement: .launcher)
  Route("/second") { _ in SecondView() }
    .leaf(text: "Second", systemImage: "die.face.2", placement: .launcher)
}
"""

struct WelcomeView: View {

    let spacing: CGFloat = 16

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: spacing) {
                Image(systemName: "leaf")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.green)
                    .frame(width: 64, height: 64)
                    .padding(spacing)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Welcome to Echeveria Framework!")
                    .font(.title)
                    .bold()
                VStack(alignment: .leading, spacing: spacing) {
                    Divider()
                    Text("This View is the root view that is displayed by default with debug build.")
                    Text("To display your own View, code Soil as follows:")
                    ScrollView(.horizontal) {
                        Text(ROOT_VIEW_SAMPLE)
                            .font(.system(.body, design: .monospaced))
                            .padding(spacing / 3)
                    }
                    .background(Color.gray.opacity(0.25))
                    .cornerRadius(spacing / 2)
                }
                .font(.body)
                VStack(alignment: .leading, spacing: spacing) {
                    Divider()
                    Text("There are other ways. Add a Leaf to registered routes and set launcher to placement.")
                    Text("Soil will display the navigation at the bottom of the screen automatically.")
                    ScrollView(.horizontal) {
                        Text(LAUNCHER_VIEW_SAMPLE)
                            .font(.system(.body, design: .monospaced))
                            .padding(spacing / 3)
                    }
                    .background(Color.gray.opacity(0.25))
                    .cornerRadius(spacing / 2)
                }
                .font(.body)
            }
            .padding(8)
        }
    }
}

#else

typealias WelcomeView = EmptyView

#endif

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
