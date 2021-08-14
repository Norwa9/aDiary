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

//MARK:-切换黑暗模式，旋转屏幕时的辅助函数
extension UITextView{
    ///重新设置图片附件的大小（旋转屏幕时使用）
    func resizeImagesAttchement(){
        let aString = self.attributedText ?? NSAttributedString(string: "")
        let attrText = NSMutableAttributedString(attributedString: aString)
        let bounds = self.bounds
        attrText.enumerateAttribute(.image, in: NSRange(location: 0, length: attrText.length), options: [], using: { [] (object, range, pointer) in
            let location = range.location
            
            if let attchment = object as? NSTextAttachment,let image = attchment.image(forBounds: bounds, textContainer: nil, characterIndex: location){
                
                let aspect = image.size.width / image.size.height
                let pedding:CGFloat = 15
                let newWidth = (bounds.width - 2 * pedding) / userDefaultManager.imageScalingFactor
                let newHeight = (newWidth / aspect)
                let para = NSMutableParagraphStyle()
                para.alignment = .center
                attrText.addAttribute(.paragraphStyle, value: para, range: NSRange(location: location, length: 1))
                attchment.bounds = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
            }
            
        })
        
        self.attributedText = attrText
    }
    
    ///重新读取todo的图片素材（切换暗黑模式时使用）
    func reloadTodoImage(){
        let aString = self.attributedText ?? NSAttributedString(string: "")
        let attrText = NSMutableAttributedString(attributedString: aString)
        attrText.enumerateAttribute(.todo, in: NSRange(location: 0, length: attrText.length), options: [], using: { [] (object, range, pointer) in
            let location = range.location
            if let value = attrText.attribute(.todo, at: location, effectiveRange: nil) as? Int{
                let attributedText = (value == 1) ? AttributedBox.getChecked() : AttributedBox.getUnChecked()

                attrText.replaceCharacters(in: NSRange(location: location, length: 1), with: (attributedText?.attributedSubstring(from: NSRange(0..<1)))!)
            }
        })
        
        self.attributedText = attrText
    }
}

//MARK:-全局函数
func GetAttachment(image:UIImage)->NSAttributedString{
    let attachment = NSTextAttachment()
    let imageAspectRatio = image.size.height / image.size.width
    let pedding:CGFloat = 15
    let textViewW = globalConstantsManager.shared.kScreenWidth - 2 * kTextViewPeddingX
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
