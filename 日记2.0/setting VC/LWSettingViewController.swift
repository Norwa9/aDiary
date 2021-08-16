//
//  LWSettingViewController.swift
//  日记2.0
//
//  Created by yy on 2021/8/16.
//

import UIKit

class LWSettingViewController: UIViewController {
    var scrollView:UIScrollView!
    var containerView:UIView!
    
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
    
    var fontNameTitle:UILabel!
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
    var exportPDFLabel:UILabel!
    var exportPDFButton:UIButton!
    
    //其它
    var otherContainer:UIView!
    var otherContainerTitle:UILabel!
    //本地通知
    var dailyRemindLabel:UILabel!
    var dailyRemindSwitch:UISwitch!
    
    //通知
    var requestReviewLabel:UILabel!
    var requestReviewButton:UIButton!//跳转App Store评分按钮
    
    //其它信息
    var infoLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        setupUI()
        setupConstraints()
    }
    
    private func initUI(){
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        containerView = UIView()
        scrollView.addSubview(containerView)
        
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
        imageSizeTitle.font = .systemFont(ofSize: 18, weight: .medium)
        imageSizeSegment = UISegmentedControl(items: ["大","中","小"])
        fontContainerView.addSubview(imageSizeTitle)
        fontContainerView.addSubview(imageSizeSegment)
        
        fontSizeTitle = UILabel()
        fontSizeTitle.font = .systemFont(ofSize: 18, weight: .medium)
        fontSizeLabel = UILabel()
        fontSizeStepper = UIStepper()
        fontContainerView.addSubview(fontSizeTitle)
        fontContainerView.addSubview(fontSizeLabel)
        fontContainerView.addSubview(fontSizeStepper)
        
        lineSpacingTitle = UILabel()
        lineSpacingTitle.font = .systemFont(ofSize: 18, weight: .medium)
        lineSpacingStepper = UIStepper()
        fontContainerView.addSubview(lineSpacingTitle)
        fontContainerView.addSubview(lineSpacingStepper)
        
        fontNameTitle = UILabel()
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
        
        exportPDFLabel = UILabel()
        exportPDFButton = UIButton()
        backupContainer.addSubview(exportPDFLabel)
        backupContainer.addSubview(exportPDFButton)
        
        //-其它
        otherContainer = UIView()
        otherContainerTitle = UILabel()
        containerView.addSubview(otherContainer)
        containerView.addSubview(otherContainerTitle)
        
        dailyRemindLabel = UILabel()
        dailyRemindSwitch = UISwitch()
        otherContainer.addSubview(dailyRemindLabel)
        otherContainer.addSubview(dailyRemindSwitch)
        
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
        
    }
    
    private func setupConstraints(){
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
//            make.width.equalToSuperview()
            make.width.equalTo(globalConstantsManager.shared.kScreenWidth)
//            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
        }
        
        
        
        fontContainerView.snp.makeConstraints { make in
            
            make.height.equalTo(400)
        }
        
        
        
    }
    
    //MARK:-actions
    
}
