//
//  LWSoundViewModel.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/19.
//

import Foundation
import UIKit
import SubviewAttachingTextView
import AVFAudio

class LWSoundViewModel:NSObject{
    /// uuid
    var uuid:String
    /// 音频文件
    var soundData:Data?
    /// 创建时间
    var createdDate:Date
    /// 音频文件插入的位置
    var location:Int
    /// 音频文件名
    var soundFileName:String = "新录音"
    /// 音频文件大小
    var soundFileSize:String
    /// 音频文件时间长度
    var soundFileLength:CGFloat = 0
    
    let bounds:CGRect = globalConstantsManager.shared.defaultLWSoundViewBounds
    
    var timer:Timer?
    var curTime:CGFloat = 0.0 // 当前已经计的时间，秒
    var isPlaying = false
    weak var soundView:LWSoundView?
    weak var lwTextView:LWTextView?{
        return UIApplication.getTodayVC()?.subpagesView.curTextVC?.textView
    }
    weak var lwTextVC:LWTextViewController?{
        return UIApplication.getTodayVC()?.subpagesView.curTextVC
    }

    
    /// 插入音频附件
    init(location:Int,soundData:Data,soundFileLength:CGFloat){
        self.uuid = UUID().uuidString
        self.soundData = soundData
        self.createdDate = Date()
        self.location = location
        self.soundFileSize = soundData.calSize() // 计算文件大小
        self.soundFileLength = soundFileLength
        
        let audio = LWSound(uuid: uuid, soundData: soundData)
        LWSoundHelper.shared.addAudios(audios: [audio]) // 创建viewModel的同时，创建它的Data
        
        super.init()
    }
    
    // 读取model时创建viewModel
    init(model:LWSoundModel){
        self.uuid = model.uuid
        self.createdDate = model.createdDate
        self.soundData = LWSoundHelper.shared.loadAudio(uuid: model.uuid)
        self.location = model.location
        self.soundFileName = model.soundFileName
        self.soundFileSize = model.soundFileSize
        self.soundFileLength = model.soundFileLength
        
        
        super.init()
    }
    
    /// viewModel转Model
    func generateModel() -> LWSoundModel{
        let model = LWSoundModel(uuid: uuid, createdDate: createdDate,location: location,soundFileName: soundFileName, soundFileSize: soundFileSize, soundFileLength: soundFileLength)
        return model
    }
    
    func getFileName() ->NSAttributedString{
        let title = ""+soundFileName
        let fileName = NSAttributedString(string: title).addingAttributes([
            .font : userDefaultManager.font,
            .foregroundColor : UIColor.label
        ]
        )
        return fileName
        
    }
    
    func getTiming() -> NSAttributedString{
        let curCount_s = getConvertedTime(count: curTime)
        let fileLengthCount_s = getConvertedTime(count: soundFileLength)
        let progress = "\(curCount_s)/\(fileLengthCount_s)"
        let timing = NSAttributedString(string: progress).addingAttributes([
            .font : userDefaultManager.customFont(withSize: 12),
            .foregroundColor : UIColor.secondaryLabel
        ])
        return timing
    }
    
    func getCreateTime() -> NSAttributedString{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/M/d/HH:mm"
        let formattedDate = dateFormatter.string(from: createdDate)
        let title = formattedDate
        let createTime = NSAttributedString(string: title).addingAttributes([
            .font : userDefaultManager.customFont(withSize: 12),
            .foregroundColor : UIColor.secondaryLabel
        ])
        return createTime

    }
    
    private func rename(newName:String){
        soundFileName = newName
        soundView?.fileNameLabel.attributedText = self.getFileName() // 更新文件名
        if let lwTextVC = self.lwTextVC {
            lwTextVC.save()
        }
    }
    
    
    /// 获取播放进度
    /// 输入是当前已计的时间
    func updateProgress(){
        //TODO: 1. 更新播放状态（图标）
        if curTime == 0{
            self.soundView?.playButton?.togglePlayState(isPlaying: isPlaying)
        }
        
        // 2. 更新时间进度
        self.soundView?.timingLabel.attributedText = getTiming()
    }
    
    //MARK: 音频控制
    func startPlaying(){
        // 开始▶️
        print("soundView 开始播放")
        // 1.开始计时
        timer = Timer.scheduledTimer(withTimeInterval: 1 / 60, repeats: true) { timer in
            if self.curTime >= self.soundFileLength{
                self.timer?.invalidate()
                self.stopPlaying()
                return
            }else{
                self.curTime += 1.0
            }
            // 更新播放进度
            self.updateProgress()
        }
        // 2.开始播放
        LWSoundPlayer.shared.play(soundViewModel: self)
        
        isPlaying.toggle() // to true
        soundView?.playButton.togglePlayState(isPlaying: isPlaying)
    }
    
    func stopPlaying(){
        // 停止播放⏹
        print("soundView 重新播放")
        timer?.invalidate()
        self.curTime = 0.0
        self.updateProgress()
        LWSoundPlayer.shared.stop()
        
        isPlaying.toggle() // to false
        soundView?.playButton.togglePlayState(isPlaying: isPlaying)
    }
    
    
    
    // MARK: soundView Actions
    public func renameSoundFile(){
        let ac = UIAlertController(title: "重命名音频文件", message: "", preferredStyle: .alert)
        ac.addTextField { textfield in
            textfield.text = self.soundFileName
        }
        ac.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            guard let newName = ac.textFields?[0].text else{
                return
            }
            self.rename(newName: newName)
        }))
        ac.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        UIApplication.getTopViewController()?.present(ac, animated: true, completion: nil)
    }
    
    public func shareSoundFile(){
        if let soundData = soundData {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(self.soundFileName + ".m4a")
            do {
                try soundData.write(to: url)
                let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                if let topVC = UIApplication.getTopViewController(){
                    let isPad = ( UIDevice.current.userInterfaceIdiom == .pad)
                    if isPad {
                        activityVC.popoverPresentationController?.sourceView = topVC.view
                        activityVC.popoverPresentationController?.sourceRect = CGRect(x: topVC.view.bounds.width / 2, y: topVC.view.bounds.height / 2, width: 0, height: 0)
                        activityVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
                    }
                    topVC.present(activityVC, animated: true, completion: nil)
                }
            } catch {
                print("write error: bufferSound.m4a")
            }
        }
    }
    
    public func deleteSoundView(){
        if let lwTextView = lwTextView {
            self.getNewestLocation(attributedString: lwTextView.attributedText) {
                lwTextView.textStorage.deleteCharacters(in: NSRange(location: location, length: 1))
                let location = location
                lwTextView.selectedRange = NSRange(location: location, length: 0)
                lwTextView.textViewController?.save() // 保存后，遍历得到soundFile的变化，然后就会把soundFile删除了
            }
        }
    }
    
    typealias completionType = ()->(Void)
    ///view的location发生变化后，计算新的location
    func getNewestLocation(attributedString:NSAttributedString,completion:completionType){
        let fullRange = NSRange(location: 0, length: attributedString.length)
        attributedString.enumerateAttribute(.attachment, in: fullRange, options: []) { object, range, stop in
            if let attchment = object as? SubviewTextAttachment{
                if let view = attchment.viewProvider.instantiateView(for: attchment, in: SubviewAttachingTextViewBehavior.init()) as? LWSoundView{
                    if view.viewModel == self{
                        let newestLocation = range.location
                        self.location = newestLocation
                        print("newest sound View location : \(newestLocation)")
                        completion()
                        stop.pointee = true
                        return
                    }
                }
                
            }
        }
    }
}

extension LWSoundViewModel:AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
    }
}
