//
//  DetailView.swift
//  testing project
//
//  Created by Theappmedia on 8/25/22.
//

import AVFoundation
import UIKit

class videoMerger{
    static let instatance = videoMerger()
    func createThumbnailOfVideoFromRemoteUrl(url: URL) -> UIImage {
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        //Can set this to improve performance if target size is known before hand
        //assetImgGenerate.maximumSize = CGSize(width,height)
        let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            print(error.localizedDescription)
            return UIImage(systemName: "play.circle")!
        }
    }
    
    func merg(_ file1: URL?, audio2 file2: URL?,onComplete:@escaping (URL?)->Void) {
        guard let file1 = file1, let file2 = file2 else {
            onComplete(nil)
            return
        }
        let video1Asset = AVAsset(url: file1)
        let video2Asset = AVAsset(url: file2)
        
        let mixComposition = AVMutableComposition()
        _ = mixComposition.naturalSize
        guard let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            print("error-- track1")
            onComplete(nil)
            return
        }
        
        guard let audioAsset: AVAssetTrack = video1Asset.tracks(withMediaType: .audio).first else {
            print("error-- track")
            onComplete(nil)
            return
        }
        
        let firstTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let v1track:AVAssetTrack = (video1Asset.tracks(withMediaType: .video)[0])
        do {
            try audioTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: video1Asset.duration), of: audioAsset, at: CMTime.zero)
            try firstTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: video1Asset.duration), of: v1track, at: .zero)
        }
        catch let r
        {
            print("error-- try \(r)")
        }
        
        let secondTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let v2track:AVAssetTrack = (video2Asset.tracks(withMediaType: .video)[0])
        do {
            try secondTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: video1Asset.duration), of: v2track, at: .zero)
        } catch {
            onComplete(nil)
        }
        
        let MainInstruction = AVMutableVideoCompositionInstruction()
        MainInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: video1Asset.duration)
        let renderSize = CGSize(width: 800, height: 700)//500)
        let scaleRatioX = (renderSize.width / 1.12) / v1track.naturalSize.width
        let scaleRatioY = (renderSize.height/1.75) / v1track.naturalSize.height
        
        let scaleRatio2X = (renderSize.width / 2) / v2track.naturalSize.width
        let scaleRatio2Y = renderSize.height / v2track.naturalSize.height
        
        let FirstlayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: firstTrack!)
        
        let Scale = CGAffineTransform(scaleX: scaleRatioX, y: scaleRatioY)
        let Move = CGAffineTransform(translationX: 0, y: 0)
        FirstlayerInstruction.setTransform(v1track.preferredTransform.concatenating(Scale).concatenating(Move), at: .zero)
        
        
        let SecondlayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: secondTrack!)
        let SecondScale = CGAffineTransform(scaleX: scaleRatio2X, y: scaleRatio2Y)
        let SecondMove = CGAffineTransform(translationX: renderSize.width/2, y: 0)
        SecondlayerInstruction.setTransform(SecondScale.concatenating(SecondMove), at: .zero)
        
        MainInstruction.layerInstructions = [FirstlayerInstruction, SecondlayerInstruction]
        
        let MainCompositionInst = AVMutableVideoComposition()
        MainCompositionInst.instructions = [MainInstruction]
        MainCompositionInst.frameDuration = CMTimeMake(value: 1, timescale: 30)
        //MainCompositionInst.renderSize = CGSize(width:width,height: height)
        MainCompositionInst.renderSize = renderSize
        
        // Create the export session with the composition and set the preset to the highest quality.
        let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality)
        // Set the desired output URL for the file created by the export process.
        let uri = URL(fileURLWithPath: ((FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).last)?.path)!).appendingPathComponent("\(UUID().uuidString)-mergedVideo.mp4").path
        try? FileManager.default.removeItem(atPath: uri)
        exporter?.outputURL = URL(fileURLWithPath: uri)
        print(uri)
        exporter?.videoComposition = MainCompositionInst
        // Set the output file type to be a QuickTime movie.
        exporter?.outputFileType = .mp4
        exporter?.shouldOptimizeForNetworkUse = true
        
        // Asynchronously export the composition to a video file and save this file to the camera roll once export completes.
        exporter?.exportAsynchronously(completionHandler: {
            DispatchQueue.main.async(execute: {
                if exporter?.status == .completed {
                    onComplete(exporter?.outputURL)
                }else{
                    print("not composle")
                    onComplete(nil)
                }
            })
        })
        
    }
}
