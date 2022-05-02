//
//  todoListCell.swift
//  日记2.0
//
//  Created by yy on 2021/7/19.
//

import UIKit

class TodoListCell: UICollectionViewCell {
    static let cellId = "todoListCell"
    
    var lwTodoView:LWTodoView!
    
    var viewModel:LWTodoViewModel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setViewModel(_ viewModel:LWTodoViewModel){
        self.viewModel = viewModel
        self.initUI()
        self.setupConstraint()
    }
    
    private func initUI(){
        lwTodoView = LWTodoView(viewModel: self.viewModel)
        self.addSubview(lwTodoView)
    }
    
    private func setupConstraint(){
        lwTodoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(layoutParasManager.shared.todoListItemWidth)
        }
    }
    
    
    func updateUI(){
        self.updateCons()
    }
    
    private func updateCons(){
        let curWidth = layoutParasManager.shared.todoListItemWidth
        self.lwTodoView.snp.updateConstraints { (make) in
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
        self.lwTodoView.removeFromSuperview() // 释放lwTodoView的内存
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
