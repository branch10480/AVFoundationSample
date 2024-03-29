//
//  ExtractionOfAudioFromVideoViewController.swift
//  AVFoundationSample
//
//  Created by 今枝 稔晴 on 2020/06/05.
//  Copyright © 2020 今枝 稔晴. All rights reserved.
//

import UIKit
import RxSwift
import AVFoundation
import SVProgressHUD

class ExtractionOfAudioFromVideoViewController: UIViewController {
    
    private var avmService: AVManagementServiceProtocol!
    private let disposeBag = DisposeBag()
    @IBOutlet var buttons: [UIButton]!
    private var asset: AVAsset!

    public func inject(_ asset: AVAsset) {
        self.asset = asset
    }

    public func inject(_ service: AVManagementServiceProtocol) {
        self.avmService = service
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Extraction of audio from video"
        buttons.forEach { button in
            button.setCorner()
        }
    }
    
    @IBAction func didTapConvertButton(_ sender: Any) {
        SVProgressHUD.show()
        avmService.getAudio(from: asset)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] asset in
                SVProgressHUD.dismiss()
                self?.launchAVPlayer(asset: asset)
            }, onError: { [weak self] error in
                SVProgressHUD.dismiss()
                let ac = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: .alert)
                ac.addAction(.init(title: "OK", style: .default, handler: nil))
                self?.present(ac, animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
    
    @IBAction func didTapPlayButton(_ sender: Any) {
        launchAVPlayer(asset: asset)
    }
    
    private func launchAVPlayer(asset: AVAsset) {
        let vc = AVPlayerViewController()
        vc.inject(asset)
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
    }
}
