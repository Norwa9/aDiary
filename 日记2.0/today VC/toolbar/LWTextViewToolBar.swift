//
//  LWTextViewToolBar.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/30.
//

import UIKit
import NVActivityIndicatorView
import Popover
import Colorful

protocol LWPhotoPickerDelegate : NSObject {
    func showPhotoPicker()
}

class LWTextViewToolBar: UIView {
    weak var delegate:LWPhotoPickerDelegate?
    weak var textView:LWTextView!
    var saveButton:LWToolBarButton!
    var insertTimeButton:LWToolBarButton!
    var insertImageButton:LWToolBarButton!
    var numberListButton:LWToolBarButton!
    var todoListButton:LWToolBarButton!
    var indicator:NVActivityIndicatorView!
    var richTextButton:LWToolBarButton!
    var boldButton:LWToolBarButton!
    var italicButton:LWToolBarButton!
    var underLineButton:LWToolBarButton!
    var aligmentButton:LWToolBarButton!
    var fontSizeButton:LWToolBarButton!
    var fontColorButton:LWToolBarButton!
    
    var buttons:[LWToolBarButton] = []
    var richTextbuttons:[LWToolBarButton] = []
    
    var isShowingPopover:Bool = false
    
    lazy var popover:Popover = {
        let options = [
            .type(.up),
            .cornerRadius(10),
          .animationIn(0.3),
            .arrowSize(CGSize(width: 5, height: 5)),
            .springDamping(0.7),
          ] as [PopoverOption]
        let popover = Popover(options: options,
                              showHandler: {self.isShowingPopover = true},
                              dismissHandler: {self.isShowingPopover = false})
        return popover
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        initCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //tool bar
    private func initUI(){
        self.backgroundColor = .secondarySystemBackground
        
        //1 add time button
        insertTimeButton = LWToolBarButton(image: UIImage(named: "clock"))
        insertTimeButton.addTarget(self, action: #selector(insertTimeToTextView), for: .touchUpInside)
        self.addSubview(insertTimeButton)
        
        //2 todo list button
        todoListButton = LWToolBarButton(image: UIImage(named: "checkbox_empty"))
        todoListButton.addTarget(self, action: #selector(insertTodoList), for: .touchUpInside)
        self.addSubview(todoListButton)
        
        //3 create number list
        numberListButton = LWToolBarButton(image: UIImage(named: "numberList"))
        numberListButton.addTarget(self, action: #selector(insertNumberList), for: .touchUpInside)
        self.addSubview(numberListButton)
        
        //4 insert picture button
        insertImageButton = LWToolBarButton(image: UIImage(named: "insertPicture"))
        insertImageButton.addTarget(self, action: #selector(insertImageToTextView), for: .touchUpInside)
        self.addSubview(insertImageButton)
       
        
        //5 save
        saveButton = LWToolBarButton(image: UIImage(named: "done"))
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        self.addSubview(saveButton)
        
        indicator = NVActivityIndicatorView(frame: .zero, type: .lineSpinFadeLoader, color: .lightGray, padding: .zero)
        indicator.alpha = 0
        saveButton.addSubview(indicator)
        
        boldButton = LWToolBarButton(image: UIImage(named: "bold"))
        boldButton.addTarget(self, action: #selector(setBold(_:)), for: .touchUpInside)
        self.addSubview(boldButton)
        
        italicButton = LWToolBarButton(image: UIImage(named: "Italic"))
        italicButton.addTarget(self, action: #selector(setItalic(_:)), for: .touchUpInside)
        self.addSubview(italicButton)
        
        underLineButton = LWToolBarButton(image: UIImage(named: "underline"))
        underLineButton.addTarget(self, action: #selector(setUnderLine(_:)), for: .touchUpInside)
        self.addSubview(underLineButton)
        
        aligmentButton = LWToolBarButton(image: UIImage(named: "leftaligment"))
        aligmentButton.addTarget(self, action: #selector(setAligment(_:)), for: .touchUpInside)
        self.addSubview(aligmentButton)
        
        fontSizeButton = LWToolBarButton(image: UIImage(named: "fontsize"))
        fontSizeButton.addTarget(self, action: #selector(setFontSize(_:)), for: .touchUpInside)
        self.addSubview(fontSizeButton)
        
        fontColorButton = LWToolBarButton(image: UIImage(named: "fontcolor"))
        fontColorButton.addTarget(self, action: #selector(setFontColor(_:)), for: .touchUpInside)
        self.addSubview(fontColorButton)
        
        
        
        buttons = [insertImageButton,todoListButton,numberListButton,saveButton]
        richTextbuttons = [boldButton,italicButton,underLineButton]
    }
    
    private func initCons(){
        insertTimeButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(5)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        todoListButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(insertTimeButton)
            make.left.equalTo(insertTimeButton.snp.right).offset(5)
            make.size.equalTo(insertTimeButton)
        }
        
        numberListButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(insertTimeButton)
            make.left.equalTo(todoListButton.snp.right).offset(5)
            make.size.equalTo(insertTimeButton)
        }
        
        insertImageButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(insertTimeButton)
            make.left.equalTo(numberListButton.snp.right).offset(5)
            make.size.equalTo(insertTimeButton)
        }
        
        boldButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(insertTimeButton)
            make.left.equalTo(insertImageButton.snp.right).offset(5)
            make.size.equalTo(insertTimeButton)
        }
        
        italicButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(insertTimeButton)
            make.left.equalTo(boldButton.snp.right).offset(5)
            make.size.equalTo(insertTimeButton)
        }
        
        underLineButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(insertTimeButton)
            make.left.equalTo(italicButton.snp.right).offset(5)
            make.size.equalTo(insertTimeButton)
        }
        
        aligmentButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(insertTimeButton)
            make.left.equalTo(underLineButton.snp.right).offset(5)
            make.size.equalTo(insertTimeButton)
        }
        
        fontColorButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(insertTimeButton)
            make.left.equalTo(aligmentButton.snp.right).offset(5)
            make.size.equalTo(insertTimeButton)
        }
        
        fontSizeButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(insertTimeButton)
            make.left.equalTo(fontColorButton.snp.right).offset(5)
            make.size.equalTo(insertTimeButton)
        }

        
        saveButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 50, height: 30))
        }
        
