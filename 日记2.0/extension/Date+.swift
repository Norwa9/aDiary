//
//  Date+.swift
//  日记2.0
//
//  Created by 罗威 on 2022/1/26.
//

import Foundation
import UIKit

extension Date{
    func getYear(from date:Date)->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
    
    func toYYMMDD_CN(font:UIFont)->NSAttributedString{
        let remindYear = getYear(from: self)
        let curYear = getYear(from: Date())
        
        let formatter = DateFormatter()
        formatter.timeZone = .current
        if curYear != remindYear{ // 不是今年的待办才显示年份
            // "yyyy/M/d  mm:ss，EE"
            formatter.dateFormat = "yyyy/M/d"
        }else{
            // "M/d  mm:ss，EE"
            formatter.dateFormat = "M/d"
        }
        var ymd = formatter.string(from: self)
        formatter.dateFormat = "hh:mm"
        let ms = formatter.string(from: self)
        formatter.dateFormat = "EE"
        let ee = formatter.string(from: self)
        
        if self.isXDaysBeforeOrAfterToday(daysOffset: -1){
            ymd = "昨天"
        }else if self.isXDaysBeforeOrAfterToday(daysOffset: 0){
            ymd = "今天"
        }else if self.isXDaysBeforeOrAfterToday(daysOffset: 1){
            ymd = "明天"
        }else if self.isXDaysBeforeOrAfterToday(daysOffset: -2){
            ymd = "前天"
        }else if self.isXDaysBeforeOrAfterToday(daysOffset: 2){
            ymd = "后天"
        }
        
        let dateString =  "⏰\(ymd) \(ms) \(ee)"
        let dateAttrStringAttributes:[NSAttributedString.Key : Any] = [
            .font : font,
            .foregroundColor : UIColor.secondaryLabel
        ]
        return NSAttributedString(string: dateString,attributes: dateAttrStringAttributes)
    }
    
    
    /// self是今天的x天前/后吗?
    func isXDaysBeforeOrAfterToday(daysOffset:Int) -> Bool {
        let remindDate = self
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        
        
        
        let xTime: TimeInterval =  Double(daysOffset) * 24*60*60 // x天
        let xDate = Date().addingTimeInterval(xTime)
        let xDay = dateFormatter.string(from: xDate)
        let remindDay = dateFormatter.string(from: remindDate)
        return xDay == remindDay
    }
}
