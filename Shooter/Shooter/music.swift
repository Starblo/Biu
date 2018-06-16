//
//  music.swift
//  Shooter
//
//  Created by Starblo Hong on 16/06/2018.
//  Copyright © 2018 Starblo Hong. All rights reserved.
//

import AVKit
import SpriteKit

enum Sounds {
    static let loading = "Loading"
    static let bigsuc = "BigSuccess"
    static let success = "Success"
    static let fail = "Fail"
    static let biu = "Biu"
    static let sec = "3Sec"
    static let theme = "Theme"
}

enum MusicState {
    case muted
    case playing
}

extension AVPlayer {
    convenience init?(name: String, extension ext: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            return nil
        }
        self.init(url: url)
    }
    
    func playLoop() {
        playFromStart()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.currentItem, queue: nil) { notification in
            if self.timeControlStatus == .playing {
                self.playFromStart()
            }
        }
    }
    
    func endLoop() {
        pause()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self)
    }
    
    func playFromStart() {
        seek(to: CMTimeMake(0, 1))
        play()
    }
}

