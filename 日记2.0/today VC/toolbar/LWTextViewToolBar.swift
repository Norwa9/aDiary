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
    var buttons:[LWToolBarButton] = []
    
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
        
        richTextButton = LWToolBarButton(image: UIImage(named: "richText"))
        richTextButton.addTarget(self, action: #selector(UnfoldRichtextMenu), for: .touchUpInside)
        self.addSubview(richTextButton)
        
        buttons = [insertImageButton,todoListButton,numberListButton,saveButton]
    }
    
    private func initCons(){
        insertTimeButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 30, height: 30))
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
        
        richTextButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(insertTimeButton)
            make.left.equalTo(insertImageButton.snp.right).offset(10)
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
    
    @objc func UnfoldRichtextMenu(){
        if !isShowingPopover{
            let colorPicker = ColorPicker()
            colorPicker.set(color: .white, colorSpace: .sRGB)
            colorPicker.frame = CGRect(origin: .zero, size: CGSize(width: 300, height: 200))
            colorPicker.addTarget(self, action: #selector(handleColorChange(picker:)), for: .valueChanged)
            popover.show(colorPicker, fromView: richTextButton)
        }else{
            popover.dismiss()
        }
//        let textFormatter = TextFormatter(textView: textView)
//        if !isShowingPopover{
//            let slider = UISlider()
//            slider.addTarget(self, action: #selector(handleFontSizeChange(picker:)), for: .valueChanged)
//            slider.minimumValue = 5
//            slider.maximumValue = 100
//            slider.width = 200
//            slider.setValue(Float(textFormatter.getSelectedFontSize()), animated: false)
//            popover.show(slider, fromView: richTextButton)
//            isShowingPopover = true
//        }else{
//            popover.dismiss()
//            isShowingPopover = false
//        }
        
    }
    
    @objc func handleFontSizeChange(picker:UISlider){
        let newFontSize = picker.value
        let textFormatter = TextFormatter(textView: textView)
        textFormatter.changeFontSize(newFontSize: CGFloat(newFontSize))
    }
    
    @objc func handleColorChange(picker:ColorPicker){
        let newColor = picker.color
        let textFormatter = TextFormatter(textView: textView)
        textFormatter.changeFontColor(newColor: newColor)
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
