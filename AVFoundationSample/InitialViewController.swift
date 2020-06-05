//
//  InitialViewController.swift
//  AVFoundationSample
//
//  Created by 今枝 稔晴 on 2020/06/05.
//  Copyright © 2020 今枝 稔晴. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    @IBOutlet var buttons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buttons.forEach { button in
            button.setCorner()
        }
    }
    
    @IBAction func didTapButton(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            let vc = ExtractionOfAudioFromVideoViewController()
            vc.inject(AVManagementService())
            navigationController?.pushViewController(vc, animated: true)
            break
        default:
            break
        }
    }

}
