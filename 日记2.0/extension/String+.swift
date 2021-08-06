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


//MARK:-解析标题和内容添加属性
extension String{
     func getAttrTitle()->NSAttributedString{
        let content = self
        let mContent = NSMutableAttributedString(string: content)
        if mContent.length > 0{
            //获取第一段
            let paragraphArray = content.components(separatedBy: "\n")
            let firstPara = paragraphArray.first!
            //标题的字体大小16行间距6。
            //标题格式
            let titlePara = NSMutableParagraphStyle()
            titlePara.lineSpacing = 3
            let titleAttributes:[NSAttributedString.Key : Any] = [
                .font : UIFont(name: "DIN Alternate", size: 17)!,
                .paragraphStyle:titlePara,
                .foregroundColor : UIColor.label
            ]
            
            let titleRange = NSMakeRange(0, firstPara.utf16.count)
            mContent.addAttributes(titleAttributes, range: titleRange)
            return mContent.attributedSubstring(from: titleRange)
        }else{
            return mContent
        }
    }
    
     func getAttrContent() -> NSAttributedString{
        let content = self
        let mString = NSMutableAttributedString(string: content)
        if mString.length > 0{
            //内容段样式
            let contentPara = NSMutableParagraphStyle()
            contentPara.lineSpacing = 3
            let contentAttributes:[NSAttributedString.Key : Any] = [
                .font : UIFont(name: "DIN Alternate", size: 14)!,
                .paragraphStyle:contentPara,
                .foregroundColor : UIColor.colorWithHex(hexColor: 0x5D5E61)//石岩灰
            ]
            mString.addAttributes(contentAttributes, range: NSRange(location: 0, length: mString.length))
            //获取第一段Range
            let paragraphArray = content.components(separatedBy: "\n")
            let firstPara = paragraphArray.first!
            //如果日记只有一行，那么这一行的末尾是不带有"\n"的！！
            let titleLength = paragraphArray.count > 1 ? firstPara.utf16.count + 1 : firstPara.utf16.count
            let titleRange = NSMakeRange(0, titleLength)
            mString.replaceCharacters(in: titleRange, with: "")
            return mString
        }
        return mString
    }
}

//MARK:-String + UILabel
extension String{
    func changeWorldSpace(space:CGFloat) -> NSAttributedString{
        //紧凑间隔
        let attributedString = NSMutableAttributedString.init(string: self, attributes: [.kern:space])
        let paragraphStyle = NSMutableParagraphStyle()
        //居中排版
        paragraphStyle.alignment = .center
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: .init(location: 0, length: attributedString.length))
        
        return attributedString
    }
}
