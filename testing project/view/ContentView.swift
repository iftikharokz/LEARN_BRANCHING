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
    private func addAudioTrack(composition: AVMutableComposition, videoUrl: URL) {


            let videoUrlAsset = AVURLAsset(url: videoUrl, options: nil)

            let audioTracks = videoUrlAsset.tracks(withMediaType: AVMediaType.audio)

            let compositionAudioTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!

            for audioTrack in audioTracks {
                try! compositionAudioTrack.insertTimeRange(audioTrack.timeRange, of: audioTrack, at: CMTime.zero)
            }
        }
    func merge(
            video videoPath: String,
            withForegroundImage foregroundImage: UIImage,
            completion: @escaping (URL?) -> Void) -> () {

            let videoUrl = URL(fileURLWithPath: videoPath)
            let videoUrlAsset = AVURLAsset(url: videoUrl, options: nil)

            // Setup `mutableComposition` from the existing video
            let mutableComposition = AVMutableComposition()
                let videoAssetTrack = videoUrlAsset.tracks(withMediaType: AVMediaType.video).first
                let videoCompositionTrack = mutableComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
                videoCompositionTrack?.preferredTransform = videoAssetTrack!.preferredTransform
                try! videoCompositionTrack?.insertTimeRange(CMTimeRange(start:CMTime.zero, duration:videoAssetTrack!.timeRange.duration), of: videoAssetTrack!, at: CMTime.zero)

            addAudioTrack(composition: mutableComposition, videoUrl: videoUrl)

            let videoSize: CGSize = (videoCompositionTrack?.naturalSize)!
            let frame = CGRect(x: 0.0, y: 0.0, width: videoSize.width, height: videoSize.height)
            let imageLayer = CALayer()
            imageLayer.contents = foregroundImage.cgImage
            imageLayer.frame = CGRect(x: 0.0, y: 0.0, width:50, height:50)


            let videoLayer = CALayer()
            videoLayer.frame = frame
            let animationLayer = CALayer()
            animationLayer.frame = frame
            animationLayer.addSublayer(videoLayer)
            animationLayer.addSublayer(imageLayer)

            let videoComposition = AVMutableVideoComposition(propertiesOf: (videoCompositionTrack?.asset!)!)
            videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: animationLayer)

            let documentDirectory = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
            let documentDirectoryUrl = URL(fileURLWithPath: documentDirectory)
            let destinationFilePath = documentDirectoryUrl.appendingPathComponent("result.mp4")

            do {

                if FileManager.default.fileExists(atPath: destinationFilePath.path) {

                    try FileManager.default.removeItem(at: destinationFilePath)

                    print("removed")
                }



            } catch {

                print(error)
            }


            let exportSession = AVAssetExportSession( asset: mutableComposition, presetName: AVAssetExportPresetHighestQuality)!

           exportSession.videoComposition = videoComposition
            exportSession.outputURL = destinationFilePath
            exportSession.outputFileType = AVFileType.mp4
            exportSession.exportAsynchronously { [weak exportSession] in
                if let strongExportSession = exportSession {
                    completion(strongExportSession.outputURL!)

                    //self.play(strongExportSession.outputURL!)
                }
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
