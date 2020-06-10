//
//  AVPlayerItem+Rx.swift
//  AVFoundationSample
//
//  Created by 今枝 稔晴 on 2020/06/08.
//  Copyright © 2020 今枝 稔晴. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import AVFoundation

extension Reactive where Base: AVPlayerItem {
    var didPlayToEnd: Observable<Notification> {
        return NotificationCenter.default.rx.notification(.AVPlayerItemDidPlayToEndTime, object: base)
    }
}
