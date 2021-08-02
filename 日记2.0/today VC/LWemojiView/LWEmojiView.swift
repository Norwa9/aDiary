//
//  LWEmojiView.swift
//  日记2.0
//
//  Created by yy on 2021/7/22.
//

import UIKit
import ISEmojiView
import Popover
///emoji的大小。是LWEmojiView的高度的一半
let kEmojiItemWidth = kEmojiViewHeight
class LWEmojiView: UIView {
    var model:diaryInfo!{
        didSet{
            setModel()
        }
    }
    
    ///最大展示的emoji个数
    let maxNum:Int = 8
    
    
    
    var emojis:[String] = []
    var collectionView:UICollectionView!
    var emojiPanel:EmojiView!
    var popover:Popover!
    init() {
        super.init(frame: .zero)
        initUI()
        setupCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setModel(){
        updateUI()
    }
    
    private func updateUI(){
        self.emojis = model.emojis
        collectionView.reloadData()
    }
    
    private func initUI(){
        //self
        self.layer.cornerRadius = 5
        self.backgroundColor = .white
        
        //textField
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: kEmojiItemWidth, height: kEmojiItemWidth)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(LWEmojiCell.self, forCellWithReuseIdentifier: LWEmojiCell.reuseId)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        
        //gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showEmojiPanel))
        collectionView.addGestureRecognizer(tapGesture)
        
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

        self.addSubview(collectionView)
        
    }
    
    //MARK:-auto layout
    private func setupCons(){
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
//        updateView(num: emojis.count)//设置正确的宽度
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
//MARK:-helper
    
    func push(with emoji:String){
        guard emojis.count < maxNum  else {return}
        emojis.append(emoji)
        LWRealmManager.shared.update {
            model.emojis = emojis
        }
        collectionView.reloadData()
        updateView(num: emojis.count)
    }
    
    func pop(){
        guard !emojis.isEmpty else {return}
        emojis.removeLast()
        LWRealmManager.shared.update {
            model.emojis = emojis
        }
        collectionView.reloadData()
        updateView(num: emojis.count)
    }
    
    private func updateView(num:Int){
//        let contentWidth = max(kEmojiViewWidth, ceil(CGFloat(num) / 2) * kEmojiItemWidth)
//        print("contentWidth:\(contentWidth)")
//        self.snp.updateConstraints { (update) in
//            update.width.equalTo(contentWidth)
//        }
//        UIView.animate(withDuration: 0.5) {
//            self.layoutIfNeeded()
//        }
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
        popover.show(container, fromView: collectionView)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LWEmojiCell.reuseId, for: indexPath) as! LWEmojiCell
        
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

