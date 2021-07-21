//
//  NSMutableAttributedString+.swift
//  日记2.0
//
//  Created by 罗威 on 2021/7/15.
//

import Foundation
import UIKit

extension NSMutableAttributedString{
    ///把.todo的文本属性改为String：例如value=1->"- [ ]"
    public func unLoadCheckboxes() -> NSMutableAttributedString {
        var offset = 0
        //content可能是多段文字
        let content = self.mutableCopy() as? NSMutableAttributedString

        self.enumerateAttribute(.attachment, in: NSRange(location: 0, length: self.length)) { (value, range, _) in
            if value != nil {
                let newRange = NSRange(location: range.location + offset, length: 1)

                guard range.length == 1,
                    let value = self.attribute(.todo, at: range.location, effectiveRange: nil) as? Int
                else { return }
    
                ///注：checkboxText.addAttribute(.todo, value: 0, range: NSRange(0..<1))
                print("发现todo attchment,range:\(range)")
                var gfm = "- [ ]"
                if value == 1 {
                    gfm = "- [x]"
                }
                content?.replaceCharacters(in: newRange, with: gfm)
                offset += 4
            }
        }
        return content!
    }

}

extension NSMutableAttributedString{
    public func loadCheckboxes() {
        while mutableString.contains("- [ ] ") {
            let range = mutableString.range(of: "- [ ] ")
            if length >= range.upperBound, let unChecked = AttributedBox.getUnChecked() {
                replaceCharacters(in: range, with: unChecked)
            }
        }
        
        while mutableString.contains("- [x] ") {
            let range = mutableString.range(of: "- [x] ")
            let parRange = mutableString.paragraphRange(for: range)
            
            if length >= range.upperBound, let checked = AttributedBox.getChecked() {
                
                //let color = NightNight.theme == .night ? UIColor.white : UIColor.black
                let color = UIColor.black
                addAttribute(.strikethroughColor, value: color, range: parRange)
                
                replaceCharacters(in: range, with: checked)
            }
        }
    }
}

//MARK:-NSMutableAttributedString + todo
extension NSMutableAttributedString{
    @discardableResult func addCheckAttribute(range:NSRange) ->Self{
        self.addAttribute(.strikethroughStyle, value: 1, range: range)
        self.addAttribute(.foregroundColor, value: UIColor.lightGray, range: range)
        return self
    }
    
    @discardableResult func addUncheckAttribute(range:NSRange)->Self{
        self.removeAttribute(.strikethroughStyle, range: range)
        self.addAttribute(.foregroundColor, value: UIColor.black, range: range)
        return self
    }
}
