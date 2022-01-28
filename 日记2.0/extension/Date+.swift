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
        let ymd = formatter.string(from: self)
        formatter.dateFormat = "hh:mm"
        let ms = formatter.string(from: self)
        formatter.dateFormat = "EE"
        let ee = formatter.string(from: self)
        let dateString =  "\(ymd) \(ee)  \(ms)"
        let dateAttrStringAttributes:[NSAttributedString.Key : Any] = [
            .font : font,
            .foregroundColor : UIColor.secondaryLabel
        ]
        return NSAttributedString(string: dateString,attributes: dateAttrStringAttributes)
    }
}
