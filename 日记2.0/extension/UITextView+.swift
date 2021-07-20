//
//  UITextView_Extension.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/25.
//

import Foundation
import UIKit

extension UITextView{
    //将view转换成image
    func textViewImage() -> UIImage {
        let tempTextView = UITextView(frame: self.bounds)
        print("textViewImage,bounds:\(self.bounds)")
        tempTextView.attributedText = self.attributedText
        tempTextView.layer.cornerRadius = 10
        tempTextView.showsVerticalScrollIndicator = false
        //不能在原textView上进行截图，没办法把所有内容都截下来
        //除非在截图之前将textView.removeFromSuperview()
        let snapshot = tempTextView.image()
        
        return snapshot
    }
    
    public func getTextRange() -> UITextRange? {
        if let start = position(from: self.beginningOfDocument, offset: self.selectedRange.location),
        let end = position(from: start, offset: self.selectedRange.length),
        let selectedRange = textRange(from: start, to: end) {
            return selectedRange
        }

        return nil
    }
    
}
