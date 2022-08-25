//
//  ContentView.swift
//  testing project
//
//  Created by Theappmedia on 5/12/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack{
            Text("HELLO WORLD FROM ISLAMABAD")
        }
        .padding(.horizontal)
        .foregroundColor(.white)
        .background(Color("red").ignoresSafeArea())
    }
}
struct ContentView_Previews: PreviewProvider{
    static var previews: some View {
        ContentView()
    }
}
