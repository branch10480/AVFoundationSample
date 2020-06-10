//
//  AVPlayerViewController.swift
//  AVFoundationSample
//
//  Created by 今枝 稔晴 on 2020/06/05.
//  Copyright © 2020 今枝 稔晴. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa
import SVProgressHUD

class AVPlayerViewController: UIViewController {

    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var convertToImageButton: UIButton!
    
    private var asset: AVAsset!
    private var player: AVPlayer!
    private static let initialTime = CMTimeMakeWithSeconds(0, preferredTimescale: Int32(NSEC_PER_SEC))
    private let disposeBag = DisposeBag()
    
    private lazy var viewModel = AVPlayerViewModel(
        bottomButtonTap: bottomButton.rx.tap.asObservable(),
        convertToImageButtonTap: convertToImageButton.rx.tap.asObservable(),
        sliderValueChange: slider.rx.value.asObservable(),
        player: player,
        interval: Double(0.5 * slider.maximumValue) / Double(slider.bounds.maxX),    // Set SeekBar Interval
        sliderMinimumValue: slider.minimumValue,
        sliderMaximumValue: slider.maximumValue
    )
    
    public func inject(_ asset: AVAsset) {
        self.asset = asset
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAVPlayer()
        bind()
    }
    
    private func setupAVPlayer() {

        // Create AVPlayer
        let item: AVPlayerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: item)
        
        // Add AVPlayerLayer
        let layer = playerView.playerLayer
        layer.videoGravity = .resizeAspect
        layer.player = player
        
        // Setup Movie SeekBar
        slider.minimumValue = 0
        slider.maximumValue = Float(CMTimeGetSeconds(asset.duration))
    }
    
    private func bind() {
        let buttonTitle: Observable<String> = viewModel.playerStateDidChange.map { state in
            switch state {
            case .playing:
                return "Stop"
            case .pause, .end:
                return "Start"
            }
        }

        buttonTitle
            .bind(to: bottomButton.rx.title())
            .disposed(by: disposeBag)
        
        viewModel.sliderValue
            .bind(to: slider.rx.value)
            .disposed(by: disposeBag)
        
        viewModel.loading
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { result in
                if result {
                    SVProgressHUD.show()
                } else {
                    SVProgressHUD.dismiss()
                }
            }).disposed(by: disposeBag)
        
        viewModel.photoSavingResult.subscribe(onNext: { result in
            var message = ""
            switch result {
            case .success(let tmpMessage):
                message = tmpMessage
                break
            case .error(let error):
                message = error.localizedDescription
            }
            
            let ac = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            ac.addAction(.init(title: "OK", style: .default, handler: nil))
            self.present(ac, animated: true, completion: nil)
            
            }).disposed(by: disposeBag)
    }

    @IBAction func didTapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
