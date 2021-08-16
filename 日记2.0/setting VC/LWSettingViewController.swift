//
//  LWSettingViewController.swift
//  日记2.0
//
//  Created by yy on 2021/8/16.
//

import UIKit
import StoreKit

class LWSettingViewController: UIViewController {
    var scrollView:UIScrollView!
    var containerView:UIView!
    
    //总的标题
    var settingTitle:UILabel!
    
    //按钮
    var saveButton:UIButton!
    var dismissButton:UIButton!
    
    //字体设置
    var fontContainerTitle:UILabel!
    var fontContainerView:UIView!
    var textView:UITextView!
    
    var imageSizeTitle:UILabel!
    var imageSizeSegment:UISegmentedControl!
    
    var fontSizeTitle:UILabel!
    var fontSizeLabel:UILabel!
    var fontSizeStepper:UIStepper!
    
    var lineSpacingTitle:UILabel!
    var lineSpacingStepper:UIStepper!
    
    var fontPickerTitle:UILabel!
    var fontPickerButton:UIButton!
    
    var tempImageSizeStyle:Int = userDefaultManager.imageSizeStyle
    var tempFontSize:CGFloat = userDefaultManager.fontSize
    var tempFontName:String? = userDefaultManager.fontName
    var tempLineSpacing:CGFloat = userDefaultManager.lineSpacing
    
    //隐私
    var privacyContainer:UIView!
    var privacyContainerTitle:UILabel!
    var biometricsLabel:UILabel!
    var biometricsSwitch:UISwitch!
    var passwordLabel:UILabel!
    var passwordSwitch:UISwitch!
    
    //备份
    var backupContainer:UIView!
    var backupContainerTitle:UILabel!
    var exportPDFButton:UIButton!
    
    //其它
    var otherContainer:UIView!
    var otherContainerTitle:UILabel!
    //本地通知
    var dailyRemindLabel:UILabel!
    var dailyRemindSwitch:UISwitch!
    var dailyRemindDatePicker:UIDatePicker!
    
    //评价
    var requestReviewLabel:UILabel!
    var requestReviewButton:UIButton!//跳转App Store评分按钮
    
    //深色模式
    var darkModeLabel:UILabel!
    var darkModeSegment:UISegmentedControl!
    
    //其它信息
    var infoLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        setupUI()
        setupConstraints()
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
    
    private func initUI(){
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        containerView = UIView()
        scrollView.addSubview(containerView)
        
        settingTitle = UILabel()
        containerView.addSubview(settingTitle)
        
        //-确认/返回
        saveButton = UIButton()
        dismissButton = UIButton()
        
        //-字体
        fontContainerView = UIView()
        fontContainerTitle = UILabel()
        containerView.addSubview(fontContainerView)
        containerView.addSubview(fontContainerTitle)
        
        textView = UITextView()
        fontContainerView.addSubview(textView)
        
        imageSizeTitle = UILabel()
        imageSizeSegment = UISegmentedControl(items: ["大","中","小"])
        fontContainerView.addSubview(imageSizeTitle)
        fontContainerView.addSubview(imageSizeSegment)
        
        fontSizeTitle = UILabel()
        fontSizeLabel = UILabel()
        fontSizeStepper = UIStepper()
        fontContainerView.addSubview(fontSizeTitle)
        fontContainerView.addSubview(fontSizeLabel)
        fontContainerView.addSubview(fontSizeStepper)
        
        lineSpacingTitle = UILabel()
        lineSpacingStepper = UIStepper()
        fontContainerView.addSubview(lineSpacingTitle)
        fontContainerView.addSubview(lineSpacingStepper)
        
        fontPickerTitle = UILabel()
        fontPickerButton = UIButton()
        fontContainerView.addSubview(fontSizeTitle)
        fontContainerView.addSubview(fontPickerButton)
        
        //-隐私
        privacyContainer = UIView()
        privacyContainerTitle = UILabel()
        containerView.addSubview(privacyContainer)
        containerView.addSubview(privacyContainerTitle)
        
        biometricsLabel = UILabel()
        biometricsSwitch = UISwitch()
        passwordLabel = UILabel()
        passwordSwitch = UISwitch()
        privacyContainer.addSubview(biometricsLabel)
        privacyContainer.addSubview(biometricsSwitch)
        privacyContainer.addSubview(passwordLabel)
        privacyContainer.addSubview(passwordSwitch)
        
        //-备份
        backupContainer = UIView()
        backupContainerTitle = UILabel()
        containerView.addSubview(backupContainer)
        containerView.addSubview(backupContainerTitle)
        
        exportPDFButton = UIButton()
        backupContainer.addSubview(exportPDFButton)
        
        //-其它(评价，深色模式，本地通知)
        otherContainer = UIView()
        otherContainerTitle = UILabel()
        containerView.addSubview(otherContainer)
        containerView.addSubview(otherContainerTitle)
        
        darkModeLabel = UILabel()
        darkModeSegment = UISegmentedControl(items: ["跟随系统","深色","浅色"])
        otherContainer.addSubview(darkModeLabel)
        otherContainer.addSubview(darkModeSegment)
        
        dailyRemindLabel = UILabel()
        dailyRemindSwitch = UISwitch()
        dailyRemindDatePicker = UIDatePicker()
        otherContainer.addSubview(dailyRemindLabel)
        otherContainer.addSubview(dailyRemindSwitch)
        otherContainer.addSubview(dailyRemindDatePicker)
        
        requestReviewLabel = UILabel()
        requestReviewButton = UIButton()
        otherContainer.addSubview(requestReviewLabel)
        otherContainer.addSubview(requestReviewButton)
        
        //-其它
        infoLabel = UILabel()
        containerView.addSubview(infoLabel)
        
        
        
    }
    
