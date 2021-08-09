//
//  todoListCell.swift
//  日记2.0
//
//  Created by yy on 2021/7/19.
//

import UIKit

class TodoListCell: UICollectionViewCell {
    weak var delegate:todoListDelegate?
    
    static let cellId = "todoListCell"
    let containerView = UIView()
    let checkButton:UIButton = UIButton()
    let contentLabel:UILabel = UILabel()
    private var isDone:Bool = false
    var todo:String!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI(){
        //contentView.setDebugBorder()
        self.backgroundColor = .tertiarySystemBackground
        
        //containerView
        contentView.addSubview(containerView)
        containerView.backgroundColor = .tertiarySystemBackground
        containerView.layer.cornerRadius = 4
        
        //checkButton
        containerView.addSubview(checkButton)
        checkButton.setImage(UIImage(named: "checkbox_empty"), for: .normal)
        checkButton.setImage(UIImage(named: "checkbox"), for: .selected)
        checkButton.addTarget(self, action: #selector(checkButtonTapped(_:)), for: .touchUpInside)
        
        //contentLabel
        contentLabel.font = UIFont(name: "DIN Alternate", size: 15)
        contentLabel.textColor = .label
        contentLabel.clipsToBounds = true
        containerView.addSubview(contentLabel)
        
    }
    
    private func setupConstraint(){
        containerView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
            make.width.equalTo(layoutParasManager.shared.todoListItemWidth)
        }
        
        checkButton.snp.makeConstraints { make in
            make.centerY.equalTo(containerView)
            make.left.equalTo(containerView).offset(5)
            make.height.equalTo(30)
            make.width.equalTo(30)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(checkButton.snp.right).offset(5)
            make.right.equalTo(containerView)
            make.height.equalTo(30)
            make.centerY.equalTo(checkButton)
        }
    }
    
    
    func fillData(todo:String){
        self.todo = todo
        
        if todo.hasPrefix("- [ ] "){
            isDone = false
        }
        else if todo.hasPrefix("- [x] "){
            isDone = true
        }
        else
        {
            isDone = false
        }
        
        self.updateUI()
    }
    
    func updateUI(){
        self.updateCons()
        
        
        let text = self.todo.replacingOccurrences(of: "- [ ] ", with: "").replacingOccurrences(of: "- [x] ", with: "")
        self.contentLabel.text = text
    }
    
    private func updateCons(){
        let curWidth = layoutParasManager.shared.todoListItemWidth
        self.containerView.snp.updateConstraints { (make) in
            make.width.equalTo(curWidth)
        }
        switch layoutParasManager.shared.collectioncolumnNumber {
        case 1:
            break
        case 2:
            break
        default:
            break
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.contentLabel.attributedText = nil
        self.checkButton.isSelected = false
        self.delegate = nil
    }
    
}

//MARK:-Target Action
extension TodoListCell{
    @objc func checkButtonTapped(_ sender:UIButton){
        sender.isSelected.toggle()
        self.bounceAnimation(usingSpringWithDamping: 0.9)
        guard let aString = self.contentLabel.attributedText else{return}
        
        let mutableAttrString = NSMutableAttributedString(attributedString: aString)
        let range = NSRange(location: 0, length: mutableAttrString.length)
        if sender.isSelected{
            //完成
            self.contentLabel.attributedText = mutableAttrString.addCheckAttribute(range: range)
        }else{
            //未完成
            self.contentLabel.attributedText = mutableAttrString.addUncheckAttribute(range: range)
        }
        delegate?.todoDidCheck(todo: self.todo)
    }
}


///渐变label
class GradientLabel: UILabel {

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        if let gradLayer =  layer as?  CAGradientLayer {
            gradLayer.colors = [UIColor.systemBackground.cgColor, APP_GRAY_COLOR().cgColor]
            gradLayer.startPoint = CGPoint(x:0,y:0.5)
            gradLayer.endPoint = CGPoint(x:1.0,y:0.5)
            gradLayer.locations = [0.7, 1.0];
            gradLayer.backgroundColor = UIColor.systemBackground.cgColor
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
