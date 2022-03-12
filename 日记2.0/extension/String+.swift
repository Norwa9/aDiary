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
        //由于date中加入了子页面下标，需要提取真实的日期信息
        let dateCN:String
        if let splitIndex = self.firstIndex(of: "-"){
            dateCN = String(self[..<splitIndex])
        }else{
            dateCN = self
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        if let rawDate = formatter.date(from: dateCN){
            formatter.dateFormat = dayComponent.rawValue
            return formatter.string(from: rawDate)
        }else{
            return "-1" // -1 表示这这个diaryinfo实例没有日期信息，不是一篇日记（模板或者其他）
        }
        
    }
    
    ///提取日期中的猴后缀信息：例如2021年9月14日-1 > 1
    ///注意：后续在引入删除页面功能后，后缀信息可能就不是一个连续的值。如果需要计算页面的序号，使用diaryInfo.indexOfPage属性
    func parseDateSuffix()->Int{
        if let splitIndex = self.firstIndex(of: "-"){
            let index2 = self.index(after: splitIndex)
            let indexString = String(self[index2..<endIndex])
            if let index =  Int(indexString){
                return index
            }
        }
        return 0
    }
    
    ///提取准确的日期：例如2021年9月14日-1 -> 2021年9月14日
    func parsePageDate()->String{
        if let splitIndex = self.firstIndex(of: "-"){
            let dateString = String(self[startIndex..<splitIndex])
            return dateString
        }else{
            return self
        }
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
                .font : userDefaultManager.monthCellTitleFont,
                .paragraphStyle:titlePara,
                .foregroundColor : UIColor.label,
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
                .font : userDefaultManager.monthCellContentFont,
                .paragraphStyle:contentPara,
                .foregroundColor : UIColor.secondaryLabel,
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
    
    /*
     1.替换图片的占位符"P"
     2.删除头部和尾部多余的空格
     */
    ///处理纯文本
    func parsePlainText()->String{
        let text = self
        var res:String
        //替换图片的占位符"P"
        res = text.replacingOccurrences(of: "P\\b", with: "[图片]",options: .regularExpression)
        //最后删除头部和尾部多余的空格
        res = res.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 处理纯文本
        var cleanText = ""
        for para in res.components(separatedBy: "\n"){
            if para != " " && para != ""{
                cleanText.append(para)
                cleanText.append("\n")
            }
        }
        
        return cleanText
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

//MARK:-常用方法扩展
extension String {
    // 获得字符串的长度，其实就是swift的count方法，只不过我习惯了Java里的length方法
    var length: Int {
        get {
            return self.count
        }
    }

    /**
     下标用法 这样用:str[1...3] str[1..< 4]
    */
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
            range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        return String(self[start...])
    }

    subscript (_ r: CountableClosedRange<Int>) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
        let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
        return String(self[startIndex...endIndex])
    }

    // 返回某个字符在字符串中出现的位置，返回-1表示没有出现
    func indexOf(_ string: String) -> Int {
        guard let index = range(of: string) else { return -1 }
        return self.distance(from: self.startIndex, to: index.lowerBound)
    }

    // 从startIndex开始查找，返回某个字符在字符串中出现的位置，返回-1表示没有出现
    func indexOf(target: String, startIndex: Int) -> Int {
        let substring = self.substring(startIndex)
        let idx = substring.indexOf(target)
        if idx == -1 {
            return -1
        }
        return idx + startIndex
    }

    // 返回某个字符在字符串中出现的位置(从末尾开始检查)，返回-1表示没有出现
    func lastIndexOf(_ string: String) -> Int {
        guard let index = range(of: string, options: .backwards) else { return -1 }
        return self.distance(from: self.startIndex, to: index.lowerBound)
    }

    // 返回从from开始的子字符串
    func substring(_ from: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: from)
        return String(self[startIndex..<self.endIndex])
    }

    // 返回从from开始，到to结束的子字符串
    func substring(from: Int, to: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[startIndex..<endIndex])
    }

    // 检查本字符串是否全是数字
    var containsOnlyDigits: Bool {
        let notDigits = NSCharacterSet.decimalDigits.inverted
        return rangeOfCharacter(from: notDigits, options: String.CompareOptions.literal, range: nil) == nil
    }
    
    // 检查本字符串是否全是字母
    var containsOnlyLetters: Bool {
        let notLetters = NSCharacterSet.letters.inverted
        return rangeOfCharacter(from: notLetters, options: String.CompareOptions.literal, range: nil) == nil
    }

    // 替换字符串中含有target的替换为withString
    func replace(target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString, options: .literal, range: nil)
    }
    
    ///替换指定下标的[一个]字符
    ///如果文章存在emoji，会让导致index计算错误从而导致奔溃
    mutating func replace(at index: Int, withCharacter character: String){
        
        return
        
        if character.count > 1{
            return
        }
        let string = self
        let replaceStart = string.index(string.startIndex, offsetBy: index)
        let replaceEnd = string.index(string.startIndex, offsetBy: index + 1)
        self.replaceSubrange(replaceStart..<replaceEnd, with: character)
    }

}
