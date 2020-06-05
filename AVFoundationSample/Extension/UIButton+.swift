//
//  UIButton+.swift
//  AVFoundationSample
//
//  Created by 今枝 稔晴 on 2020/06/05.
//  Copyright © 2020 今枝 稔晴. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func setCorner() {
        layer.cornerRadius = 5
        layer.masksToBounds = true
    }
}
