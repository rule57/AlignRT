//
//  ContentView.swift
//  AlignRT
//
//  Created by William Rule on 6/26/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            VStack {
                Text("this is another V stack")
                HStack {
                    Text("This is an hstack within the 2nd v stack")
                    Text("And this is another element in that hstack")
                }
            }
            Text("Hello, Hi!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
