//
//  InitialViewController.swift
//  AVFoundationSample
//
//  Created by 今枝 稔晴 on 2020/06/05.
//  Copyright © 2020 今枝 稔晴. All rights reserved.
//

import UIKit
import AVFoundation

class InitialViewController: UIViewController {

    @IBOutlet var buttons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buttons.forEach { button in
            button.setCorner()
        }
    }
    
    private func pushToNext(asset: AVAsset?) {
        let vc = ExtractionOfAudioFromVideoViewController()
        vc.inject(AVManagementService())
        
        var asset = asset
        if asset == nil, let path = Bundle.main.path(forResource: "rooster", ofType: "mp4") {
            let url = URL(fileURLWithPath: path)
            asset = AVAsset(url: url)
        }
        vc.inject(asset!)
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapSampleButton(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            pushToNext(asset: nil)
        default:
            break
        }
    }

    @IBAction func didTapLibraryButton(_ sender: Any) {
        let imagePC = UIImagePickerController()
        imagePC.sourceType = .photoLibrary
        imagePC.mediaTypes = ["public.movie"]
        imagePC.delegate = self
        present(imagePC, animated: true, completion: nil)
    }
}

extension InitialViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {
            return
        }
        let asset = AVAsset(url: videoURL)
        picker.dismiss(animated: true, completion: { [weak self] in
            self?.pushToNext(asset: asset)
        })
    }
}
