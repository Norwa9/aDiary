//
//  LWEmojiView.swift
//  日记2.0
//
//  Created by yy on 2021/7/22.
//

import UIKit
import ISEmojiView
import Popover

class LWEmojiView: UIView {
    var diary:diaryInfo
    var emojis:[String]
    var emojiCollection:UICollectionView!
    var emojiPanel:EmojiView!
    var popover:Popover!
    init(model:diaryInfo) {
        self.diary = model
        self.emojis = model.emojis
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
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.scrollDirection = .horizontal
        emojiCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        emojiCollection.register(LWEmojiCell.self, forCellWithReuseIdentifier: LWEmojiCell.reuseId)
        emojiCollection.delegate = self
        emojiCollection.dataSource = self
        emojiCollection.isScrollEnabled = false
        emojiCollection.showsHorizontalScrollIndicator = false
        emojiCollection.backgroundColor = .clear
        
        //gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showEmojiPanel))
        emojiCollection.addGestureRecognizer(tapGesture)
        
        //popover
        let options = [
            .type(.auto),
            .cornerRadius(10),
          .animationIn(0.3),
            .arrowSize(CGSize(width: 5, height: 5)),
            .springDamping(0.7),
          ] as [PopoverOption]
        popover = Popover(options: options)
        
        //emojiView
        let keyboardSettings = KeyboardSettings(bottomType: .categories)
        keyboardSettings.countOfRecentsEmojis = 10
        emojiPanel = EmojiView(keyboardSettings: keyboardSettings)
        emojiPanel.translatesAutoresizingMaskIntoConstraints = false
        emojiPanel.delegate = self

        self.addSubview(emojiCollection)
    }
    
    func setupCons(){
        emojiCollection.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func push(with emoji:String){
        emojis.append(emoji)
        LWRealmManager.shared.update {
            diary.emojis = emojis
        }
        emojiCollection.reloadData()
    }
    
    func pop(){
        guard !emojis.isEmpty else {return}
        emojis.removeLast()
        LWRealmManager.shared.update {
            diary.emojis = emojis
        }
        emojiCollection.reloadData()
    }
    
    
}
//MARK:-target action
extension LWEmojiView{
    @objc func showEmojiPanel(){
        let viewSize = CGSize(width: 400, height:300 )
        let container = UIView(frame: CGRect(origin: .zero, size: viewSize))
        container.addSubview(emojiPanel)
        emojiPanel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        popover.show(container, fromView: emojiCollection)
    }
}


//MARK:-EmojiViewDelegate
extension LWEmojiView:EmojiViewDelegate{
    func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
        self.push(with: emoji)
        
    }
        
    // callback when tap delete button on keyboard
    func emojiViewDidPressDeleteBackwardButton(_ emojiView: EmojiView) {
        self.pop()
    }
}

//MARK:-UICollectionViewDataSource
extension LWEmojiView:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = emojiCollection.dequeueReusableCell(withReuseIdentifier: LWEmojiCell.reuseId, for: indexPath) as! LWEmojiCell
        
        let item = indexPath.item
        cell.setEmoji(emojis[item])
        
        return cell
    }
    

}
//MARK:-UICollectionViewDelegate
extension LWEmojiView:UICollectionViewDelegate{

}

