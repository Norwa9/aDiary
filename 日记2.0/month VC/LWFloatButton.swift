//
//  LWFloatButton.swift
//  日记2.0
//
//  Created by 罗威 on 2022/5/1.
//

import Foundation
import UIKit

class LWFloatButton: UIButton{
    var viewModel:monthViewModel
    let monthVC = UIApplication.getMonthVC()
    
    init(viewModel:monthViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI(){
        self.backgroundColor = #colorLiteral(red: 0.007843137255, green: 0.6078431373, blue: 0.3529411765, alpha: 1)
        self.layer.cornerRadius = 20
        self.setupShadow()
        self.addTarget(self, action: #selector(floatButtonDidTapped(sender:)), for: .touchUpInside)
    }
    
    /// 进入今日or回到本月
    @objc func floatButtonDidTapped(sender:UIButton){
        LWImpactFeedbackGenerator.impactOccurred(style: .light)
        sender.showBounceAnimation {}
        let isCurrentMonth = viewModel.isCurrentMonth
        let formatter = DateFormatter()
        if isCurrentMonth{
            // 1. 进入今日
            formatter.dateFormat = "yyyy年M月d日"
            let todayDateString = GetTodayDate()
            let predicate = NSPredicate(format: "date = %@", todayDateString)
            if let selectedDiary = LWRealmManager.shared.query(predicate: predicate).first{
                monthVC?.presentEditorVC(withViewModel: selectedDiary)
            }else{
                let createOptVC = LWCreateOptionViewController(mode: .newDay)
                monthVC?.present(createOptVC, animated: true, completion: nil)
            }
        }else{
            // 2. 回到本月
            let curDate = Date()
            formatter.dateFormat = "yyyy"
            let year = Int(formatter.string(from: curDate))!
            formatter.dateFormat = "MM"
            let month = Int(formatter.string(from: curDate))!
            viewModel.selectedYear = year
            viewModel.selectedMonth = month
            monthVC?.updateUIForDateChange()
        }
    }
    
    // MARK: FloatButton
    ///返回按钮的显示与否
    public func updateUIForDateChange(){
        var title:String
        var colors:(UIColor,UIColor) // 背景、字体颜色
        let selectedYear = viewModel.selectedYear
        let curYear = viewModel.currentYear
        let selectedMonth = viewModel.selectedMonth
        let curMonth = viewModel.currentMonth
        
        if selectedMonth != curMonth || selectedYear != curYear{
            title = "返回本月"
            colors.0 = .white
            colors.1 = .black
        }else{
            title = "进入今日"
            colors.0 = UIColor.label
            colors.1 = UIColor.systemBackground
        }
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: colors.1,
            .font: appDefault.defaultFont(size: 14)
        ]
        let attributedString = NSAttributedString(string: title, attributes: titleAttributes)
        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = colors.0
            self.setAttributedTitle(attributedString, for: .normal)
        }
    }
    
}
