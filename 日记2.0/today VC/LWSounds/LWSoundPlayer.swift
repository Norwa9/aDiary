//
//  LWSoundPlayer.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/19.
//

import Foundation
import AVFAudio


class LWSoundPlayer{
    static let shared:LWSoundPlayer = LWSoundPlayer()
    var audioPlayer:AVAudioPlayer?
    var lastPlayedSoundViewModel:LWSoundViewModel?
    
    func play(soundViewModel:LWSoundViewModel?){
        guard let soundViewModel = soundViewModel else {
            return
        }
        // 每次都重头开始播放内容
        
        // 之前有播放过view，暂停计时
        if let lastPlayedSoundViewModel = lastPlayedSoundViewModel{
            // 上一次播放的音频与本次音频不是同一段，且上一次播放的音频在播放的过程中被切换到本次播放音频
            if lastPlayedSoundViewModel != soundViewModel && lastPlayedSoundViewModel.isPlaying{
                lastPlayedSoundViewModel.stopPlaying()
            }
        }
        // 让新的viewModel开始播放
        if let soundData = soundViewModel.soundData {
            audioPlayer = try? AVAudioPlayer(data: soundData, fileTypeHint: "m4a")
            audioPlayer?.play()
        }
        
        self.lastPlayedSoundViewModel = soundViewModel
    }
    

    
    func stop(){
        if let audioPlayer = audioPlayer {
            if audioPlayer.isPlaying{
                audioPlayer.stop()
            }
        }
    }
    
//    func replay(contentsOf soundData:Data){
//        stop()
//        play(contentsOf: soundData)
//
//    }
    
    //    func pause(){
    //        if let audioPlayer = audioPlayer {
    //            if audioPlayer.isPlaying{
    //                audioPlayer.pause()
    //            }
    //        }
    //    }
    
}
