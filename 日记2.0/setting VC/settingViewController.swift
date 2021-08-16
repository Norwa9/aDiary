//
//  settingViewController.swift
//  日记2.0
//
//  Created by 罗威 on 2021/3/28.
//

import UIKit
import StoreKit

class settingViewController: UIViewController {
    @IBOutlet weak var saveButton:UIButton!
    //font setting
    @IBOutlet weak var imageSizeSegment:UISegmentedControl!
    @IBOutlet weak var fontSettingContainer:UIView!
    @IBOutlet weak var textView:UITextView!
    @IBOutlet weak var fontSizeLabel:UILabel!
    @IBOutlet weak var fontSizeStepper:UIStepper!
    @IBOutlet weak var lineSpacingStepper:UIStepper!
    var tempImageSizeStyle:Int = userDefaultManager.imageSizeStyle
    var tempFontSize:CGFloat = userDefaultManager.fontSize
    var tempFontName:String? = userDefaultManager.fontName
    var tempLineSpacing:CGFloat = userDefaultManager.lineSpacing
    
    //security setting
    @IBOutlet weak var securitySettingContainer:UIView!
    @IBOutlet weak var BiometricsSwitch:UISwitch!
    @IBOutlet weak var passwordSwitch:UISwitch!
    
    //back up setting
    @IBOutlet weak var backupSettingContainer:UIView!
    
