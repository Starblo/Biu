//
//  MusicManager.swift
//  Shooter
//
//  Created by Starblo Hong on 16/06/2018.
//  Copyright © 2018 Starblo Hong. All rights reserved.
//

import AVKit

class MusicManager {
    static let sharedInstance = MusicManager()
    private init() {}
    
    private var avPlayer: AVPlayer = AVPlayer(name: Sounds.theme, extension: "mp3")!
    private var player: AVPlayer = AVPlayer.init()
    private var bgmusicState: MusicState = .playing
    private var musicState: MusicState = .playing
    
    private let standartVolume: Float = 0.05
    
    func playBackgroundMusic() {
        avPlayer.volume = standartVolume
        avPlayer.playLoop()
    }
    
    func stopBackgroundMusic() {
        avPlayer.volume = 0
        avPlayer.endLoop()
    }
    
    func Loading() {
        player = AVPlayer(name: Sounds.loading, extension: "mp3")!
        if musicState == .playing {
            player.volume = standartVolume
        }
        else {
            player.volume = 0
        }
        player.playFromStart()
    }
    
    func bigSuccess() {
        player = AVPlayer(name: Sounds.bigsuc, extension: "mp3")!
        if musicState == .playing {
            player.volume = standartVolume
        }
        else {
            player.volume = 0
        }
        player.playFromStart()
    }
    
    func Success() {
        player = AVPlayer(name: Sounds.success, extension: "mp3")!
        if musicState == .playing {
            player.volume = standartVolume
        }
        else {
            player.volume = 0
        }
        player.playFromStart()
    }
    
    func Fail() {
        player = AVPlayer(name: Sounds.fail, extension: "mp3")!
        if musicState == .playing {
            player.volume = standartVolume
        }
        else {
            player.volume = 0
        }
        player.playFromStart()
    }
    
    func Biu() {
        player = AVPlayer(name: Sounds.biu, extension: "mp3")!
        if musicState == .playing {
            player.volume = standartVolume
        }
        else {
            player.volume = 0
        }
        player.playFromStart()
    }
    
    
    func changeBackMusicState(_ button: UIButton) {
        switch bgmusicState {
        case .playing:
            bgmusicState = .muted
            avPlayer.volume = 0
            button.setImage(#imageLiteral(resourceName: "musicoff"), for: .normal)
        case .muted:
            bgmusicState = .playing
            avPlayer.volume = standartVolume
            button.setImage(#imageLiteral(resourceName: "musicon"), for: .normal)
        }
    }
    
    func changeMusicState(_ button: UIButton) {
        switch musicState {
        case .playing:
            musicState = .muted
            player.volume = 0
            button.setImage(#imageLiteral(resourceName: "soundoff"), for: .normal)
        case .muted:
            musicState = .playing
            player.volume = standartVolume
            button.setImage(#imageLiteral(resourceName: "soundon"), for: .normal)
        }
    }
}
