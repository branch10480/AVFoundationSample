//
//  AVManagementService.swift
//  AVFoundationSample
//
//  Created by 今枝 稔晴 on 2020/06/05.
//  Copyright © 2020 今枝 稔晴. All rights reserved.
//

import Foundation
import AVFoundation
import RxSwift

protocol AVManagementServiceProtocol {
    func getAudio(from videoAsset: AVAsset) -> Single<AVAsset>
}

class AVManagementService: AVManagementServiceProtocol {
    
    func getAudio(from videoAsset: AVAsset) -> Single<AVAsset> {
        
        return Single<AVAsset>.create { observer in
            let audioTrack = videoAsset.tracks(withMediaType: .audio).first!
            let composition = AVMutableComposition()
            let audioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
            do {
                try audioCompositionTrack.insertTimeRange(
                   CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration),
                   of: audioTrack,
                   at: CMTime.zero)
                let audioAsset: AVAsset = composition
                observer(.success(audioAsset))
            } catch(let error) {
                observer(.error(error))
            }
            return Disposables.create {}
        }
    }
}
