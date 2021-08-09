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
    @IBOutlet weak var fontStylePicker:UIPickerView!
    var familyFonts = [String?]()
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
    var activityIndicator:UIActivityIndicatorView!//进度条
    var vSpinner : UIView?
    
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
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .center
        paraStyle.lineSpacing = lineSpacing
        let nameAttr = UIFontDescriptor.AttributeName.init(rawValue: "NSFontNameAttribute")
        let customFont = UIFont(descriptor: UIFontDescriptor(fontAttributes: [nameAttr : fontName]), size: fontSize)
        let attributes: [NSAttributedString.Key:Any] = [
//            .font: (fontName != nil) ? UIFont(name: fontName!, size: fontSize)! : UIFont.systemFont(ofSize: fontSize, weight: .regular),
            .font: (fontName != nil) ? UIFont(name: fontName!, size: fontSize)! : customFont,
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

//MARK:-UIPickerView
extension settingViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return familyFonts.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return familyFonts[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let name = familyFonts[row]
        tempFontName = name
        updateExampleTextView(withFontSize: tempFontSize, withFontStyle: tempFontName,withLineSpacing: tempLineSpacing)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerlabel = UILabel()
        pickerlabel.adjustsFontSizeToFitWidth = true
        pickerlabel.textAlignment = .center
        pickerlabel.backgroundColor = .clear
        if row == 0{
            //默认字体
            pickerlabel.font = .systemFont(ofSize: 12, weight: .regular)
            pickerlabel.text = "系统字体"
        }else{
            //其他字体
            pickerlabel.font = UIFont(name: familyFonts[row]!, size: 12)
            pickerlabel.text = familyFonts[row]
        }
        
        return pickerlabel
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
        
        //添加字体
        familyFonts.append(nil)//默认字体
//        for fontFamily in UIFont.familyNames{
//            //print("fontFamily:\(fontFamily)")
//            for fontName in UIFont.fontNames(forFamilyName: fontFamily){
//                //print("fontName:\(fontName),")
//                familyFonts.append(fontName)
//            }
//        }
        for name in userDefaultManager.userInsatlledFontNames{
            familyFonts.append(name)
        }
        
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
        
        //font style picker
        fontStylePicker.dataSource = self
        fontStylePicker.delegate = self
        if let fontName = userDefaultManager.fontName{
            if let selectedRow = familyFonts.firstIndex(of: fontName){
                fontStylePicker.selectRow(selectedRow, inComponent: 0, animated: true)
            }
        }else{
            fontStylePicker.selectRow(0, inComponent: 0, animated: true)
        }
        
        
        
        //security
        passwordSwitch.isOn = userDefaultManager.usePassword
        BiometricsSwitch.isOn = userDefaultManager.useBiometrics
        
        //add shadow & round corner
        fontSettingContainer.setupShadow()
        securitySettingContainer.setupShadow()
        backupSettingContainer.setupShadow()
        fontSettingContainer.layer.cornerRadius = 10
        securitySettingContainer.layer.cornerRadius = 10
        backupSettingContainer.layer.cornerRadius = 10
        
        setupExampleTextView(imageScalingFactor: (CGFloat(userDefaultManager.imageSizeStyle + 1)))
        
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
    }
    
}

//MARK:-跳转app store评价
extension settingViewController{
    @IBAction func requestReview(){
//        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1564045149?action=write-review"){
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        }
        presentFontPickerVC()
    }
}

//MARK:-选取字体
extension settingViewController:UIFontPickerViewControllerDelegate{
    func presentFontPickerVC(){
        let fontConfig = UIFontPickerViewController.Configuration()
        fontConfig.includeFaces = true//选取字体族下的不同字体
        let fontPicker = UIFontPickerViewController(configuration: fontConfig)
        fontPicker.delegate = self
        self.present(fontPicker, animated: true, completion: nil)
    }
    
    func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
        if let descriptor = viewController.selectedFontDescriptor{
            print(descriptor.fontAttributes)
            let font = UIFont(descriptor: descriptor, size: 20)
            
            let familyName = font.familyName
            let fontName = font.fontName
            
            if !userDefaultManager.userInsatlledFontNames.contains(fontName){
                userDefaultManager.userInsatlledFontNames.append(fontName)
            }
            
            
            let familyAttr = UIFontDescriptor.AttributeName.init(rawValue: "NSFontFamilyAttribute")
            let nameAttr = UIFontDescriptor.AttributeName.init(rawValue: "NSFontNameAttribute")
            let familyDescriptor = UIFontDescriptor(fontAttributes: [familyAttr : familyName])
            let nameDescriptor = UIFontDescriptor(fontAttributes: [nameAttr : fontName])
            let font1 = UIFont(descriptor: familyDescriptor, size: 20)
            let font2 = UIFont(descriptor: nameDescriptor, size: 20)
            
            
            let font3 = UIFont(name: fontName, size: 20)
            
            textView.font = font3
            print(font3?.fontName)
            textView.text = "\(font1.familyName),\(font1.fontName)" + "\(font2.familyName),\(font2.fontName)"
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
