//
//  UIFont_Extension.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/12.
//

import Foundation
import UIKit

class appDefault {
    static func defaultFont(size:CGFloat) -> UIFont{
        return UIFont(name: "DIN Alternate", size: size)!
    }
}

//MARK:-粗体、斜体
extension UIFont {
    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    
    var isItalic: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
    
    func bold() -> UIFont? {
        if (isItalic) {
            if let descriptor = fontDescriptor.withSymbolicTraits([.traitBold,.traitItalic]){
                return UIFont(descriptor: descriptor, size: self.pointSize)
            }
        } else {
            if let descriptor = fontDescriptor.withSymbolicTraits([.traitBold]){
                return UIFont(descriptor: descriptor, size: self.pointSize)
            }
        }
    
        return nil
    }
    
    func unBold() -> UIFont? {
        if (isItalic) {
            if let descriptor = fontDescriptor.withSymbolicTraits([.traitItalic]){
                return UIFont(descriptor: descriptor, size: self.pointSize)
            }
        } else {
            if let descriptor = fontDescriptor.withSymbolicTraits([]){
                return UIFont(descriptor: descriptor, size: self.pointSize)
            }
        }
    
        return nil
    }
    
    func italic() -> UIFont? {
        if (isBold) {
            print("italic() isBold")
            if let descriptor = fontDescriptor.withSymbolicTraits([.traitBold,.traitItalic]){
                return UIFont(descriptor: descriptor, size: 0)
            }
        } else {
            print("italic() !isBold")
            if let descriptor = fontDescriptor.withSymbolicTraits([.traitItalic]){
                return UIFont(descriptor: descriptor, size: 0)
            }
        }
    
        return nil
        
    }
    
    func unItalic() -> UIFont? {
        if (isBold) {
            if let descriptor = fontDescriptor.withSymbolicTraits([.traitBold]){
                return UIFont(descriptor: descriptor, size: 0)
            }
        } else {
            if let descriptor = fontDescriptor.withSymbolicTraits([]){
                return UIFont(descriptor: descriptor, size: 0)
            }
        }
    
        return nil
    }
    
    func copyFontTraitsToNewSelectedFont() -> UIFont{
        var fontTraits:[UIFontDescriptor.SymbolicTraits.Element] = []
        if self.isBold{
            fontTraits.append(.traitBold)
        }
        if self.isItalic{
            fontTraits.append(.traitItalic)
        }
        
        //复制字体的特性（加粗、斜体）
        var resDescriptor:UIFontDescriptor = userDefaultManager.font.fontDescriptor
        var resFont = userDefaultManager.font
        for trait in fontTraits{
            if resFont.supportTrait(trait: trait){
                resDescriptor = resDescriptor.withSymbolicTraits([trait])!
                resFont = UIFont(descriptor: resDescriptor, size: userDefaultManager.fontSize)
            }
        }
        //复制字体大小
        resFont = resFont.withSize(self.pointSize)
        
        return resFont
    }
    
    func supportTrait(trait:UIFontDescriptor.SymbolicTraits.Element)->Bool{
        if let _ = self.fontDescriptor.withSymbolicTraits([trait]){
            return true
        }else{
           return false
        }
    }
    
    func supportItalicTrait()->Bool{
        if let _ = self.fontDescriptor.withSymbolicTraits([.traitItalic]){
            return true
        }else{
           return false
        }
    }
}
