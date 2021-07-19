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
    
    weak var selectionLayer: CAShapeLayer!//选中视图：圆环
    
    var selectionType:SelectionType = .none {
        didSet{
            setNeedsLayout()//将调用layoutSubviews()
        }
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init!(frame: CGRect) {
        super.init(frame: frame)
         
        /*
         因为reuse机制，整个程序过程中只会创建一定数量的cell，
         也就是init在开始时调用，后面就不再调用。
         所以可以在init内对cell的统一特性进行初始化。
         */
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
    
    func initUI(forDate date:Date){
        /*
         在这里初始化与日期信息相关的UI
         */
        
//        print("initUI")
        //初始化cell背景色
        self.date = date
        if date.compare(Date()) == .orderedDescending{
            self.clearBGColor()
        }else{
            bgView.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
        }
    }
    
    
    override func layoutSubviews() {
//        print("FSCalendar Cell layoutSubviews")
        super.layoutSubviews()
        

        
        //1.更新cell的selected状态
        self.backgroundView?.frame = self.bounds.insetBy(dx: 2, dy: 1)
        self.selectionLayer.frame = self.contentView.bounds
        switch selectionType {
        case .single:
            self.selectionLayer.isHidden = false
            let diameter: CGFloat = min(self.contentView.frame.width, self.contentView.frame.height)
            let square = CGRect(
                x: self.contentView.frame.width / 2 - diameter / 2,
                y: self.contentView.frame.height / 2 - diameter / 2,
                width: diameter,
                height: diameter)
            let cyclePath = UIBezierPath(ovalIn: square.insetBy(dx: 5, dy: 5))
            self.selectionLayer.path = cyclePath.cgPath
        default:
            self.selectionLayer.isHidden = true
            break
        }
        
    }
    
    
    //MARK:-
    func clearBGColor(){
        bgView.backgroundColor = .clear
    }
    
    
    
    
}
