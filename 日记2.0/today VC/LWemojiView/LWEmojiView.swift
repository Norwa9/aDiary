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
    ///最大展示的emoji个数
    let maxNum:Int = 4
    
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
        self.layer.cornerRadius = 5
        self.backgroundColor = .systemGray6
        
        //textField
        let layout = UICollectionViewFlowLayout()
        let inset:CGFloat = 2
        let itemWidth = (kEmojiViewHeight - 2 * inset) / 2
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        emojiCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        emojiCollection.register(LWEmojiCell.self, forCellWithReuseIdentifier: LWEmojiCell.reuseId)
        emojiCollection.contentInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
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
            .springDamping(0.9),
          ] as [PopoverOption]
        popover = Popover(options: options)
        
        //emojiView keyboard
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
//MARK:-helper
    
    func push(with emoji:String){
        guard emojis.count < maxNum  else {return}
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
        let viewSize = CGSize(width: 300, height:300 )
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
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.item == emojis.count - 1 else {return}
        cell.transform = .init(translationX: 0, y: 40)
        cell.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseInOut]) {
            cell.transform = .identity
            cell.alpha = 1
        } completion: { (_) in
            
        }

    }
}

