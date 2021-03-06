//
//  LWSettingViewController.swift
//  日记2.0
//
//  Created by yy on 2021/8/16.
//

import UIKit
import StoreKit
import AttributedString

class LWSettingViewController: UIViewController {
    static let titleFont:UIFont = UIFont.systemFont(ofSize: 20, weight: .medium)
    static let contentFont:UIFont = UIFont.systemFont(ofSize: 18, weight: .regular)
    var scrollView:UIScrollView!
    var containerView:UIView!
    
    //总的标题
    var settingTitle:UILabel!
    
    //按钮
    var saveButton:UIButton!
    var dismissButton:UIButton!
    
    //付费
    var iapSettingCell:LWIAPSettingCell!
    
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
    var fontPickerButton:LWFontPickerButton!
    var cellFontPickerTitle:UILabel!
    var cellFontPickerTipBtn:UIButton!
    var cellFontPickerButton:LWFontPickerButton!
    var selecedFontButton:FontPlace!
    
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
    var iCloudCell:LWiCloudCell!
    
    
    //其它
    var otherContainer:UIView!
    var otherContainerTitle:UILabel!
    var autoCreateTitle:UILabel!
    var autoCreateTitleSwitch:UISwitch!
    
    // 每日提醒通知
    var dailyRemindLabel:UILabel!
    var dailyRemindSwitch:UISwitch!
    var dailyRemindDatePicker:UIDatePicker!
    
    // 显示农历
    var showLunarCell:LWSwitchSettingCell!
    
    // todo样式
    var todoListStyleCell:LWSegSettingCell!
    
    // 模板管理
    var templateManageCell:LWTemplateSettingCell!
    
    //评价
    var requestReviewLabel:UILabel!
    var requestReviewButton:UIButton!//跳转App Store评分按钮
    
    //深色模式
    var darkModeLabel:UILabel!
    var darkModeSegment:UISegmentedControl!
    
    // 联系我
    var contactWaysContainer:UIView!
    var contactWaysContainerTitle:UILabel!
    var contactMeWeiboCell:LWSettingCell!
    var contactMeMailCell:LWSettingCell!
    var contactMeWeChat:LWSettingCell!
    
    
    //其它信息
    var infoLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        setupUI()
        setupConstraints()
        
