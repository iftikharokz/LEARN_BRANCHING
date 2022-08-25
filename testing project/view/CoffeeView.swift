//
//  Home.swift
//  testing project
//
//  Created by Theappmedia on 5/12/22.
//

import SwiftUI

struct CoffeView: View {
    @EnvironmentObject var viewModel : ViewModel
    var body: some View {
        VStack{
            Button {
                viewModel.checkInternalLinks(host: "A13")
            } label: {
                Text("GOTO 3")
            }
            ForEach(viewModel.coffess){ coffee in
                NavigationLink(destination: DetailView(coffe: coffee),tag: coffee.id, selection: $viewModel.currentdatilPage) {
                    HStack {
                        Image(coffee.productImage)
                            .resizable()
                            .frame(width: 100, height: 100)
                        Text(coffee.title)
                    }
                }
            }
        }
    }
}

struct CoffeView_Previews: PreviewProvider {
    static var previews: some View {
        CoffeView()
    }
}

struct DetailView: View{
    let coffe : Coffee
    var body: some View{
        VStack{
            Text(coffe.title)
                .font(.title)
            Image(coffe.productImage)
                .resizable()
                .scaledToFit()
                .padding()
            Text(coffe.description)
        }
    }
}
