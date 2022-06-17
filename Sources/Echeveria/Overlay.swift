//
//  Overlay.swift
//

import SwiftUI

struct Overlay: View {

    let launchers: Array<Leaf>
    @Environment(\.navigator) var navigator
    @State var selectedLauncherIndex = 0

    init(_ leaves: Array<Leaf>) {
        self.launchers = leaves
            .filter { $0.placement == .launcher }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                    .allowsHitTesting(false)
                #if DEBUG
                DebugView()
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                #endif
                HStack(spacing: 0) {
                    ForEach(launchers.indices, id: \.self) { i in
                        let launcher = launchers[i]
                        VStack(spacing: 4) {
                            launcher.icon
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                            launcher.text
                        }
                        .padding(4)
                        .padding(.vertical, 4)
                        .font(.system(size: 9))
                        .frame(maxWidth: .infinity)
                        .drawingGroup()
                        .contentShape(Rectangle())
                        .opacity(selectedLauncherIndex == i ? 1 : 0.25)
                        .onTapGesture {
                            navigator.present(path: launcher.path)
                            withAnimation(.default.speed(5)) { selectedLauncherIndex = i }
                        }
                    }
                }
                .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.bottom))
            }
        }
    }
}
