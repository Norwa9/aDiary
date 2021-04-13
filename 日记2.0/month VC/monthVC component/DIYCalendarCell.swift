//
//  DIYCalendarCell.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/5.
//

import UIKit
import FSCalendar

enum  SelectionType: Int {
    case none//未选取
    case single//选取
}

class DIYCalendarCell: FSCalendarCell {
    var date:Date!
    var bgView:UIView!
    weak var selectionLayer: CAShapeLayer!
    
    var selectionType:SelectionType = .none {
        didSet{
            setNeedsLayout()
        }
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init!(frame: CGRect) {
        super.init(frame: frame)
        
        //设置cell的灰色圆角矩形背景
        bgView = UIView(frame: self.bounds)
        bgView.layer.cornerRadius = 7
        self.backgroundView = bgView
        
        //设置新的cell选取效果：绿色圆环
        self.shapeLayer.isHidden = true
        let selectionLayer = CAShapeLayer()
        selectionLayer.fillColor = UIColor.clear.cgColor
        selectionLayer.strokeColor = APP_GREEN_COLOR().cgColor
        selectionLayer.lineWidth = 3.0
        self.contentView.layer.insertSublayer(selectionLayer, below: self.titleLabel!.layer)
        self.selectionLayer = selectionLayer
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //1,设置cell的背景颜色，如果是未来的cell，不设置背景颜色
        if date.compare(Date()) == .orderedDescending{
            self.clearBGColor()
        }else{
            bgView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.12)
        }
        
        //2,绘制点选圆环view
        self.backgroundView?.frame = self.bounds.insetBy(dx: 2, dy: 1)
        self.selectionLayer.frame = self.backgroundView!.bounds
        
        
        switch selectionType {
        case .single:
            let diameter: CGFloat = min(self.contentView.frame.width, self.contentView.frame.height)
            let square = CGRect(
                x: self.contentView.frame.width / 2 - diameter / 2,
                y: self.contentView.frame.height / 2 - diameter / 2,
                width: diameter,
                height: diameter)
            let cyclePath = UIBezierPath(ovalIn: square.insetBy(dx: 5, dy: 5))
            self.selectionLayer.path = cyclePath.cgPath
        default:
            //.none
            return
        }
        
    }
    
    //MARK:-
    func clearBGColor(){
        bgView.backgroundColor = .clear
    }
    
    
    
    
}
