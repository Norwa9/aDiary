//
//  String+.swift
//  日记2.0
//
//  Created by 罗威 on 2021/6/14.
//

import Foundation
import UIKit
extension String{
    func image(size:CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.white.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 30)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
    enum dayComponents:String {
        case year = "yyyy"
        case month = "M"
        case day = "d"
        case weekday = "EEE"
    }
    ///返回年、月、日(String)
    func dateComponent(for dayComponent:dayComponents)->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        let rawDate = formatter.date(from: self)!
        formatter.dateFormat = dayComponent.rawValue
        return formatter.string(from: rawDate)
    }
}

extension String{
    var isContainsLetters: Bool {
        let letters = CharacterSet.letters
        return self.rangeOfCharacter(from: letters) != nil
    }
}
