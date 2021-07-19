//
//  todoListCell.swift
//  日记2.0
//
//  Created by yy on 2021/7/19.
//

import UIKit

class TodoListCell: UICollectionViewCell {
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
        contentView.setDebugBorder()
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(checkButton)
        
        
        containerView.addSubview(contentLabel)
    }
    
    private func setupConstraint(){
        containerView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
            make.width.equalTo(layoutParasManager.shared.todoListItemWidth)
        }
        
        checkButton.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(5)
            make.top.equalTo(containerView).offset(5)
            make.bottom.equalTo(containerView).offset(-5)
            make.width.equalTo(10)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(checkButton.snp.right).offset(5)
            make.right.equalTo(containerView).offset(-5)
            make.top.equalTo(checkButton)
            make.bottom.equalTo(checkButton)
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
        self.contentLabel.text = self.todo
        self.checkButton.backgroundColor = isDone ? .red : .blue
    }
    
    func updateCons(){
        let curWidth = layoutParasManager.shared.todoListItemWidth
        self.containerView.snp.updateConstraints { (make) in
            make.width.equalTo(curWidth)
        }
        print("[TodoListCell]:\(curWidth)")
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    
}
