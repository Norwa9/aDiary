//
//  LWEmojiView.swift
//  日记2.0
//
//  Created by yy on 2021/7/22.
//

import UIKit
import ISEmojiView

class LWEmojiView: UIView {
    var stack:[String] = []
    var textField:UITextField!
    var emojiPan:EmojiView!
    init() {
        super.init(frame: .zero)
        initUI()
        setupCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        //self
        self.layer.cornerRadius = 10
        self.backgroundColor = APP_GRAY_COLOR()
        
        //textField
        textField = UITextField()
        textField.placeholder = "😁"
        
        //emojiView
        let keyboardSettings = KeyboardSettings(bottomType: .categories)
        emojiPan = EmojiView(keyboardSettings: keyboardSettings)
        emojiPan.translatesAutoresizingMaskIntoConstraints = false
        emojiPan.delegate = self
        textField.inputView = emojiPan

        self.addSubview(textField)
    }
    
    func setupCons(){
        textField.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func add(emoji:String){
        
    }
    
    
}
//MARK:-EmojiViewDelegate
extension LWEmojiView:EmojiViewDelegate{
    func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
        textField.insertText(emoji)
    }
    // callback when tap change keyboard button on keyboard
    func emojiViewDidPressChangeKeyboardButton(_ emojiView: EmojiView) {
        textField.inputView = nil
        textField.keyboardType = .default
        textField.reloadInputViews()
    }
        
    // callback when tap delete button on keyboard
    func emojiViewDidPressDeleteBackwardButton(_ emojiView: EmojiView) {
        textField.deleteBackward()
    }

    // callback when tap dismiss button on keyboard
    func emojiViewDidPressDismissKeyboardButton(_ emojiView: EmojiView) {
        textField.resignFirstResponder()
    }
}