        //此时设置示例textView，才能取得正确的frame以正确显示图片的大小
        setupExampleTextView(imageScalingFactor: (CGFloat(userDefaultManager.imageSizeStyle + 1)))
    }
    
    //MARK: -实例化UI
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
        containerView.addSubview(saveButton)
        containerView.addSubview(dismissButton)
        
        // 内购
        iapSettingCell = LWIAPSettingCell(delegate: self, selector: #selector(showIAPViewController))
        containerView.addSubview(iapSettingCell)
        
        
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
        fontPickerButton = LWFontPickerButton(delegate: self, actionSelector: #selector(presentFontPickerVC),fontPlace: .diary)
        fontContainerView.addSubview(fontPickerTitle)
        fontContainerView.addSubview(fontPickerButton)
        
        cellFontPickerTitle = UILabel()
        cellFontPickerTipBtn = UIButton()
        cellFontPickerTipBtn.addTarget(self, action: #selector(showCellFontTips), for: .touchUpInside)
        cellFontPickerButton = LWFontPickerButton(delegate: self, actionSelector: #selector(presentCellFontPickerVC), fontPlace: .monthCell)
        fontContainerView.addSubview(cellFontPickerTitle)
        fontContainerView.addSubview(cellFontPickerTipBtn)
        fontContainerView.addSubview(cellFontPickerButton)
        
        
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
        iCloudCell = LWiCloudCell(
            delegate: self,
            switchState: userDefaultManager.iCloudEnable,
            title: "iClound备份",
            selector: #selector(iCloudDidChange(_:))
        )
        backupContainer.addSubview(iCloudCell)
        backupContainer.addSubview(exportPDFButton)
        
        //-其它(评价，深色模式，本地通知)
        otherContainer = UIView()
        otherContainerTitle = UILabel()
        containerView.addSubview(otherContainer)
        containerView.addSubview(otherContainerTitle)
        
        darkModeLabel = UILabel()
        darkModeSegment = UISegmentedControl(items: ["自动","浅色","深色"])
        otherContainer.addSubview(darkModeLabel)
        otherContainer.addSubview(darkModeSegment)
        
        todoListStyleCell = LWSegSettingCell(
            delegate:self,
            title: "主页待办列表样式",
            icon: nil,
            controlItems: ["默认","消失","置底"],
            selectedSegmentIndex: userDefaultManager.todoListViewStyle,
            selector: #selector(todoListStyleDidChange(_:))
        )
        otherContainer.addSubview(todoListStyleCell)
        
        // 模板
        templateManageCell = LWTemplateSettingCell(
            delegate: self,
            title: "日记模板",
            selector: #selector(templateCellDidTap)
        )
        otherContainer.addSubview(templateManageCell)
        
        // 农历
        showLunarCell = LWSwitchSettingCell(
            delegate: self,
            switchState: userDefaultManager.showLunar,
            title: "显示农历",
            selector: #selector(showLunarDidChange(_:))
        )
        otherContainer.addSubview(showLunarCell)
        
        
        dailyRemindLabel = UILabel()
        dailyRemindSwitch = UISwitch()
        dailyRemindDatePicker = UIDatePicker()
        otherContainer.addSubview(dailyRemindLabel)
        otherContainer.addSubview(dailyRemindSwitch)
        otherContainer.addSubview(dailyRemindDatePicker)
        
        autoCreateTitle = UILabel()
        autoCreateTitleSwitch = UISwitch()
        otherContainer.addSubview(autoCreateTitle)
        otherContainer.addSubview(autoCreateTitleSwitch)
        
        requestReviewLabel = UILabel()
        requestReviewButton = UIButton()
        otherContainer.addSubview(requestReviewLabel)
        otherContainer.addSubview(requestReviewButton)
        
        
        
        // MARK:  - 联系我
        contactWaysContainer = UIView()
        contactWaysContainerTitle = UILabel()
        contactWaysContainerTitle.text = "反馈"
        contactWaysContainerTitle.font = LWSettingViewController.titleFont
        contactWaysContainer.backgroundColor = settingContainerDynamicColor
        contactWaysContainer.setupShadow()
        contactWaysContainer.layer.cornerRadius = 10
        
        contactMeMailCell = LWSettingCell(text: "邮件联系", accessoryImage: nil, actionSelector: #selector(openMail), accessoryActionSelector: nil)
        contactMeWeChat = LWSettingCell(text: "加入用户群", accessoryImage: nil, actionSelector: #selector(joinUserGroup), accessoryActionSelector: nil)
        contactMeWeiboCell = LWSettingCell(text: "关注微博", accessoryImage: nil, actionSelector: #selector(jumpToWeibo), accessoryActionSelector: nil)
        contactMeMailCell.delegate = self
        contactMeWeiboCell.delegate = self
        contactMeWeChat.delegate = self
        contactWaysContainer.addSubview(contactMeMailCell)
        contactWaysContainer.addSubview(contactMeWeiboCell)
        contactWaysContainer.addSubview(contactMeWeChat)
        containerView.addSubview(contactWaysContainerTitle)
        containerView.addSubview(contactWaysContainer)
        
        //-其它
        infoLabel = UILabel()
        containerView.addSubview(infoLabel)
        
        
        
    }
    
    //MARK: -填充UI
    private func setupUI(){
        scrollView.backgroundColor = .systemBackground
        
        settingTitle.text = "设置"
        settingTitle.font = .systemFont(ofSize: 24, weight: .bold)
        
        saveButton.setAttributedTitle(settingVCConfig.saveButtonAttributedTitle(title: "保存", color: .label), for: .normal)
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        
        dismissButton.setAttributedTitle(settingVCConfig.cancelButtonAttributedTitle(title: "返回",color: .secondaryLabel), for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        //字体
        fontContainerTitle.text = "字体"
        fontContainerTitle.font = LWSettingViewController.titleFont
        fontContainerView.backgroundColor = settingContainerDynamicColor
        fontContainerView.setupShadow()
        fontContainerView.layer.cornerRadius = 10
        
        textView.backgroundColor = .clear
        
        imageSizeTitle.text = "图片大小"
        imageSizeTitle.font = LWSettingViewController.contentFont
        imageSizeSegment.selectedSegmentIndex = userDefaultManager.imageSizeStyle
        imageSizeSegment.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        
        lineSpacingTitle.text = "行间距"
        lineSpacingTitle.font = LWSettingViewController.contentFont
        lineSpacingStepper.stepValue = 1
        lineSpacingStepper.minimumValue = 0
        lineSpacingStepper.maximumValue = 10
        lineSpacingStepper.value = Double(userDefaultManager.lineSpacing)
        lineSpacingStepper.addTarget(self, action: #selector(lineSapacingChange), for: .valueChanged)
        
        fontSizeTitle.text = "默认字号"
        fontSizeTitle.font = LWSettingViewController.contentFont
        fontSizeLabel.text = String(Int(userDefaultManager.fontSize))
        fontSizeLabel.font = LWSettingViewController.contentFont
        fontSizeStepper.minimumValue = 10
        fontSizeStepper.maximumValue = 40
        fontSizeStepper.value = Double(userDefaultManager.fontSize)
        fontSizeStepper.addTarget(self, action: #selector(fontSizeDidChange(_:)), for: .valueChanged)
        
        fontPickerTitle.text = "日记字体"
        fontPickerTitle.font = LWSettingViewController.contentFont
        
        cellFontPickerTitle.text = "主页字体"
        cellFontPickerTitle.font = LWSettingViewController.contentFont
        cellFontPickerTipBtn.setImage(UIImage(systemName: "info.circle"), for: .normal)
        
        //隐私
        privacyContainerTitle.text = "隐私"
        privacyContainerTitle.font = LWSettingViewController.titleFont
        privacyContainer.backgroundColor = settingContainerDynamicColor
        privacyContainer.setupShadow()
        privacyContainer.layer.cornerRadius = 10
        
        passwordLabel.text = "使用App密码"
        passwordLabel.font = LWSettingViewController.contentFont
        passwordSwitch.isOn = userDefaultManager.usePassword
        passwordSwitch.addTarget(self, action: #selector(usePasswordSwitchDidChange(_:)), for: .valueChanged)
        biometricsLabel.text = "使用FaceID/TouchID"
        biometricsLabel.font = LWSettingViewController.contentFont
        biometricsSwitch.isOn = userDefaultManager.useBiometrics
        biometricsSwitch.addTarget(self, action: #selector(useBiometricsSwitchDidChange(_:)), for: .valueChanged)
        
        //备份
        backupContainerTitle.text = "备份"
        backupContainerTitle.font = LWSettingViewController.titleFont
        backupContainer.backgroundColor = settingContainerDynamicColor
        backupContainer.setupShadow()
        backupContainer.layer.cornerRadius = 10
        
        exportPDFButton.setAttributedTitle(settingVCConfig.exportPDFButtonAttributedTitle(title: "导出日记",color: .link), for: .normal)
        exportPDFButton.contentHorizontalAlignment = .leading
        exportPDFButton.addTarget(self, action: #selector(showExportVC), for: .touchUpInside)
        
        //其它
        otherContainerTitle.text = "其它"
        otherContainerTitle.font = LWSettingViewController.titleFont
        otherContainer.backgroundColor = settingContainerDynamicColor
        otherContainer.setupShadow()
        otherContainer.layer.cornerRadius = 10
        
        darkModeLabel.text = "外观模式"
        darkModeLabel.font = LWSettingViewController.contentFont
        darkModeSegment.selectedSegmentIndex = userDefaultManager.appearanceMode
        darkModeSegment.addTarget(self, action: #selector(appearanceModeDidChange(_:)), for: .valueChanged)
        
        dailyRemindLabel.text = "每日提醒"
        dailyRemindLabel.font = LWSettingViewController.contentFont
        dailyRemindSwitch.isOn = userDefaultManager.dailyRemindEnable
        dailyRemindSwitch.addTarget(self, action: #selector(dailyReminderDidChange(_:)), for: .valueChanged)
        dailyRemindDatePicker.datePickerMode = .time
        dailyRemindDatePicker.locale = Locale(identifier: "zh_CN")
        dailyRemindDatePicker.setDate(userDefaultManager.dailyRemindTimeDate, animated: true)
        dailyRemindDatePicker.addTarget(self, action: #selector(dateDidChange(_:)), for: .valueChanged)
        
        autoCreateTitle.text = "自动创建新日记"
        autoCreateTitle.font = LWSettingViewController.contentFont
        autoCreateTitleSwitch.isOn = userDefaultManager.autoCreate
        autoCreateTitleSwitch.addTarget(self, action: #selector(autoCreateDiary(_:)), for: .valueChanged)
        
        requestReviewButton.setAttributedTitle(settingVCConfig.reviewButtonAttributedTitle(title: "App Store撰写好评",color: .link), for: .normal)
        requestReviewButton.contentHorizontalAlignment = .leading
        requestReviewButton.addTarget(self, action: #selector(requestReview), for: .touchUpInside)
        requestReviewLabel.text = "支持开发者🍗"
        requestReviewLabel.font = .systemFont(ofSize: 10)
        
        
        
        
        
        infoLabel.numberOfLines = 0
        let info: ASAttributedString =
            .init(
                """
                \("期待收到你的使用反馈和功能建议。",.font(.systemFont(ofSize: 15, weight: .medium)),.foreground(.secondaryLabel))
                \("长按复制联系方式：",.font(.systemFont(ofSize: 15, weight: .medium)),.foreground(.secondaryLabel))
                \(.image(#imageLiteral(resourceName: "mail"), .custom(size: CGSize(width: 17, height: 17))))\("norwa99@163.com",.font(.systemFont(ofSize: 15)),.foreground(.secondaryLabel),.action(richTextDidClicked))\(.image(#imageLiteral(resourceName: "copy"), .custom(size: CGSize(width: 15, height: 15))))
                \(.image(#imageLiteral(resourceName: "wechat"),.custom(size: CGSize(width: 15, height: 15)))) \("n0rway99(进用户群)",.font(.systemFont(ofSize: 15)),.foreground(.secondaryLabel),.action(richTextDidClicked))\((.image(#imageLiteral(resourceName: "copy"), .custom(size: CGSize(width: 15, height: 15)))))
                """
            )
        infoLabel.attributed.text = info
        
    }
    
    //MARK: -约束
    private func setupConstraints(){
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
        }
        
        settingTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
        }
        
        saveButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(settingTitle)
            make.width.equalTo(40)
        }
        
        dismissButton.snp.makeConstraints { make in
            make.right.equalTo(saveButton.snp.left).offset(-5)
            make.centerY.equalTo(saveButton)
            make.width.equalTo(40)
        }
        
        //MARK: layout：付费
        iapSettingCell.snp.makeConstraints { make in
            make.top.equalTo(settingTitle.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        // MARK:  - layout:字体
        fontContainerTitle.snp.makeConstraints { make in
            make.top.equalTo(iapSettingCell.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(15)
        }
        
        fontContainerView.snp.makeConstraints { make in
            make.top.equalTo(fontContainerTitle.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        textView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(2)
            make.left.equalToSuperview().offset(2)
            make.right.equalToSuperview().offset(-2)
            make.height.equalTo(100)
        }
        
        imageSizeTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.equalTo(textView.snp.bottom).offset(20)
        }
        
        imageSizeSegment.snp.makeConstraints { make in
            make.centerY.equalTo(imageSizeTitle)
            make.right.equalTo(textView).offset(-10)
        }
        
        lineSpacingTitle.snp.makeConstraints { make in
            make.top.equalTo(imageSizeTitle.snp.bottom).offset(20)
            make.left.equalTo(imageSizeTitle)
        }
        
        lineSpacingStepper.snp.makeConstraints { make in
            make.centerY.equalTo(lineSpacingTitle)
            make.width.equalTo(imageSizeSegment)
            make.right.equalTo(imageSizeSegment)
        }
        
        fontSizeTitle.snp.makeConstraints { make in
            make.left.equalTo(imageSizeTitle)
            make.top.equalTo(lineSpacingTitle.snp.bottom).offset(20)
        }
        
        fontSizeStepper.snp.makeConstraints { make in
            make.centerY.equalTo(fontSizeTitle)
            make.width.equalTo(imageSizeSegment)
            make.right.equalTo(imageSizeSegment)
        }
        
        fontSizeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(fontSizeStepper.snp.left).offset(-5)
            make.centerY.equalTo(fontSizeStepper)
            make.width.equalTo(30)
        }
        
        fontPickerTitle.snp.makeConstraints { make in
            make.left.equalTo(imageSizeTitle)
            make.top.equalTo(fontSizeTitle.snp.bottom).offset(20)
            
        }
        
        fontPickerButton.snp.makeConstraints { make in
            make.left.greaterThanOrEqualTo(fontPickerTitle.snp.right)
            make.right.equalTo(imageSizeSegment)
            make.centerY.equalTo(fontPickerTitle)
            make.height.equalTo(fontSizeStepper)
        }
        
        cellFontPickerTitle.snp.makeConstraints { make in
            make.left.equalTo(imageSizeTitle)
            make.top.equalTo(fontPickerTitle.snp.bottom).offset(20)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        cellFontPickerTipBtn.snp.makeConstraints { make in
            make.left.equalTo(cellFontPickerTitle.snp.right)
            make.centerY.equalTo(cellFontPickerTitle)
            make.height.width.equalTo(cellFontPickerTitle.snp.height)
        }
        
        cellFontPickerButton.snp.makeConstraints { make in
            make.left.greaterThanOrEqualTo(cellFontPickerTitle.snp.right)
            make.right.equalTo(imageSizeSegment)
            make.centerY.equalTo(cellFontPickerTitle)
            make.height.equalTo(fontSizeStepper)
        }
        
        // MARK:  - layout:隐私
        privacyContainerTitle.snp.makeConstraints { make in
            make.top.equalTo(fontContainerView.snp.bottom).offset(40)
            make.left.equalTo(fontContainerTitle)
        }
        
        privacyContainer.snp.makeConstraints { make in
            make.top.equalTo(privacyContainerTitle.snp.bottom).offset(10)
            make.left.right.equalTo(fontContainerView)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
        }
        
        passwordSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(passwordLabel)
            make.right.equalToSuperview().offset(-10)
        }
        
        biometricsLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(20)
            make.left.equalTo(passwordLabel)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        biometricsSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(biometricsLabel)
            make.right.equalToSuperview().offset(-10)
        }
        
        
        // MARK:  - layout:备份
        backupContainerTitle.snp.makeConstraints { make in
            make.top.equalTo(privacyContainer.snp.bottom).offset(40)
            make.left.equalTo(fontContainerTitle)
        }
        
        backupContainer.snp.makeConstraints { make in
            make.top.equalTo(backupContainerTitle.snp.bottom).offset(10)
            make.left.right.equalTo(fontContainerView)
        }
        
        iCloudCell.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(exportPDFButton.snp.top)
        }

        exportPDFButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-5)
            make.width.equalTo(200)
        }
        
        // MARK:  - layout:其他
        otherContainerTitle.snp.makeConstraints { make in
            make.top.equalTo(backupContainer.snp.bottom).offset(40)
            make.left.equalTo(fontContainerTitle)
        }
        
        otherContainer.snp.makeConstraints { make in
            make.top.equalTo(otherContainerTitle.snp.bottom).offset(10)
            make.left.right.equalTo(fontContainerView)
        }
        
        darkModeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
        }
        
        darkModeSegment.snp.makeConstraints { make in
            make.centerY.equalTo(darkModeLabel)
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(150)
        }
        
        todoListStyleCell.snp.makeConstraints { make in
            make.top.equalTo(darkModeLabel.snp.bottom).offset(10) // 10 + 10(内)
            make.left.right.equalToSuperview()
        }
        
        templateManageCell.snp.makeConstraints { make in
            make.top.equalTo(todoListStyleCell.snp.bottom).offset(0) // 10 + 10(内)
            make.left.right.equalToSuperview()
        }
        
        showLunarCell.snp.makeConstraints { make in
            make.top.equalTo(templateManageCell.snp.bottom).offset(0) // 10(内) + 10(内) + 0 = 20
            make.left.right.equalToSuperview()
        }
        
        dailyRemindLabel.snp.makeConstraints { make in
            make.top.equalTo(showLunarCell.snp.bottom).offset(10)
            make.left.equalTo(darkModeLabel)
        }
        
        dailyRemindSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(dailyRemindLabel)
            make.right.equalTo(todoListStyleCell).offset(-10)
        }
        
        dailyRemindDatePicker.snp.makeConstraints { make in
            make.centerY.equalTo(dailyRemindLabel)
            make.right.equalTo(dailyRemindSwitch.snp.left).offset(-10)
        }
        
        autoCreateTitle.snp.makeConstraints { make in
            make.top.equalTo(dailyRemindLabel.snp.bottom).offset(20)
            make.left.equalTo(dailyRemindLabel)
        }
        
        autoCreateTitleSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(autoCreateTitle)
            make.right.equalTo(dailyRemindSwitch)
        }
        
        requestReviewButton.snp.makeConstraints { make in
            make.top.equalTo(autoCreateTitle.snp.bottom).offset(15) // 20 -> 15 ，button比label高一些
            make.left.equalTo(darkModeLabel)
            make.bottom.equalToSuperview().offset(-10)
            make.width.equalTo(200)
        }
        
        requestReviewLabel.snp.makeConstraints { make in
            make.top.equalTo(requestReviewButton.snp.bottom).offset(-8)
            make.left.equalTo(requestReviewButton)
        }
        
        // MARK:  - layout:联系我
        contactWaysContainerTitle.snp.makeConstraints { make in
            make.top.equalTo(otherContainer.snp.bottom).offset(40)
            make.left.equalTo(fontContainerTitle)
        }
        
        contactWaysContainer.snp.makeConstraints { make in
            make.top.equalTo(contactWaysContainerTitle.snp.bottom).offset(10)
            make.left.right.equalTo(fontContainerView)
        }
        
        contactMeMailCell.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }
        
        contactMeWeiboCell.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(contactMeMailCell.snp.bottom).offset(20)
        }
        
        contactMeWeChat.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(contactMeWeiboCell.snp.bottom).offset(20)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(contactWaysContainer.snp.bottom).offset(50)
            make.left.right.equalTo(otherContainer)
            make.height.equalTo(0)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        
    }
    
    //MARK: action内购
    @objc func showIAPViewController(){
        let vc = IAPViewController()
        self.present(vc, animated: true, completion: nil)
        
    }
    
    
    //MARK: -保存
    @objc func save(){
        //保存设置
        userDefaultManager.lineSpacing = tempLineSpacing
        userDefaultManager.imageSizeStyle = tempImageSizeStyle
        userDefaultManager.fontSize = tempFontSize
        
        // 刷新list，使待办列表样式生效
        UIApplication.getMonthVC()?.diaryListView.reloadCollectionViewData()
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissVC(){
        dismiss(animated: true, completion: nil)
    }
    
    
    
    //MARK: -示例textView
    private func setupExampleTextView(imageScalingFactor:CGFloat){
        self.view.layoutIfNeeded()
        textView.attributedText = nil
        
        //插入文字
        let shortVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let text =
        """

        aDiary
        版本\(shortVersionString)

        """
        textView.insertText(text)
        
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
    
    // MARK: 字体、图片
    ///图片大小
    @objc func segmentedControlChanged(_ sender:UISegmentedControl){
        tempImageSizeStyle = sender.selectedSegmentIndex
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
    
    /// 选取日记字体
    @objc func presentFontPickerVC(){
        self.selecedFontButton = .diary
        let fontConfig = UIFontPickerViewController.Configuration()
        fontConfig.includeFaces = true//选取字体族下的不同字体
        let fontPicker = UIFontPickerViewController(configuration: fontConfig)
        fontPicker.delegate = self
        self.present(fontPicker, animated: true, completion: nil)
    }
    /// 选取主页字体
    @objc func presentCellFontPickerVC(){
        self.selecedFontButton = .monthCell
        let fontConfig = UIFontPickerViewController.Configuration()
        fontConfig.includeFaces = true//选取字体族下的不同字体
        let fontPicker = UIFontPickerViewController(configuration: fontConfig)
        fontPicker.delegate = self
        self.present(fontPicker, animated: true, completion: nil)
    }
    
    @objc func showCellFontTips(){
        let vc = LWTipsViewController(cardViewHeight: 200, cardTitle: "主页字体设置说明",content: cellFontTipText)
        self.present(vc, animated: true, completion: nil)
    }
    
    func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
        if let descriptor = viewController.selectedFontDescriptor,let selecedFontButton = self.selecedFontButton{
            print(descriptor.fontAttributes)
            let selectedFont = UIFont(descriptor: descriptor, size: 20)
            let selectedFontName = selectedFont.fontName
            
            //更新示例
            tempFontName = selectedFontName
            self.updateExampleTextView(withFontSize: tempFontSize, withFontStyle: tempFontName, withLineSpacing: tempLineSpacing)
            
            //打分
            if userDefaultManager.requestReviewTimes % 2 == 0{
                SKStoreReviewController.requestReview()
                userDefaultManager.requestReviewTimes += 1
            }
            
            if selecedFontButton == .diary{
                userDefaultManager.fontSize = tempFontSize
                userDefaultManager.fontName = tempFontName
                fontPickerButton.updateFontLabel()
            }else{
                userDefaultManager.monthCellFontName = tempFontName
                cellFontPickerButton.updateFontLabel()
            }
            
        }
        viewController.dismiss(animated: true)
    }
    
    
   
    
    //MARK: -密码
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
    
    //MARK: -iCloud
    @objc func iCloudDidChange(_ sender:UISwitch){
        userDefaultManager.iCloudEnable = sender.isOn
        if sender.isOn == true{
            //恢复iCloud：1.上传本地数据，2.下载远程数据
            indicatorViewManager.shared.start(type: .recover)
            DiaryStore.shared.startEngine()
        }
    }
    
    //MARK: -导出
    @objc func showExportVC(){
        let vc = exportSettingViewController()
        vc.transitioningDelegate = vc
        vc.modalPresentationStyle = .custom//模态
        self.present(vc, animated: true, completion: nil)
    }
    
    //MARK: -请求好评
    @objc func requestReview(){
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1564045149?action=write-review"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    //MARK: -切换深色模式
    @objc func appearanceModeDidChange(_ sender:UISegmentedControl){
        // 实际项目中，如果是iOS应用这么写没问题，但是对于iPadOS应用还需要判断scene的状态是否激活
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
            userDefaultManager.appearanceMode = 2
        }
        userDefaultManager.appearanceMode = sender.selectedSegmentIndex
        #endif
    }
    
    //MARK: - 主页todo列表样式
    @objc func todoListStyleDidChange(_ sender:UISegmentedControl){
        userDefaultManager.todoListViewStyle = sender.selectedSegmentIndex
    }
    
    //MARK: - 管理模板
    @objc func templateCellDidTap(){
        let vc = LWTemplateViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: -显示农历
    @objc func showLunarDidChange(_ sender: UISwitch){
        userDefaultManager.showLunar = sender.isOn
        UIApplication.getMonthVC()?.topbarView.dateView.reloadData()
    }

    
    //MARK: -每日提醒
    @objc func dailyReminderDidChange(_ sender: UISwitch){
        //一、开启每日提醒功能
        if sender.isOn{
            LWNotificationHelper.shared.checkNotificationAuthorization {
                // requestdeniedAction
                // 关掉开关
                DispatchQueue.main.async {
                    sender.setOn(false, animated: true)
                }
            } requestGrantedAction: {
                // requestGrantedAction
                let dict = LWNotificationHelper.generateDailyRemindInfoDict()
                LWNotificationHelper.shared.registerNotification(from: dict)
                userDefaultManager.dailyRemindEnable = true
            }
        }
        
        
        //二、关闭每日提醒功能
        if sender.isOn == false{
            LWNotificationHelper.shared.unregisterNotification(uuids: [userDefaultManager.TodoNotificationCategoryName])
            userDefaultManager.dailyRemindEnable = false
        }
        
        userDefaultManager.dailyRemindEnable = sender.isOn
    }
    
    @objc func autoCreateDiary(_ sender:UISwitch){
        userDefaultManager.autoCreate = sender.isOn
    }
    
    @objc func dateDidChange(_ picker:UIDatePicker){
        userDefaultManager.dailyRemindTimeDate = picker.date
        if dailyRemindSwitch.isOn{
            //重新注册新的时间通知提醒
            let dict = LWNotificationHelper.generateDailyRemindInfoDict()
            LWNotificationHelper.shared.registerNotification(from: dict)
        }
    }
    
    func richTextDidClicked(_ result: ASAttributedString.Action.Result) {
        switch result.content {
        case .string(let value):
            let text = value.string
            if text.contains("@"){
                UIPasteboard.general.string = "norwa99@163.com"
            }else if text.contains("n0rway99"){
                UIPasteboard.general.string = "n0rway99"
            }
            
        case .attachment(let _):
            return
        }
        
        
    }
}


// MARK:  - 联系我
extension LWSettingViewController{
    @objc func jumpToWeibo(){
        let weiboUrl = URL(string: "sinaweibo://userinfo?uid=6394154593")
        if let url = weiboUrl, UIApplication.shared.canOpenURL(url){
            // 微博客户端
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }else if let weiboInternalUrl = URL(string: "weibointernational://userinfo?uid=6394154593"),UIApplication.shared.canOpenURL(weiboInternalUrl){
            // 微博国际版客户端
            UIApplication.shared.open(weiboInternalUrl, options: [:], completionHandler: nil)
        }else if let website = URL(string: "https://weibo.com/u/6394154593"),UIApplication.shared.canOpenURL(website){
            // 都没有安装则打开网页
            UIApplication.shared.open(website, options: [:], completionHandler: nil)
        }
    }
    
    @objc func openMail(){
        let email = "norwa99@163.com"
        if let url = URL(string: "mailto:\(email)"),UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func joinUserGroup(){
        let vc = joinUserGroupController()
        self.present(vc, animated: true, completion: nil)
    }
}
extension LWSettingViewController:UIFontPickerViewControllerDelegate{
    
}
