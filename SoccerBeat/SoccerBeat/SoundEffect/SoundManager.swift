//
//  SoundManager.swift
//  SoccerBeat
//
//  Created by jose Yun on 11/10/23.
//

import SwiftUI
import AVKit

class SoundManager: ObservableObject {
    var backgroundPlayer: AVAudioPlayer?
    var cardFrontPlayer: AVAudioPlayer?
    var cardBackPlayer: AVAudioPlayer?
    
    init(){
        setupPlayer()
    }
    
    func setupPlayer() {
        guard let backgroundURL = Bundle.main.url(forResource: "FifaBackground", withExtension: ".mp3") else { return }
        
        guard let effectURL = Bundle.main.url(forResource: "CardFlipEffect", withExtension: ".mp3") else { return }
        
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: backgroundURL)
            cardFrontPlayer = try AVAudioPlayer(contentsOf: effectURL)
            cardBackPlayer = try AVAudioPlayer(contentsOf: effectURL)
        } catch let error {
            print("재생하는데 오류가 발생했습니다. \(error.localizedDescription)")
        }

    }
    
    func playBackground() {
        backgroundPlayer?.numberOfLoops = -1
        backgroundPlayer?.play()
    }
    
    func playFrontSoundEffect() {
        cardFrontPlayer?.stop()
        cardFrontPlayer?.play()
    }
    
    func playBackSoundEffect() {
        cardBackPlayer?.stop()
        cardBackPlayer?.play()
    }
    
    
}
