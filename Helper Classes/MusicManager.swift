//
//  MusicManager.swift
//  AcidRain_2
//
//  Created by Daniel Lans on 3/17/18.
//  Copyright © 2018 lessThanAlpha. All rights reserved.
//

import AVFoundation

// Music Manager
class MusicManager {
    
    static let shared = MusicManager()
    
    var audioPlayer = AVAudioPlayer()
    
    
    private init() { } // private singleton init
    
    
    func setup(songName:String) {
        do {
            audioPlayer =  try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: songName, ofType: "mp3")!))
            audioPlayer.prepareToPlay()
        } catch {
            print (error)
        }
    }
    
    
    func play() {
        audioPlayer.play()
        audioPlayer.numberOfLoops = -1
    }
    
    func pause() {
        audioPlayer.pause()
    }
    
    func stop() {
        audioPlayer.stop()
        audioPlayer.currentTime = 0 // I usually reset the song when I stop it. To pause it create another method and call the pause() method on the audioPlayer.
        audioPlayer.prepareToPlay()
    }
}

