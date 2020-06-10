//
//  PlayerView.swift
//  AVFoundationSample
//
//  Created by 今枝 稔晴 on 2020/06/10.
//  Copyright © 2020 今枝 稔晴. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerView: UIView {

    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    // Override UIView property
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

}
