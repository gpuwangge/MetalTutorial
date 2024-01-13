//
//  ContentView.swift
//  Pipeline
//
//  Created by XiaojunW Wang on 1/8/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        //VStack {
        //    Image(systemName: "globe")
        //        .imageScale(.large)
        //        .foregroundStyle(.tint)
        //    Text("Hello, world!")
        //}
        //.padding()
        VStack{
            MetalView()
                .border(Color.blue, width: 2)
            Text("Hello Wangge")
        }
    }
}

#Preview {
    ContentView()
}
