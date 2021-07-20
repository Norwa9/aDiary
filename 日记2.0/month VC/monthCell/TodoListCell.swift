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
        
        //containerView
        contentView.addSubview(containerView)
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 4
        
        //checkButton
        containerView.addSubview(checkButton)
        checkButton.setImage(UIImage(named: "checkbox_empty"), for: .normal)
        checkButton.setImage(UIImage(named: "checkbox"), for: .selected)
        checkButton.addTarget(self, action: #selector(checkButtonTapped(_:)), for: .touchUpInside)
        
        //contentLabel
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
            make.right.equalTo(containerView).offset(-5)
            make.height.equalTo(30)
            make.centerY.equalTo(checkButton)
        }
    }
    
    
    func fillData(todo:String){
        self.updateCons()
        
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
        
        self.contentLabel.text = self.todo.replacingOccurrences(of: "- [ ] ", with: "").replacingOccurrences(of: "- [x] ", with: "")
        
    }
    
    func updateCons(){
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
    
    
}

//MARK:-Target Action
extension TodoListCell{
    @objc func checkButtonTapped(_ sender:UIButton){
        sender.isSelected.toggle()
        
        guard let aString = self.contentLabel.attributedText else{return}
        
        
        if sender.isSelected{
            //完成
            self.contentLabel.attributedText = aString.addStrikethroughStyle()
        }else{
            //未完成
            self.contentLabel.attributedText = aString.removeStrikethroughStyle()
        }
        delegate?.todoDidCheck(todo: self.todo)
    }
}
