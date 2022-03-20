//
//  LWSoundsViewController.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/19.
//

import UIKit
import AVFoundation

protocol LWSoundDelegate:AnyObject {
    
    func LWSoundDidFinishRecording(soundData:Data,soundFileLength:CGFloat)
}

class LWSoundsViewController: UIViewController {
    weak var delegate:LWSoundDelegate?
    var audioRecorder:AVAudioRecorder?
    static let KRecordingBtnWidth:CGFloat = 160.0
    static let KRecordingBtnHeight:CGFloat = 50.0
    
    var timer:Timer!
    
    var titleLabel:UILabel!
    var timingLabel:LWTimingLabel!
    var recordButtonOutlet: LWRecodingButton!
    var saveButtonOutlet: UIButton!
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
        
        initUI()
        setCons()
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func initUI(){
        self.view.backgroundColor = .systemBackground
        self.view.layer.cornerRadius = 10
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.text = "插入音频"
        
        timingLabel = LWTimingLabel()
        
        
        recordButtonOutlet = LWRecodingButton()
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(startRecord))
        recordButtonOutlet.addGestureRecognizer(tapGes)
        
        saveButtonOutlet = UIButton()
        saveButtonOutlet.addTarget(self, action: #selector(stopRecord), for: .touchUpInside)
        saveButtonOutlet.setAttributedTitle(NSAttributedString(string: "完成").addingAttributes([
            .font : UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor : UIColor.link
        ]), for: .normal)
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(timingLabel)
        self.view.addSubview(recordButtonOutlet)
        self.view.addSubview(saveButtonOutlet)
    }
    
    private func setCons(){
        titleLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(18)
        }
        
        timingLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(globalConstantsManager.shared.kScreenWidth - 100.0)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.height.equalTo(60.0)
        }
        
        recordButtonOutlet.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: LWSoundsViewController.KRecordingBtnWidth, height: LWSoundsViewController.KRecordingBtnHeight))
            make.top.equalTo(timingLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        saveButtonOutlet.snp.makeConstraints { make in
            make.centerY.equalTo(recordButtonOutlet)
            make.left.equalTo(recordButtonOutlet.snp.right).offset(20)
        }
        
    }
    
    
    private func checkMicrophoneAccess(){
        // Check Microphone Authorization
        switch AVAudioSession.sharedInstance().recordPermission {
            
            case AVAudioSession.RecordPermission.granted:
                print(#function, " Microphone Permission Granted")
                break
                
            case AVAudioSession.RecordPermission.denied:
                // Dismiss Keyboard (on UIView level, without reference to a specific text field)
                UIApplication.shared.sendAction(#selector(UIView.endEditing(_:)), to:nil, from:nil, for:nil)
                
                let alertVC = UIAlertController(title: "无法录音", message: "请到系统设置开启aDiary麦克风权限", preferredStyle: .alert)
                
                // Left hand option (default color in PMAlertAction.swift)
                alertVC.addAction(UIAlertAction(title: "设置", style: .default) { _ in
                    DispatchQueue.main.async {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                        }
                    } // end dispatchQueue
                })
                
                // Right hand option (default color grey)
                alertVC.addAction(UIAlertAction(title: "取消", style: .cancel))
                
                self.present(alertVC, animated: true, completion: nil)
                return
                
            case AVAudioSession.RecordPermission.undetermined:
                print("Request permission here")
                // Dismiss Keyboard (on UIView level, without reference to a specific text field)
                UIApplication.shared.sendAction(#selector(UIView.endEditing(_:)), to:nil, from:nil, for:nil)
                
                AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                    // Handle granted
                    if granted {
                        print(#function, " Now Granted")
                    } else {
                        print("Pemission Not Granted")
                        
                    } // end else
                })
            @unknown default:
                print("ERROR! Unknown Default. Check!")
        } // end switch
        
    } // end func checkMicrophoneAccess
    
    
    private func setUp(){
        // Microphone Authorization/Permission
        checkMicrophoneAccess()
        
        
        // Set the audio file
        let directoryURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in:
            FileManager.SearchPathDomainMask.userDomainMask).first
        
        let audioFileName = "test-sound-file-20220319" + ".m4a"
        let audioFileURL = directoryURL!.appendingPathComponent(audioFileName)
        
        // Setup audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playAndRecord)), mode: .default)
        } catch _ {
        }
        
        // Define the recorder setting
        let recorderSetting = [AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC as UInt32),
                            AVSampleRateKey: 12000.0,
                            AVNumberOfChannelsKey: 2 ]
        
        audioRecorder = try? AVAudioRecorder(url: audioFileURL, settings: recorderSetting)
        audioRecorder?.delegate = self
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.prepareToRecord()
    }
    
    private func startTiming(){
        saveButtonOutlet.isEnabled = false
        timer = Timer.scheduledTimer(withTimeInterval: 1 / 60, repeats: true) { timer in
            self.timingLabel.time += 1.0
        }
        recordButtonOutlet.recordAnimation(isRecording: true)

    }
    
    private func pauseTiming(){
        saveButtonOutlet.isEnabled = true
        timer.invalidate()
        recordButtonOutlet.recordAnimation(isRecording: false)
    }
    
    private func finishTiming(){
        self.timingLabel.time = 0
    }
    
    // 开始录音或者暂停录音
    @objc func startRecord(){
        // Stop the audio player before recording
        if let player = LWSoundPlayer.shared.audioPlayer {
            if player.isPlaying {
                player.stop()
            }
        }
        
        if let recorder = audioRecorder {
            if !recorder.isRecording {
                let audioSession = AVAudioSession.sharedInstance()
                
                do {
                    try audioSession.setActive(true)
                } catch _ {
                }
                
                // Start recording
                recorder.record()
                startTiming()
                
            } else {
                // Pause recording
                recorder.pause()
                pauseTiming()
                
                
            }
        }
    }
    
    @objc func stopRecord(){
        // Stop recording
        if let recorder = audioRecorder {
            print("audioRecorder?.stop()")
            recorder.stop() // 调用audioRecorderDidFinishRecording?
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(false)
            } catch _ {
                
            }
        }
        
        // Stop the audio player if playing
        if let player = LWSoundPlayer.shared.audioPlayer {
            if player.isPlaying {
                player.stop()
            }
        }
    }
    
}


// MARK: Audio delegate
extension LWSoundsViewController:AVAudioRecorderDelegate,AVAudioPlayerDelegate{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            do {
                let soundData = try Data.init(contentsOf: recorder.url)
                delegate?.LWSoundDidFinishRecording(soundData: soundData, soundFileLength: timingLabel.time)
                finishTiming() // 重置时间
                self.dismiss(animated: true, completion: nil)
            } catch _ {
            }
        }
    }

}

// MARK: UIViewControllerTransitioningDelegate
extension LWSoundsViewController:UIViewControllerTransitioningDelegate{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return cardPresentationController(presentedViewController: presented, presenting: presenting,viewHeight: 200)
    }
}

// Helper function inserted by Swift migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}

// Helper function inserted by Swift migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}


