//
//  settingViewController.swift
//  日记2.0
//
//  Created by 罗威 on 2021/3/28.
//

import UIKit

let kVersion:String = "2.0"
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
        indicatorViewManager.shared.start()
//        exportManager.shared.exportAll(){ [self] in
//        }
        indicatorViewManager.shared.stop()

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
        let attributes: [NSAttributedString.Key:Any] = [
            .font: (fontName != nil) ? UIFont(name: fontName!, size: fontSize)! : UIFont.systemFont(ofSize: fontSize, weight: .regular),
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
        let fontStyle = familyFonts[row]
        tempFontName = fontStyle
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
        fontSettingContainer.backgroundColor = .white
        backupSettingContainer.backgroundColor = .white
        securitySettingContainer.backgroundColor = .white
        textView.backgroundColor = .clear
        
        //添加字体
        familyFonts.append(nil)//默认字体
        for fontFamily in UIFont.familyNames{
//            print("fontFamily:\(fontFamily)")
            for fontName in UIFont.fontNames(forFamilyName: fontFamily){
//                print("fontName:\(fontName),")
                familyFonts.append(fontName)
            }
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
    func setupExampleTextView(imageScalingFactor:CGFloat){
        self.view.layoutIfNeeded()
        textView.attributedText = nil
        
        //插入文字
        let text =
        """
        版本\(kVersion)
        Version\(kVersion)

        """
        textView.insertText(text)
        
        
        //插入图片
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
        
//        textView.layer.borderWidth = 1
//        textView.layer.borderColor = UIColor.black.cgColor
//        textView.layer.cornerRadius = 5
    }
    
}

extension settingViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .large)
        ai.color = .black
        ai.startAnimating()
        ai.center = spinnerView.center
        spinnerView.alpha = 0
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
            UIView.animate(withDuration: 0.5) {
                spinnerView.alpha = 1
            } completion: { (_) in
                
            }

        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async { [self] in
            UIView.animate(withDuration: 0.5) {
                vSpinner?.alpha = 0
            } completion: { (_) in
                vSpinner?.removeFromSuperview()
                vSpinner = nil
            }
            
        }
    }
}
