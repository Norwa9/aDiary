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
        
        //设置cell的灰色圆角矩形背景
        bgView = UIView(frame: self.bounds)
        bgView.layer.cornerRadius = 7
        self.backgroundView = bgView
        self.backgroundView?.layer.masksToBounds = true
        
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
        //有内容的，设置背景色
        let res = LWRealmManager.shared.queryFor(date: date)
        if let model = res.first{
            bgView.backgroundColor = model.content == "" ? .clear : calendarCellBackgroudDynamicColor
        }else{
            bgView.backgroundColor = .clear
        }
        
        //给今日cell加上绿色边框
        if DateToCNString(date: date) == GetTodayDate(){
            self.backgroundView?.layer.borderWidth = 1.5;
            self.backgroundView?.layer.borderColor = APP_GREEN_COLOR().cgColor
        }else{
            self.backgroundView?.layer.borderWidth = 0;
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()

        //1.更新cell的selected状态
        self.backgroundView?.frame = self.bounds.insetBy(dx: 4, dy: 2)
        self.selectionLayer.frame = self.contentView.bounds
        switch selectionType {
        case .single:
            self.selectionLayer.isHidden = true//取消选中提示
        default:
            self.selectionLayer.isHidden = true
            break
        }
        
    }
    
    
    
    
    
    
}
