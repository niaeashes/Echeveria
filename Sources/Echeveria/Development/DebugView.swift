//
//  DebugView.swift
//

import SwiftUI

#if DEBUG

struct DebugView: View {

    @State var isOpen = false
    @EnvironmentObject var manager: RoutingManager

    var body: some View {
        Button(action: { withAnimation { isOpen.toggle() } }) {
            Image(systemName: "ladybug")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .padding(8)
                .compositingGroup()
                .contentShape(Circle())
        }
        .background(Color(UIColor.systemBackground))
        .clipShape(Circle())
        .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 0)
        .sheet(isPresented: $isOpen) {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Echeveria Debugger")
                        .font(.title)
                    Divider()
                    Text("Routing Manager")
                        .font(.headline)
                    ScrollView(.horizontal) {
                        Text(manager.debugDescription)
                            .padding()
                    }
                    .background(Color.gray.opacity(0.25))
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        }
    }
}

#endif
