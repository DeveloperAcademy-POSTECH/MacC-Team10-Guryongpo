//
//  SoundManager.swift
//  SoccerBeat
//
//  Created by jose Yun on 11/10/23.
//

import AVKit
import SwiftUI

final class SoundManager: ObservableObject {
    private var backgroundPlayer: AVAudioPlayer?
    private var cardFrontPlayer: AVAudioPlayer?
    private var cardBackPlayer: AVAudioPlayer?
    private var photoSelectPlayer: AVAudioPlayer?
    
    @Published var isMusicPlaying = true
    
    init() {
        setupPlayer()
    }
    
    func setupPlayer() {
        // 음악파일 Url 로딩
        guard let backgroundURL = Bundle.main.url(forResource: "FifaBackground",
                                                  withExtension: ".mp3"),
              let cardEffectURL = Bundle.main.url(forResource: "CardFlipEffect",
                                                  withExtension: ".mp3"),
              let photoSelectEffectURL = Bundle.main.url(forResource: "PhotoSelectEffect",
                                                         withExtension: ".mp3")
            else { return }
        
        // 음악 파일 별로 플레이어 할당
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: backgroundURL)
            cardFrontPlayer = try AVAudioPlayer(contentsOf: cardEffectURL)
            cardBackPlayer = try AVAudioPlayer(contentsOf: cardEffectURL)
            photoSelectPlayer = try AVAudioPlayer(contentsOf: photoSelectEffectURL)
        } catch let error {
            print("재생하는데 오류가 발생했습니다. \(error.localizedDescription)")
        }
        
        // 상태 불러와서 저장
        self.isMusicPlaying = UserDefaults.standard.bool(forKey: "isMusicPlaying")
    }
    
    func playBackground() {
        backgroundPlayer?.numberOfLoops = -1
        backgroundPlayer?.play()
    }
    
    func stopBackground() {
        backgroundPlayer?.stop()
    }
    
    func playFrontSoundEffect() {
        cardFrontPlayer?.stop()
        cardFrontPlayer?.play()
    }
    
    func playBackSoundEffect() {
        cardBackPlayer?.stop()
        cardBackPlayer?.play()
    }
    
    func playPhotoSelectEffect() {
        photoSelectPlayer?.play()
    }
    
    func toggleMusic() {
        isMusicPlaying ? stopBackground() : playBackground()
        isMusicPlaying.toggle()
        UserDefaults.standard.set(isMusicPlaying, forKey: "isMusicPlaying")
    }
}
