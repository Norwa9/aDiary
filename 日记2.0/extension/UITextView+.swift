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

//MARK:-全局函数
func GetAttachment(image:UIImage)->NSAttributedString{
    let attachment = NSTextAttachment()
    let imageAspectRatio = image.size.height / image.size.width
    let pedding:CGFloat = 15
    let textViewW = kScreenWidth - 2 * kTextViewPeddingX
    let imageWidth = (textViewW - 2 * pedding)
    let imageHeight = (imageWidth * imageAspectRatio)
    let compressedImage = image.compressPic(toSize: CGSize(width: imageWidth * 2, height: imageHeight * 2))//修改尺寸，防止从存储中读取富文本时图片方向错位
    attachment.image = compressedImage.createRoundedRectImage(size: compressedImage.size, radius: compressedImage.size.width / 25)
    attachment.bounds = CGRect(x: 0, y: 0,
                               width: imageWidth / userDefaultManager.imageScalingFactor,
                               height: imageHeight / userDefaultManager.imageScalingFactor)
    let aString = NSMutableAttributedString(attachment: attachment)
    aString.addAttribute(.image, value: 1, range: NSRange(location: 0, length: 1))
    return aString
}
