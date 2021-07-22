//
//  LWCalendar.swift
//  日记2.0
//
//  Created by yy on 2021/7/22.
//

import UIKit
import FSCalendar

class LWCalendar: FSCalendar {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        //MARK:-日历
        //configure FSCalendar
        self.setDebugBorder()
        self.register(DIYCalendarCell.self, forCellReuseIdentifier: "cell")
        
        self.firstWeekday = 2
        self.locale = Locale(identifier: "zh_CN")//设置周次为中文
        self.placeholderType = .none//仅显示当月日期cell
        self.appearance.caseOptions = .weekdayUsesSingleUpperCase//设置为一、二···
        
        self.scrollEnabled = true
        self.layer.cornerRadius = 10
        self.backgroundColor = .clear
        self.appearance.todayColor = .clear
        self.appearance.titleTodayColor = .black
        self.headerHeight = 0//移除年月份栏
        self.appearance.weekdayFont = UIFont.boldSystemFont(ofSize: 17)
        self.appearance.titleFont = UIFont.appCalendarCellTitleFont()
        self.appearance.weekdayTextColor = UIColor.colorWithHex(hexColor: 0x90969B)//石岩灰
        self.appearance.eventSelectionColor = .black
        self.appearance.selectionColor = #colorLiteral(red: 0.2, green: 0.231372549, blue: 0.2509803922, alpha: 1)
        self.appearance.titleSelectionColor = APP_GREEN_COLOR()
        self.appearance.eventOffset = CGPoint(x: 0, y: -5)
        self.appearance.eventDefaultColor = .black
        self.appearance.headerDateFormat = "yyyy年M月"
        
        
        self.alpha = 0
//        self.alpha = 1
    }
    
    
}
//MARK:-DataSource
extension monthVC:FSCalendarDataSource{
    //使用DIY cell
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position) as! DIYCalendarCell
        
        cell.initUI(forDate: date)
        
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.configure(cell: cell, for: date, at: monthPosition)
    }
}

//MARK:-Delegate
extension monthVC:FSCalendarDelegate{
    //点击cell
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let cell = calendar.cell(for: date, at: monthPosition)
        //1、显示绿色圆环
        self.configureVisibleCells()
        
//        //2、如果选中未来日期，摇晃cell
//        if date.compare(Date()) == .orderedDescending{
//            cell?.shake()
//            return
//        }
        
        //2、进入日记
        formatter.dateFormat = "yyyy年M月d日"
        let dateString = formatter.string(from: date)
        let predicate = NSPredicate(format: "date = %@", dateString)
        if let selectedDiary = LWRealmManager.shared.query(predicate: predicate).first{
            guard let todayVC = storyboard?.instantiateViewController(identifier: "todayVC") as? todayVC else{
                return
            }
            todayVC.todayDiary = selectedDiary
            self.present(todayVC, animated: true, completion: nil)
        }else{
            //3,补日记
            let popoverAlert = customAlertView(frame: CGRect(origin: .zero, size: CGSize(width: 150, height: 75)))
            popoverAlert.dateString = dateString
            popover.show(popoverAlert, fromView: cell!)
        }
        
    }
    
    //取消点击cell
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        //自定义选取动画
//        print("didDeselect")
//        self.configureVisibleCells()
    }
}

// MARK: - FSCalendar自定义外观
extension monthVC:FSCalendarDelegateAppearance{
    private func configureVisibleCells() {
        //参考自FSCalendar作者的demo
        lwCalendar.visibleCells().forEach { (cell) in
            let date = lwCalendar.date(for: cell)
            let position = lwCalendar.monthPosition(for: cell)
            self.configure(cell: cell, for: date!, at: position)
        }
    }
    
    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        let cell = (cell as! DIYCalendarCell)
        
        //设置cell的选取视图：圆环
        if lwCalendar.selectedDates.contains(date){
            cell.selectionType = .single
        }else{
            cell.selectionType = .none
        }
        
    }
    
    //event dot数量
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        formatter.dateFormat = "yyyy年M月d日"
        let localDB = LWRealmManager.shared.localDatabase

        for diary in localDB{
            //如果有内容
            if diary.date == formatter.string(from: date) && diary.content.count != 0{
                return 1
            }
        }
        return 0
    }
    
    //事件点默认颜色
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        formatter.dateFormat = "yyyy年M月d日"
        let localDB = LWRealmManager.shared.localDatabase
        for diary in localDB{
            //如果有内容
            if diary.date == formatter.string(from: date) && diary.islike{
                return [.yellow]
            }
        }
        return [.black]
    }
    
    //事件点选取状态的颜色
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        return [APP_GREEN_COLOR()]
    }
}


extension monthVC:ExtendedFSCalendarDelegate{
    func didEndDecelerating(calendar: FSCalendar) {
        /*
         calendarCurrentPageDidChange存在问题：页面是willchange时调用而不是didchange时调用
         为此使用网友提供的ExtendedFSCalendarDelegate。
         通过didEndDecelerating来真正实现page didchange时调用
        */
        //获取当前页面月份
        formatter.dateFormat = "yyyy"
        let year = Int(formatter.string(from: calendar.currentPage))!
        formatter.dateFormat = "MM"
        let month = Int(formatter.string(from: calendar.currentPage))!

        selectedYear = year
        selectedMonth = month
        updateUI()
    }
}

extension LWCalendar: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        ///scrollViewDidEndDecelerating时调用delegate的didEndDecelerating方法
        ///在这里，delegate就是montgVC
        (delegate as? ExtendedFSCalendarDelegate)?.didEndDecelerating(calendar: self)
    }
}

protocol ExtendedFSCalendarDelegate: FSCalendarDelegate {
    func didEndDecelerating(calendar: FSCalendar)
}

extension ExtendedFSCalendarDelegate {
    func didEndDecelerating(calendar: FSCalendar) { }
}
