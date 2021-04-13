//
//  settingViewController.swift
//  日记2.0
//
//  Created by 罗威 on 2021/3/28.
//

import UIKit

class settingViewController: UIViewController {
    @IBOutlet weak var saveButton:UIButton!
    //font setting
    @IBOutlet weak var fontSettingContainer:UIView!
    @IBOutlet weak var textView:UITextView!
    @IBOutlet weak var fontSizeLabel:UILabel!
    @IBOutlet weak var fontSizeStepper:UIStepper!
    @IBOutlet weak var lineSpacingStepper:UIStepper!
    @IBOutlet weak var fontStylePicker:UIPickerView!
    var familyFonts:[String]!
    var tempFontSize:CGFloat = userDefaultManager.fontSize
    var tempFontName:String = userDefaultManager.fontName
    var tempLineSpacing:CGFloat = userDefaultManager.lineSpacing
    
    //security setting
    @IBOutlet weak var securitySettingContainer:UIView!
    @IBOutlet weak var BiometricsSwitch:UISwitch!
    @IBOutlet weak var passwordSwitch:UISwitch!

//MARK:-IBActions
    @IBAction func save(_ sender: Any) {
        //保存设置
        userDefaultManager.fontSize = tempFontSize
        userDefaultManager.fontName = tempFontName
        userDefaultManager.lineSpacing = tempLineSpacing
        
        //更新textView和monthCell的字体
        let todayVC = UIApplication.getTodayVC()
        if let attrString = todayVC.textView.attributedText{
            todayVC.textView.attributedText = attrString.addUserDefaultAttributes()
        }
        let monthVC = UIApplication.getMonthVC()
        monthVC.collectionView.reloadData()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func fontSizeDidChange(_ sender: UIStepper) {
        let fontSize = sender.value
        tempFontSize = CGFloat(fontSize)
        updateExampleTextView(withFontSize:tempFontSize,withFontStyle: tempFontName,withLineSpacing: tempLineSpacing)
        fontSizeLabel.text = String(Int(tempFontSize))
    }
    
    @IBAction func lineSapacingChange(_ sender: UIStepper){
        tempLineSpacing = CGFloat(sender.value)
        updateExampleTextView(withFontSize:tempFontSize,withFontStyle: tempFontName,withLineSpacing: tempLineSpacing)
    }
    
    @IBAction func useBiometricsSwitchDidChange(_ sender: UISwitch) {
        //if 如果设备不支持生物识别，则return
        //...
        //
        
        userDefaultManager.useBiometrics = sender.isOn
        
        if sender.isOn && !passwordSwitch.isOn{
            passwordSwitch.setOn(true, animated: true)
            usePasswordSwitchDidChange(passwordSwitch)
        }
    }
    
    @IBAction func usePasswordSwitchDidChange(_ sender: UISwitch){
        userDefaultManager.usePassword = sender.isOn
        
        //开启密码
        if sender.isOn{
            let ac = UIAlertController(title: "设置密码", message: "请输入App密码", preferredStyle: .alert)
            ac.addTextField()
            ac.addTextField()
            ac.addAction(UIAlertAction(title: "取消", style: .cancel){ [weak self]_ in
                //取消密码设置
                sender.setOn(false, animated: true)
                self!.BiometricsSwitch.setOn(false, animated: true)
                self!.useBiometricsSwitchDidChange(self!.BiometricsSwitch)//调用didchange，目的是同步userDefaultManager
            })
            ac.addAction(UIAlertAction(title: "提交", style: .default){[weak self] _ in
                //进行密码设置
                guard let password1 = ac.textFields?[0].text else {return}
                guard let password2 = ac.textFields?[1].text else {return}
                if password1 == password2{
                    userDefaultManager.password = password1
                }else{
                    //前后密码不一致，设置密码失败
                    sender.setOn(false, animated: true)
                    self!.BiometricsSwitch.setOn(false, animated: true)
                    self!.useBiometricsSwitchDidChange(self!.BiometricsSwitch)//调用didchange，目的是同步userDefaultManager
                    //提示再次进行设置密码
                    //...
                    return
                }
                
            })
            self.present(ac, animated: true)
        }
        
        //关闭密码
        if !sender.isOn{
            //关闭密码则生物识别也不能使用
            BiometricsSwitch.setOn(false, animated: true)
            useBiometricsSwitchDidChange(BiometricsSwitch)//调用didchange，目的是同步userDefaultManager
        }
        
        
    }
    
}

//MARK:-UITextView
extension settingViewController{
    func updateExampleTextView(withFontSize fontSize:CGFloat,withFontStyle fontName:String,withLineSpacing lineSpacing:CGFloat){
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .center
        paraStyle.lineSpacing = lineSpacing
        let attributes: [NSAttributedString.Key:Any] = [
            .font:UIFont(name: fontName, size: CGFloat(fontSize))!,
            .paragraphStyle : paraStyle
        ]
        let mutableAttr = NSMutableAttributedString(attributedString: textView.attributedText)
        mutableAttr.addAttributes(attributes, range: NSRange(location: 0, length: mutableAttr.length))
        textView.attributedText = mutableAttr
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
        pickerlabel.font = UIFont(name: familyFonts[row], size: 10)
        pickerlabel.text = familyFonts[row]
        return pickerlabel
    }
}

//MARK:- LIFE CYCLE
extension settingViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        familyFonts = UIFont.familyNames
//        for fontFamily in UIFont.familyNames{
//            print("fontFamily:\(fontFamily)")
//            for fontName in UIFont.fontNames(forFamilyName: fontFamily){
//                print("fontName:\(fontName),")
//            }
//        }
        
        //text view
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.cornerRadius = 5
        
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
        let selectedRow = familyFonts.firstIndex(of: userDefaultManager.fontName)!
        fontStylePicker.selectRow(selectedRow, inComponent: 0, animated: true)
        
        //security
        passwordSwitch.isOn = userDefaultManager.usePassword
        BiometricsSwitch.isOn = userDefaultManager.useBiometrics
        
        //add shadow & round corner
        fontSettingContainer.setupShadow(opacity: 1, radius: 4, offset: CGSize(width: 1, height: 1), color: UIColor.black.withAlphaComponent(0.35))
        securitySettingContainer.setupShadow(opacity: 1, radius: 4, offset: CGSize(width: 1, height: 1), color: UIColor.black.withAlphaComponent(0.35))
        fontSettingContainer.layer.cornerRadius = 10
        securitySettingContainer.layer.cornerRadius = 10
        
        
        updateExampleTextView(withFontSize: userDefaultManager.fontSize, withFontStyle: userDefaultManager.fontName, withLineSpacing: userDefaultManager.lineSpacing)
    }
}
