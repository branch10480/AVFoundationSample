//
//  AVPlayerViewController.swift
//  AVFoundationSample
//
//  Created by 今枝 稔晴 on 2020/06/05.
//  Copyright © 2020 今枝 稔晴. All rights reserved.
//

import UIKit
import AVFoundation

class AVPlayerViewController: UIViewController {

    @IBOutlet weak var slider: UISlider!
    private var asset: AVAsset!
    private var player: AVPlayer!
    
    public func inject(_ asset: AVAsset) {
        self.asset = asset
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create AVPlayer
        let item: AVPlayerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: item)
        
        // Add AVPlayerlayer
        let layer = AVPlayerLayer()
        layer.videoGravity = .resizeAspect
        layer.player = player
        layer.frame = view.bounds
        view.layer.addSublayer(layer)
        
        // Setup Movie SeekBar
        slider.minimumValue = 0
        slider.maximumValue = Float(CMTimeGetSeconds(asset.duration))
        
        // Processing to synchrinize the seek bar with the movie.
        
        // Set SeekBar Interval
        let interval = Double(0.5 * slider.maximumValue) / Double(slider.bounds.maxX)
        
        // ConvertCMTime
        let time = CMTime(seconds: interval, preferredTimescale: Int32(NSEC_PER_SEC))
        
        // Observer
        player.addPeriodicTimeObserver(forInterval: time, queue: nil) { [weak self] time in
            // Change SeekBar Position
            guard let self = self,
                  let currentTime = self.player.currentItem else
            {
                return
            }
            let duration = CMTimeGetSeconds(currentTime.duration)
            let time = CMTimeGetSeconds(self.player.currentTime())
            let value = Float(self.slider.maximumValue - self.slider.minimumValue) * Float(time) / Float(duration) + Float(self.slider.minimumValue)
            self.slider.value = value
        }
    }
    
    @IBAction func didTapStartButton(_ sender: Any) {
        player.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: Int32(NSEC_PER_SEC)))
        player.play()
    }

    @IBAction func didTapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didChangedSliderValue(_ sender: Any) {
    }
    
}