        indicator.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

//MARK:-action target
extension LWTextViewToolBar{
    
    @objc func saveButtonTapped(){
        self.statAnimateIndicator()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.stopAnimatreIndicator()
            self.textView.resignFirstResponder()
        }
        
    }
    
    @objc func insertTimeToTextView(){
        let textFormatter = TextFormatter(textView: textView)
        textFormatter.insertTimeTag()
    }
    
    @objc func insertImageToTextView(){
        delegate?.showPhotoPicker()
    }
    
    @objc func insertNumberList(){
        let textFormatter = TextFormatter(textView: textView)
        textFormatter.insertOrderedList()
    }
    
    @objc func insertTodoList(){
        let textFormatter = TextFormatter(textView: textView)
        textFormatter.insertTodoList()
    }
    
    @objc func setBold(_ sender:LWToolBarButton){
        let textFormatter = TextFormatter(textView: textView)
        textFormatter.toggleTrait(On: .bold)
        sender.isOn.toggle()
    }
    
    @objc func setItalic(_ sender:LWToolBarButton){
        let textFormatter = TextFormatter(textView: textView)
        textFormatter.toggleTrait(On: .italic)
        sender.isOn.toggle()
    }
    
    @objc func setUnderLine(_ sender:LWToolBarButton){
        let textFormatter = TextFormatter(textView: textView)
        textFormatter.toggleUnderLine()
        sender.isOn.toggle()
    }
    
