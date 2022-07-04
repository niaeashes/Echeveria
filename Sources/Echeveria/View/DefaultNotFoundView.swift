//
//  DefaultNotFoundView.swift
//

import SwiftUI

struct DefaultNotFoundView: View {

    let info: RoutingInfo

    var body: some View {
        VStack(spacing: 16) {
            Text("Route Not Found")
                .font(.title)
            #if DEBUG
            Text(info.path)
                .frame(maxWidth: .infinity, alignment: .leading)
            ForEach(info.errors.indices, id: \.self) { index in
                let error = info.errors[index]
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(describing: type(of: error).self))
                        .font(.headline)
                        .padding(.bottom, 8)
                    Text("\(error.localizedDescription)")
                        .font(.caption)
                    if let mismatch = error as? RoutingMismatchError {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Testing route definition:")
                                .bold()
                            Text(mismatch.path)
                        }
                        .font(.footnote)
                    }
                    if let invalid = error as? InvalidPathFieldError {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Failed route definition:")
                                .bold()
                            Text(invalid.path)
                        }
                        .font(.footnote)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            #endif
        }
        .padding(8)
    }
}

struct DefaultNotFoundView_Previews: PreviewProvider {

    static var previews: some View {
        DefaultNotFoundView(info: .init(path: "!not-found", params: [:], query: [:], errors: []))
        DefaultNotFoundView(info: .init(path: "!not-found", params: [:], query: [:], errors: [
            RoutingMismatchError(path: "/testing/path")
        ]))
    }
}
