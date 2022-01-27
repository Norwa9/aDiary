//
//  Date+.swift
//  日记2.0
//
//  Created by 罗威 on 2022/1/26.
//

import Foundation
import UIKit

extension Date{
    func toYYMMDD_CN()->NSAttributedString{
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy/M/d"
        let ymd = formatter.string(from: self)
        formatter.dateFormat = "hh:mm"
        let ms = formatter.string(from: self)
        formatter.dateFormat = "EE"
        let ee = formatter.string(from: self)
        
        // "yyyy/M/d  mm:ss，EE"
        let dateString =  "\(ymd)  \(ms)，\(ee)"
        let dateAttrStringAttributes:[NSAttributedString.Key : Any] = [
            .font : userDefaultManager.customFont(withSize: userDefaultManager.fontSize * 0.6),
            .foregroundColor : UIColor.secondaryLabel
        ]
        return NSAttributedString(string: dateString,attributes: dateAttrStringAttributes)
    }
}