    //notification setting
    @IBOutlet weak var dailyRemindSwitch:UISwitch!
    
//MARK:-IBActions
    @IBAction func save(_ sender: Any) {
        //保存设置
        userDefaultManager.fontSize = tempFontSize
        userDefaultManager.fontName = tempFontName
        userDefaultManager.lineSpacing = tempLineSpacing
        userDefaultManager.imageSizeStyle = tempImageSizeStyle
        
        let monthVC = UIApplication.getMonthVC()
        monthVC.reloadCollectionViewData()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissVC(){
        dismiss(animated: true, completion: nil)
    }
    //MARK:-UI
    ///字体大小
    @IBAction func fontSizeDidChange(_ sender: UIStepper) {
        let fontSize = sender.value
        tempFontSize = CGFloat(fontSize)
        updateExampleTextView(withFontSize:tempFontSize,withFontStyle: tempFontName,withLineSpacing: tempLineSpacing)
        fontSizeLabel.text = String(Int(tempFontSize))
    }
    
    ///行间距
    @IBAction func lineSapacingChange(_ sender: UIStepper){
        tempLineSpacing = CGFloat(sender.value)
        updateExampleTextView(withFontSize:tempFontSize,withFontStyle: tempFontName,withLineSpacing: tempLineSpacing)
    }
    
    //MARK:-安全
    ///生物识别
    @IBAction func useBiometricsSwitchDidChange(_ sender: UISwitch) {
        //如果已经设定了密码，此时可以自由开启关闭生物识别
        if userDefaultManager.usePassword{
            if sender.isOn{
                userDefaultManager.useBiometrics = true
            }else{
                userDefaultManager.useBiometrics = false
            }
        }
        
        //如果密码尚未设定，此时提示设定密码
        if !userDefaultManager.usePassword && sender.isOn {
            passwordSwitch.setOn(true, animated: true)
            usePasswordSwitchDidChange(passwordSwitch)
        }
        
        
    }
    
    ///密码
    @IBAction func usePasswordSwitchDidChange(_ sender: UISwitch){
        
        //如果用户打开开关：开启密码
        if sender.isOn{
            let ac = UIAlertController(title: "设置独立密码", message: "请妥善保管该密码", preferredStyle: .alert)
            ac.view.setupShadow()
            ac.addTextField()
            ac.addTextField()
            ac.textFields?[0].placeholder = "输入密码"
            ac.textFields?[1].placeholder = "重复密码"
            ac.addAction(UIAlertAction(title: "取消", style: .cancel){ [weak self]_ in
                //取消密码设置:
                sender.setOn(false, animated: true)
                self!.BiometricsSwitch.setOn(false, animated: true)
                userDefaultManager.useBiometrics = false
                userDefaultManager.usePassword = false
            })
            ac.addAction(UIAlertAction(title: "提交", style: .default){[weak self] _ in
                //进行密码设置
                guard let textField1 = ac.textFields?[0], let textField2 = ac.textFields?[1] else {return}
                guard let password1 = textField1.text,let password2 = textField2.text else {return}
                if password1 == password2 && (password1 != ""){
                    //成功设置密码
                    userDefaultManager.password = password1
                    
                    userDefaultManager.usePassword = true
                    if  self!.BiometricsSwitch.isOn{
                        userDefaultManager.useBiometrics = true
                    }
                }else{
                    //前后密码不一致，设置密码失败
                    sender.setOn(false, animated: true)
                    self!.BiometricsSwitch.setOn(false, animated: true)
                    userDefaultManager.usePassword = false
                    userDefaultManager.usePassword = false
                    //提示再次进行设置密码
                    //...
                    return
                }
                
            })
            self.present(ac, animated: true)
        }
        
        //用户关闭开关：关闭密码
        if !sender.isOn{
            //关闭密码则生物识别也不能使用
            BiometricsSwitch.setOn(false, animated: true)
            userDefaultManager.usePassword = false
            userDefaultManager.useBiometrics = false
        }
        
        
    }
    
    //MARK:-导入、导出
    ///导出
    @IBAction func exportAll(){
        exportManager.shared.exportAll(){ 
            
        }

//        let fileURL = DataContainerSingleton.sharedDataContainer.savePlistFile()
//        do {
//            let plistData = try Data(contentsOf: fileURL)
//            let ac = UIActivityViewController(activityItems: [plistData,fileURL], applicationActivities: nil)
//            self.present(ac, animated: true, completion: nil)
//        } catch {
//            print("fail to load plistFile")
//        }
        
    }
    
    ///daygram导入
    @IBAction func importFromDayGram(){
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.text"], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
}

//MARK:-UITextView
extension settingViewController{
    func updateExampleTextView(withFontSize fontSize:CGFloat,withFontStyle fontName:String?,withLineSpacing lineSpacing:CGFloat){
        //1.行间距
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .center
        paraStyle.lineSpacing = lineSpacing
        
        //2.字体
        let nameAttr = UIFontDescriptor.AttributeName.init(rawValue: "NSFontNameAttribute")
        var font:UIFont
        if let name = fontName{
            font = UIFont(descriptor: UIFontDescriptor(fontAttributes: [nameAttr : name]), size: fontSize)
        }else{
            font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        }
        
        
        let attributes: [NSAttributedString.Key:Any] = [
            .font: font,
            .paragraphStyle : paraStyle
        ]
        let mutableAttr = NSMutableAttributedString(attributedString: textView.attributedText)
        mutableAttr.addAttributes(attributes, range: NSRange(location: 0, length: mutableAttr.length))
        textView.attributedText = mutableAttr
    }
}

//MARK:-UISegmentControl
extension settingViewController{
    @objc func segmentedControlChanged(_ sender:UISegmentedControl){
        tempImageSizeStyle = sender.selectedSegmentIndex
        setupExampleTextView(imageScalingFactor: CGFloat(tempImageSizeStyle+1))
    }
}

//MARK:-UIDocumentPickerDelegate
extension settingViewController:UIDocumentPickerDelegate{
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard controller.documentPickerMode == .import, let url = urls.first, let importText = try? String(contentsOfFile: url.path) else { return }
        
        
        
        parseDayGramText(text: importText)
        
        
        controller.dismiss(animated: true)
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
}

//MARK:- LIFE CYCLE
extension settingViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        fontSettingContainer.backgroundColor = settingContainerDynamicColor
        backupSettingContainer.backgroundColor = settingContainerDynamicColor
        securitySettingContainer.backgroundColor = settingContainerDynamicColor
        textView.backgroundColor = .clear
        
        //image size segment control
        imageSizeSegment.selectedSegmentIndex = userDefaultManager.imageSizeStyle
        imageSizeSegment.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        
        //font size stepper
        fontSizeStepper.stepValue = 1
        fontSizeStepper.minimumValue = 10
        fontSizeStepper.maximumValue = 40
        fontSizeStepper.value = Double(userDefaultManager.fontSize)
        fontSizeLabel.text = String(Int(userDefaultManager.fontSize))
        
        //paragraph line spacing stepper
        lineSpacingStepper.stepValue = 1
        lineSpacingStepper.minimumValue = 0
        lineSpacingStepper.maximumValue = 10
        lineSpacingStepper.value = Double(userDefaultManager.lineSpacing)
        
        //security
        passwordSwitch.isOn = userDefaultManager.usePassword
        BiometricsSwitch.isOn = userDefaultManager.useBiometrics
        
        //notification
        //dailyRemindSwitch.isOn = userDefaultManager.dailyRemindEnable
        
        //add shadow & round corner
        fontSettingContainer.setupShadow()
        securitySettingContainer.setupShadow()
        backupSettingContainer.setupShadow()
        fontSettingContainer.layer.cornerRadius = 10
        securitySettingContainer.layer.cornerRadius = 10
        backupSettingContainer.layer.cornerRadius = 10
        
    }

    
    ///设置字体示意
    private func setupExampleTextView(imageScalingFactor:CGFloat){
        self.view.layoutIfNeeded()
        textView.attributedText = nil
        
        let shortVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        //插入文字
        let text =
        """
        版本\(shortVersionString)
        Version\(shortVersionString)

        """
        textView.insertText(text)
        
        
        //插入图标
        let attachment = NSTextAttachment()
        let image = UIImage(named: "icon-1024.png")!
        let imageAspectRatio = image.size.height / image.size.width
        let imageWidth = self.fontSettingContainer.frame.width
        print(imageWidth)
        let imageHeight = imageWidth * imageAspectRatio
        let compressedImage = image.compressPic(toSize: CGSize(width: imageWidth * 2, height: imageHeight * 2))
        attachment.image = compressedImage.createRoundedRectImage(size: compressedImage.size, radius: compressedImage.size.width / 25)
        let pedding:CGFloat = 15.0
        attachment.bounds = CGRect(x: 0, y: 0,
                                   width: (imageWidth - 2 * pedding) / imageScalingFactor,
                                   height: (imageHeight - 2 * pedding) / imageScalingFactor)
        let attStr = NSAttributedString(attachment: attachment)
        let mutableStr = NSMutableAttributedString(attributedString: textView.attributedText)
        mutableStr.insert(attStr, at: textView.attributedText.length)
        textView.attributedText = mutableStr
        
        //更新textView的字体等信息
        updateExampleTextView(withFontSize: tempFontSize, withFontStyle: tempFontName, withLineSpacing: tempLineSpacing)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if userDefaultManager.requestReviewTimes % 2 == 0{
            SKStoreReviewController.requestReview()
            userDefaultManager.requestReviewTimes += 1
        }
        //此时设置示例textView，才能取得正确的frame以正确显示图片的大小
        setupExampleTextView(imageScalingFactor: (CGFloat(userDefaultManager.imageSizeStyle + 1)))
    }
    
}

