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
    
    // 富文本
    var richTextPanelButton:LWToolBarButton!
    var boldButton:LWToolBarButton!
    var italicButton:LWToolBarButton!
    var underLineButton:LWToolBarButton!
    var aligmentButton:LWToolBarButton!
    var fontSizeButton:LWToolBarButton!
    var fontColorButton:LWToolBarButton!
    
    // 普通按钮
    var insertTimeButton:LWToolBarButton!
    var insertImageButton:LWToolBarButton!
    var numberListButton:LWToolBarButton!
    var todoListButton:LWToolBarButton!
    var indicator:NVActivityIndicatorView!
    
    // undo/redo按钮
    var undoButton:LWToolBarButton!
    var redoButton:LWToolBarButton!
    
    // 保存按钮
    var saveButton:LWToolBarButton!
    
    
    // 按钮组合
    var basicButtons:[LWToolBarButton] = []
    var richTextbuttons:[LWToolBarButton] = []
    var isShowingRichButtonsPanel:Bool = false
    
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
        initBasicButtons()
        initBasicButtonsCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func reloadTextViewToolBar(type:Int){
        UIView.animate(withDuration: 0.2) {
            if type == 0{ // textView
                self.alpha = 1
            }else if type == 1{ // todo
                self.alpha = 0
            }
        }
       
    }
        
    
    //tool bar
    private func initBasicButtons(){
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
       
        
        // undo
        undoButton = LWToolBarButton(image: UIImage(named: "undo"),inset: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        undoButton.addTarget(self, action: #selector(undoButtonTapped), for: .touchUpInside)
        self.addSubview(undoButton)
        
        // redo
        redoButton = LWToolBarButton(image: UIImage(named: "redo"),inset: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        redoButton.addTarget(self, action: #selector(redoButtonTapped), for: .touchUpInside)
        self.addSubview(redoButton)
        
        //5 save
        saveButton = LWToolBarButton(image: UIImage(named: "done"),inset: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        self.addSubview(saveButton)
        
        
        //6,富文本开关
        richTextPanelButton = LWToolBarButton(image: UIImage(named: "richtext"))
        richTextPanelButton.addTarget(self, action: #selector(showRichButtonPanel(_:)), for: .touchUpInside)
        self.addSubview(richTextPanelButton)
        
        indicator = NVActivityIndicatorView(frame: .zero, type: .lineSpinFadeLoader, color: .lightGray, padding: .zero)
        indicator.color = UIColor.gray
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
        
        fontColorButton = LWToolBarButton(image: UIImage(named: "fontcolor"))
        fontColorButton.addTarget(self, action: #selector(setFontColor(_:)), for: .touchUpInside)
        self.addSubview(fontColorButton)
        
        fontSizeButton = LWToolBarButton(image: UIImage(named: "fontsize"))
        fontSizeButton.addTarget(self, action: #selector(setFontSize(_:)), for: .touchUpInside)
        self.addSubview(fontSizeButton)
        
        
        
        basicButtons = [insertTimeButton,insertImageButton,todoListButton,numberListButton,undoButton,redoButton]
        richTextbuttons = [boldButton,italicButton,underLineButton,aligmentButton,fontColorButton,fontSizeButton]
        self.initRichTextButtonsCons()
        for button in richTextbuttons{
            button.alpha = 0
        }
    }
    
    private func initBasicButtonsCons(){
        richTextPanelButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        insertTimeButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(richTextPanelButton)
            make.left.equalTo(richTextPanelButton.snp.right).offset(10)
            make.size.equalTo(richTextPanelButton)
        }
        
        todoListButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(insertTimeButton)
            make.left.equalTo(insertTimeButton.snp.right).offset(10)
            make.size.equalTo(insertTimeButton)
        }
        
        numberListButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(insertTimeButton)
            make.left.equalTo(todoListButton.snp.right).offset(10)
            make.size.equalTo(insertTimeButton)
        }
        
        insertImageButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(insertTimeButton)
            make.left.equalTo(numberListButton.snp.right).offset(10)
            make.size.equalTo(insertTimeButton)
        }
        
        undoButton.snp.makeConstraints { make in
            make.centerY.equalTo(saveButton)
            make.right.equalTo(redoButton.snp.left).offset(-10)
            make.size.equalTo(insertTimeButton)
        }
        
        redoButton.snp.makeConstraints { make in
            make.centerY.equalTo(saveButton)
            make.right.equalTo(saveButton.snp.left).offset(-10)
            make.size.equalTo(insertTimeButton)
        }
        
        saveButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 50, height: 30))
        }
        
        indicator.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        }
    }
    
    private func initRichTextButtonsCons(){
        boldButton.snp.makeConstraints { (make) in
            make.edges.equalTo(insertTimeButton)
        }
        
        italicButton.snp.makeConstraints { (make) in
            make.edges.equalTo(todoListButton)
        }
        
        underLineButton.snp.makeConstraints { (make) in
            make.edges.equalTo(numberListButton)
        }
        
        aligmentButton.snp.makeConstraints { (make) in
            make.edges.equalTo(insertImageButton)
        }
        
        fontColorButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(aligmentButton)
            make.left.equalTo(aligmentButton.snp.right).offset(10)
            make.size.equalTo(aligmentButton)
        }
        
        fontSizeButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(aligmentButton)
            make.left.equalTo(fontColorButton.snp.right).offset(10)
            make.size.equalTo(aligmentButton)
        }
    }
}

