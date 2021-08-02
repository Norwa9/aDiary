//
//  LWEmojiCell.swift
//  日记2.0
//
//  Created by yy on 2021/7/22.
//

import UIKit

class LWEmojiCell: UICollectionViewCell {
    static let reuseId = "LWEmojiCell"
    
    private var emojiLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        //contentView
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
        
        //emojiLabel
        emojiLabel = UILabel()
        emojiLabel.font = UIFont(name: "Apple color emoji", size: 20)
        emojiLabel.adjustsFontSizeToFitWidth = true
        emojiLabel.textAlignment = .center
        emojiLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(emojiLabel)
    }
    
    func setupConstraints(){
        emojiLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setEmoji(_ emoji:String){
        emojiLabel.text = emoji
    }
}