//MARK:-跳转app store评价
extension settingViewController{
    @IBAction func requestReview(){
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1564045149?action=write-review"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        //presentFontPickerVC()
    }
}

//MARK:-选取字体
extension settingViewController:UIFontPickerViewControllerDelegate{
    @IBAction func presentFontPickerVC(){
        let fontConfig = UIFontPickerViewController.Configuration()
        fontConfig.includeFaces = true//选取字体族下的不同字体
        let fontPicker = UIFontPickerViewController(configuration: fontConfig)
        fontPicker.delegate = self
        self.present(fontPicker, animated: true, completion: nil)
    }
    
    func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
        if let descriptor = viewController.selectedFontDescriptor{
            print(descriptor.fontAttributes)
            let selectedFont = UIFont(descriptor: descriptor, size: 20)
            let selectedFontName = selectedFont.fontName
            
            //更新示例
            tempFontName = selectedFontName
            self.updateExampleTextView(withFontSize: tempFontSize, withFontStyle: tempFontName, withLineSpacing: tempLineSpacing)
        }
    }
}
//MARK:-深色模式
extension settingViewController{
    @objc func appearanceModeDidChange(_ sender:UISegmentedControl){
        // 这里就简单介绍一下，实际项目中，如果是iOS应用这么写没问题，但是对于iPadOS应用还需要判断scene的状态是否激活
        #if os(iOS)
        let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        switch sender.selectedSegmentIndex {
        case 0:
            scene?.window?.overrideUserInterfaceStyle = .unspecified
        case 1:
            scene?.window?.overrideUserInterfaceStyle = .light
        case 2:
            scene?.window?.overrideUserInterfaceStyle = .dark
        default:
            scene?.window?.overrideUserInterfaceStyle = .unspecified
        }
        #endif
        
        
    }
}
    
//MARK:-订阅
extension settingViewController{
    @IBAction func showIAPViewController(){

        let vc = IAPViewController()
        self.present(vc, animated: true, completion: nil)
        
    }
}


//MARK:-每日提醒
extension settingViewController{
    ///每日提醒开关行为
    @IBAction func dailyReminderDidChange(_ sender: UISwitch){
        //一、开启每日提醒功能
        if sender.isOn{
            //需要先检查App的本地通知权限是否被用户关闭了
            LWNotificationHelper.shared.enableDailyRemind {
                DispatchQueue.main.async(execute: { () -> Void in
                    //1.恢复开关
                    sender.setOn(false, animated: true)
                    
                    //2.弹出警告框
                    let alertController = UIAlertController(title: "消息推送权限已被关闭",
                                                message: "想要App发送提醒。点击“设置”，开启通知。",
                                                preferredStyle: .alert)
                     
                    let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler:nil)
                     
                    let settingsAction = UIAlertAction(title:"设置", style: .default, handler: {
                        (action) -> Void in
                        let url = URL(string: UIApplication.openSettingsURLString)
                        if let url = url, UIApplication.shared.canOpenURL(url) {
                            if #available(iOS 10, *) {
                                UIApplication.shared.open(url, options: [:],
                                                          completionHandler: {
                                                            (success) in
                                })
                            } else {
                                UIApplication.shared.openURL(url)
                            }
                        }
                    })
                    alertController.addAction(cancelAction)
                    alertController.addAction(settingsAction)
                    self.present(alertController, animated: true, completion: nil)
                })
            } requestFailureCompletion: {
                //1.恢复开关
                sender.setOn(false, animated: true)
            }
        }
        
        
        //二、关闭每日提醒功能
        if sender.isOn == false{
            LWNotificationHelper.shared.disableDailyRemind()
        }
    }
}