    @objc func setAligment(_ sender:LWToolBarButton){
        let textFormatter = TextFormatter(textView: textView)
        let curAligment = textFormatter.getCurrentAligment()
        var setAligmentRawValue = curAligment.rawValue + 1
        if setAligmentRawValue > 2{
            setAligmentRawValue = 0
        }
        let imageName:String
        switch setAligmentRawValue {
        case 0:
            imageName = "leftaligment"
        case 1:
            imageName = "centeraligment"
        case 2:
            imageName = "rightaligment"
        default:
            imageName = "leftaligment"
        }
        sender.buttonImageView.image = UIImage(named: imageName)
        textFormatter.setParagraphAligment(aligment: LWTextAligmentStyle.init(rawValue: setAligmentRawValue)!)
    }
    
    @objc func setFontColor(_ sender:LWToolBarButton){
        if !isShowingPopover{
            let colorPicker = ColorPicker()
            colorPicker.set(color: .white, colorSpace: .sRGB)
            colorPicker.frame = CGRect(origin: .zero, size: CGSize(width: 300, height: 200))
            colorPicker.addTarget(self, action: #selector(handleColorChange(picker:)), for: .valueChanged)
            popover.show(colorPicker, fromView: sender)
        }else{
            popover.dismiss()
        }
    }
    
    @objc func handleColorChange(picker:ColorPicker){
        let newColor = picker.color
        let textFormatter = TextFormatter(textView: textView)
        textFormatter.changeFontColor(newColor: newColor)
    }
    
    @objc func setFontSize(_ sender:LWToolBarButton){
        let textFormatter = TextFormatter(textView: textView)
        if !isShowingPopover{
            let sliderView = LWFontSizeSliderView(toolbar: self)
            sliderView.size = CGSize(width: 240, height: 30)
            sliderView.defaultSize = textFormatter.getSelectedFontSize()
            popover.show(sliderView, fromView: sender)
            isShowingPopover = true
        }else{
            popover.dismiss()
            isShowingPopover = false
        }
        
    }
    
    func handleFontSizeChange(newFontSize:CGFloat){
        let textFormatter = TextFormatter(textView: textView)
        textFormatter.changeFontSize(newFontSize: newFontSize)
    }
    
    
    func updateToolbarButtonsState(attributes:[NSAttributedString.Key : Any]){
        print("updateToolbarButtonsState:\(attributes)")
        for button in richTextbuttons{
            button.isOn = false
        }
        for attribute in attributes{
            //1.粗体，斜体
            if let font = attribute.value as? UIFont{
                if font.fontDescriptor.symbolicTraits.contains(.traitBold){
                    boldButton.isOn = true
                }
                if font.fontDescriptor.symbolicTraits.contains(.traitItalic){
                    italicButton.isOn = true
                }
            }
            
            //2.下划线
            if attribute.key == .underlineStyle{
                underLineButton.isOn = true
            }
            
            //3.段落排版
            if attribute.key == .paragraphStyle{
                if let paraStyle = attribute.value as? NSParagraphStyle{
                    switch paraStyle.alignment {
                    case .left:
                        aligmentButton.buttonImageView.image = UIImage(named: "leftaligment")
                    case .center:
                        aligmentButton.buttonImageView.image = UIImage(named: "centeraligment")
                    case .right:
                        aligmentButton.buttonImageView.image = UIImage(named: "rightaligment")
                    default:
                        aligmentButton.buttonImageView.image = UIImage(named: "leftaligment")
                    }
                }
            }
        }
        
        
    }
    
}

//MARK:-indicator
extension LWTextViewToolBar{
    func statAnimateIndicator(){
        UIView.animate(withDuration: 0.1) {
            self.saveButton.buttonImageView.alpha = 0
            self.indicator.alpha = 1
        }
        self.indicator.startAnimating()
    }
    
    func stopAnimatreIndicator(){
        UIView.animate(withDuration: 0.1) {
            self.saveButton.buttonImageView.alpha = 1
            self.indicator.alpha = 0
        }
        self.indicator.stopAnimating()
    }
}
