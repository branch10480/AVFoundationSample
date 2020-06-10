//
//  AVPlayerViewModel.swift
//  AVFoundationSample
//
//  Created by 今枝 稔晴 on 2020/06/08.
//  Copyright © 2020 今枝 稔晴. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import AVFoundation

class AVPlayerViewModel: NSObject {
    
    // Public Observables
    let playerStateDidChange: Observable<PlayerState>
    let sliderValue = BehaviorRelay<Float>(value: 0)
    let loading = BehaviorRelay<Bool>(value: false)
    var photoSavingResult: Observable<Result<String>> {
        return _photoSavingResult.asObservable()
    }

    private let disposeBag = DisposeBag()
    private let playerState = BehaviorRelay<PlayerState>(value: .pause)
    private let _photoSavingResult = BehaviorRelay<Result<String>>(value: .success(""))
    private let player: AVPlayer
    enum PlayerState {
        case playing
        case pause
        case end
    }

    // Observables
    private let didPlayToEnd: Driver<Notification>
    private var currentTime: CMTime
    
    init(
        bottomButtonTap: Observable<Void>,
        convertToImageButtonTap: Observable<Void>,
        sliderValueChange: Observable<Float>,
        player: AVPlayer,
        interval: Double,
        sliderMinimumValue: Float,
        sliderMaximumValue: Float
    ) {
        self.player = player
        self.didPlayToEnd = player.currentItem!.rx.didPlayToEnd.asDriver(onErrorDriveWith: .empty())
        
        let playerStateDidChange: Observable<PlayerState> = Observable.combineLatest(bottomButtonTap, playerState.asObservable()).map { _, state2  in
            return state2
        }.share(replay: 1)
        self.playerStateDidChange = playerStateDidChange

        // Processing to synchrinize the seek bar with the movie.

        // ConvertCMTime
        let time = CMTime(seconds: interval, preferredTimescale: Int32(NSEC_PER_SEC))
        self.currentTime = time
        
        // Call Super Method
        super.init()
        
        // Observer
        player.addPeriodicTimeObserver(forInterval: time, queue: nil) { [weak self, weak player] time in
            // Change SeekBar Position
            guard let self = self,
                  let player = player,
                  let currentTime = player.currentItem else
            {
                return
            }
            self.currentTime = time
            
            let duration = CMTimeGetSeconds(currentTime.duration)
            let time = CMTimeGetSeconds(player.currentTime())
            let value = (sliderMaximumValue - sliderMinimumValue) * Float(time) / Float(duration) + Float(sliderMinimumValue)
            self.sliderValue.accept(value)
            
            self.playerState.accept(player.rate != 0 && player.error == nil ? .playing : .pause)
        }
        
        // Button Tap
        bottomButtonTap.subscribe(onNext: { [weak self] in
            self?.bottomButtonHandler()
            }).disposed(by: disposeBag)
        
        convertToImageButtonTap.subscribe(onNext: { [weak self] in
            
            guard let self = self,
                  let asset = player.currentItem?.asset else { return }
            
            self.player.pause()
            
            // Convert View to Image
            self.loading.accept(true)
            defer {
                self.loading.accept(false)
            }
            
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            do {
                let cgImage = try imageGenerator.copyCGImage(at: player.currentTime(), actualTime: nil)
                let uiImage = UIImage(cgImage: cgImage)
                UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(self.handlePhotoSavingResult(_:didFinishSavingWithError:contextInfo:)), nil)
            } catch {
                
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.loading.accept(false)
            }
            
            
            }).disposed(by: disposeBag)
        
        // PlayerItem Did End
        self.didPlayToEnd.drive(onNext: { [weak self] _ in
            self?.playerState.accept(.end)
            }).disposed(by: disposeBag)
        
        // Slider Value Changed
        sliderValueChange.subscribe(onNext: { value in
            player.seek(to: CMTimeMakeWithSeconds(Float64(value), preferredTimescale: Int32(NSEC_PER_SEC)))
            }).disposed(by: disposeBag)
    }
    
    private func bottomButtonHandler() {
        
        switch self.playerState.value {
        case .playing:
            self.player.pause()
        case .pause:
            self.player.play()
        case .end:
            player.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: Int32(NSEC_PER_SEC)))
            self.player.play()
        }
    }
    
    @objc func handlePhotoSavingResult(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
        if let error = error {
            _photoSavingResult.accept(.error(error))
            return
        }
        _photoSavingResult.accept(.success("Saving was succeeded!\nPlease check your photo library."))
    }
}

enum Result<T> {
    case success(T)
    case error(Error)
}
