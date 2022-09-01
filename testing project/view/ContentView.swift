//
//  ContentView.swift
//  testing project
//
//  Created by Theappmedia on 5/12/22.
//

import SwiftUI
import AVKit
import AVFoundation

struct ContentView: View {
    @State private var currentAmount = 0.0
    @State private var finalAmount = 1.0
    @State private var location: CGPoint = CGPoint()
    @State var cc = false
    @State var video = URL(string: "")
    
    var body: some View {
        VStack{
            if cc{
                Button {
                    merge(video:"\(readVideo())", withForegroundImage: UIImage(named: "1")!){ url in
                    }
                } label: {
                    Text("Press Me")
                }

                ZStack{
                    Image("1")
                        .resizable()
                        .scaledToFill()
                    VideoPlayer(player: AVPlayer(url: video!))
                        .scaleEffect(finalAmount + currentAmount)
                        .position(location)
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                withAnimation {
                                                    DispatchQueue.global(qos: .userInteractive).async {
                                                  DispatchQueue.main.async {
                                                            self.location = value.location
                                                        }
                                                    }
                                                }
                                            }.simultaneously(with:
                                        MagnificationGesture()
                                            .onChanged { amount in
                                                currentAmount = amount
                                            }
                                            .onEnded { amount in
                                                finalAmount += currentAmount
                                                currentAmount = 0
                                            }
                                                             )
                                        
                                    )
                        .frame(width: 150, height: 200, alignment: .center)
                }
            }else{
                Text("Hello")
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            readVideo()
            cc.toggle()
        }
    }

    func readVideo()->URL{
        video = Bundle.main.url(forResource: "Don't Fight", withExtension: "mp4")
        return video!
    }
}

struct ContentView_Previews: PreviewProvider{
    static var previews: some View {
        ContentView()
    }
}