    private func setupUI(){
        scrollView.backgroundColor = .systemBackground
        
        settingTitle.text = "设置"
        settingTitle.font = .systemFont(ofSize: 20, weight: .bold)
        
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        dismissButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        //字体
        fontContainerTitle.text = "字体"
        fontContainerTitle.font = .systemFont(ofSize: 18, weight: .medium)
        fontContainerView.backgroundColor = settingContainerDynamicColor
        fontContainerView.setupShadow()
        fontContainerView.layer.cornerRadius = 10
        
        textView.backgroundColor = .clear
        
        imageSizeTitle.text = "图片大小"
        imageSizeTitle.font = .systemFont(ofSize: 18, weight: .medium)
        imageSizeSegment.selectedSegmentIndex = userDefaultManager.imageSizeStyle
        imageSizeSegment.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        
        lineSpacingTitle.text = "行间距"
        lineSpacingTitle.font = .systemFont(ofSize: 18, weight: .medium)
        lineSpacingStepper.stepValue = 1
        lineSpacingStepper.minimumValue = 0
        lineSpacingStepper.maximumValue = 10
        lineSpacingStepper.value = Double(userDefaultManager.lineSpacing)
        lineSpacingStepper.addTarget(self, action: #selector(lineSapacingChange), for: .valueChanged)
        
        fontSizeTitle.text = "字体大小"
        fontSizeStepper.stepValue = 1
        fontSizeStepper.minimumValue = 10
        fontSizeStepper.maximumValue = 40
        fontSizeStepper.value = Double(userDefaultManager.fontSize)
        fontSizeLabel.text = String(Int(userDefaultManager.fontSize))
        fontSizeStepper.addTarget(self, action: #selector(fontSizeDidChange(_:)), for: .valueChanged)
        
        fontPickerTitle.text = "字体"
        fontPickerTitle.font = .systemFont(ofSize: 18, weight: .medium)
        fontPickerButton.setTitle("选取自定义字体", for: .normal)
        fontPickerButton.addTarget(self, action: #selector(presentFontPickerVC), for: .touchUpInside)
        
        //隐私
        privacyContainerTitle.text = "隐私"
        privacyContainerTitle.font = .systemFont(ofSize: 18, weight: .medium)
        privacyContainer.backgroundColor = settingContainerDynamicColor
        privacyContainer.setupShadow()
        privacyContainer.layer.cornerRadius = 10
        
        passwordLabel.text = "使用App密码"
        passwordSwitch.isOn = userDefaultManager.usePassword
        passwordSwitch.addTarget(self, action: #selector(usePasswordSwitchDidChange(_:)), for: .valueChanged)
        biometricsLabel.text = "使用FaceID/TouchID"
        biometricsSwitch.isOn = userDefaultManager.useBiometrics
        biometricsSwitch.addTarget(self, action: #selector(useBiometricsSwitchDidChange(_:)), for: .valueChanged)
        
        //备份
        backupContainerTitle.text = "备份"
        backupContainerTitle.font = .systemFont(ofSize: 18, weight: .medium)
        backupContainer.backgroundColor = settingContainerDynamicColor
        backupContainer.setupShadow()
        backupContainer.layer.cornerRadius = 10
        
        exportPDFButton.setTitle("导出所有日记为PDF", for: .normal)
        exportPDFButton.addTarget(self, action: #selector(exportAll), for: .touchUpInside)
        
        //其它
        otherContainerTitle.text = "其它"
        otherContainerTitle.font = .systemFont(ofSize: 18, weight: .medium)
        otherContainer.backgroundColor = settingContainerDynamicColor
        otherContainer.setupShadow()
        otherContainer.layer.cornerRadius = 10
        
        requestReviewButton.setTitle("好评鼓励", for: .normal)
        requestReviewButton.addTarget(self, action: #selector(requestReview), for: .touchUpInside)
        requestReviewLabel.text = "支持开发者🍗"
        
        
        
        
        
        
    }
    
    private func setupConstraints(){
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(globalConstantsManager.shared.kScreenWidth)//必须为常量
        }
        
        settingTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
        }
        
        
        
        
        
        
    }
    
    //MARK:-字体
    @objc func save(){
        //保存设置
        userDefaultManager.fontSize = tempFontSize
        userDefaultManager.fontName = tempFontName
        userDefaultManager.lineSpacing = tempLineSpacing
        userDefaultManager.imageSizeStyle = tempImageSizeStyle
        
        let monthVC = UIApplication.getMonthVC()
        monthVC.reloadCollectionViewData()
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissVC(){
        dismiss(animated: true, completion: nil)
    }
    
    ///图片大小
    @objc func segmentedControlChanged(_ sender:UISegmentedControl){
        tempImageSizeStyle = sender.selectedSegmentIndex
        setupExampleTextView(imageScalingFactor: CGFloat(tempImageSizeStyle+1))
    }
    
    ///字体大小
    @objc func fontSizeDidChange(_ sender: UIStepper) {
        let fontSize = sender.value
        tempFontSize = CGFloat(fontSize)
        updateExampleTextView(withFontSize:tempFontSize,withFontStyle: tempFontName,withLineSpacing: tempLineSpacing)
        fontSizeLabel.text = String(Int(tempFontSize))
    }
    
    ///行间距
    @objc func lineSapacingChange(_ sender: UIStepper){
        tempLineSpacing = CGFloat(sender.value)
        updateExampleTextView(withFontSize:tempFontSize,withFontStyle: tempFontName,withLineSpacing: tempLineSpacing)
    }
    
    //MARK:-密码
    ///生物识别
    @objc func useBiometricsSwitchDidChange(_ sender: UISwitch) {
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
    
    ///数字密码
    @objc func usePasswordSwitchDidChange(_ sender: UISwitch){
        
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
                self!.biometricsSwitch.setOn(false, animated: true)
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
                    if  self!.biometricsSwitch.isOn{
                        userDefaultManager.useBiometrics = true
                    }
                }else{
                    //前后密码不一致，设置密码失败
                    sender.setOn(false, animated: true)
                    self!.biometricsSwitch.setOn(false, animated: true)
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
            biometricsSwitch.setOn(false, animated: true)
            userDefaultManager.usePassword = false
            userDefaultManager.useBiometrics = false
        }
    }
    
    //MARK:-导出
    @objc func exportAll(){
        exportManager.shared.exportAll(){
            
        }
    }
    
    //MARK:-请求好评
    @objc func requestReview(){
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1564045149?action=write-review"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        //presentFontPickerVC()
    }
    
    //MARK:-切换显示模式
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
    
    //MARK:-订阅
    @objc func showIAPViewController(){

        let vc = IAPViewController()
        self.present(vc, animated: true, completion: nil)
        
    }
    
    //MARK:-每日提醒开关行为
    @objc func dailyReminderDidChange(_ sender: UISwitch){
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

//MARK:-选取字体
extension LWSettingViewController:UIFontPickerViewControllerDelegate{
    @objc func presentFontPickerVC(){
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


//MARK:-示例textView
extension LWSettingViewController{
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
        let imageWidth = self.fontContainerView.frame.width
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