//MARK:-action target
extension LWTextViewToolBar:UIColorPickerViewControllerDelegate{
    @objc func showRichButtonPanel(_ sender:LWToolBarButton){
        updateToolbarButtonsState(textView: textView)
        
        isShowingRichButtonsPanel.toggle()
        if isShowingRichButtonsPanel{
            UIView.animate(withDuration: 0.2) {
                sender.buttonImageView.image = UIImage(named: "back")
                for button in self.richTextbuttons{
                    button.alpha = 1
                }
                for button in self.basicButtons{
                    button.alpha = 0
                }
            }
            
        }else{
            UIView.animate(withDuration: 0.2) {
                sender.buttonImageView.image = UIImage(named: "richtext")
                for button in self.richTextbuttons{
                    button.alpha = 0
                }
                for button in self.basicButtons{
                    button.alpha = 1
                }
            }
            
        }
    }
    
    @objc func undoButtonTapped(){
        guard let textView = textView, let undoManager = textView.undoManager else{return}
        undoManager.undo()
    }
    
    @objc func redoButtonTapped(){
        guard let textView = textView, let undoManager = textView.undoManager else{return}
        
        undoManager.redo()
    }
    
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
            if #available(iOS 14.0, *) {
                let colorPickerVC = UIColorPickerViewController()
                colorPickerVC.delegate = self
                let textFormatter = TextFormatter(textView: textView)
                let curFontColor = textFormatter.getSelectedFontColor()
                colorPickerVC.selectedColor = curFontColor
                colorPickerVC.undoManager?.disableUndoRegistration()
                UIApplication.getTodayVC()?.present(colorPickerVC, animated: true, completion: nil)
            } else {
                let colorPicker = ColorPicker()
                colorPicker.set(color: .white, colorSpace: .sRGB)
                colorPicker.frame = CGRect(origin: .zero, size: CGSize(width: 300, height: 200))
                colorPicker.addTarget(self, action: #selector(handleColorChange(picker:)), for: .valueChanged)
                popover.show(colorPicker, fromView: sender)
            }
            
        }else{
            popover.dismiss()
        }
    }
    
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    @available(iOS 14.0, *)
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        let textFormatter = TextFormatter(textView: textView)
        textFormatter.changeFontColor(newColor: color)
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
        }else{
            popover.dismiss()
        }
        
    }
    
    func handleFontSizeChange(newFontSize:CGFloat){
        let textFormatter = TextFormatter(textView: textView)
        textFormatter.changeFontSize(newFontSize: newFontSize)
    }
    
    
    func updateToolbarButtonsState(textView:LWTextView){
        var attributes:[NSAttributedString.Key : Any]
        let textFormatter = TextFormatter(textView: textView )
        let selectedRange = textView.selectedRange
        if selectedRange.length > 0{
            let subAttributedString = textView.attributedText.attributedSubstring(from: selectedRange)
            attributes = subAttributedString.attributes(at: 0, effectiveRange: nil)
        }else{
            attributes = textFormatter.getLocationAttributes()
        }
        
        
        boldButton.isOn = false
        italicButton.isOn = false
        underLineButton.isOn = false
        
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
