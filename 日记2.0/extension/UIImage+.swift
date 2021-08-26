//
//  UIImage_Extension.swift
//  日记2.0
//
//  Created by 罗威 on 2021/2/2.
//

import Foundation
import UIKit

extension UIImage{
    //MARK:-压缩image到特定尺寸
    func compressPic(toSize:CGSize) -> UIImage{
        let toW = toSize.width
        let toH = toSize.height
        let renderRect = CGRect(origin: .zero, size: CGSize(width: toW, height: toH))
        let renderer = UIGraphicsImageRenderer(size: renderRect.size)
        
        let img = renderer.image { ctx in
            self.draw(in: renderRect)
        }
        return img
    }
    
    //MARK:-生成空的图片
    public static func emptyImage(with size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            if #available(iOS 11.0, *) {
                ctx.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
                ctx.cgContext.setLineWidth(1)

                let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                let roundRectPath = UIBezierPath(roundedRect: rectangle, cornerRadius: size.width / 25)
                ctx.cgContext.addPath(roundRectPath.cgPath)
                ctx.cgContext.setFillColor(APP_GRAY_COLOR().cgColor)
//                ctx.cgContext.setFillColor(UIColor.white.cgColor)
                ctx.cgContext.drawPath(using: .fillStroke)
            }
        }
        return img
    }
    
    //MARK:-image切圆角
    func createRoundedRectImage(size: CGSize,radius:CGFloat,callBack: @escaping (_ image: UIImage) ->()) {
    //在子线程中执行
            DispatchQueue.global().async {
                let rect = CGRect(origin: CGPoint.zero, size: size)
                //1. 开启上下文
                UIGraphicsBeginImageContext(size)
                //2. 设置颜色
//                backgroundColor.setFill()
                //3. 颜色填充
//                UIRectFill(rect)
                //4. 图像绘制
                //切回角
                let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
                path.addClip()
                self.draw(in: rect)
                //5. 获取图片
                let image = UIGraphicsGetImageFromCurrentImageContext()
                //6 关闭上下文
                UIGraphicsEndImageContext()
                //回到主线程刷新UI
                DispatchQueue.main.async(execute: {
                    callBack(image!)
                })
            }
        /*
         用法：
         let compressedImage = UIImage(data: image.jpegData(compressionQuality: 0.6)!)!
         compressedImage.createRoundedRectImage(size: compressedImage.size,radius: image.size.width / 25) { (RRimg) in
             //RRimg即在后台线程渲染完成后返回的UIImage对象
             attachment.image = RRimg
         }
         */
        
    }
    
    //MARK:-image切圆角
    func createRoundedRectImage(size: CGSize,radius:CGFloat)->UIImage {
        let rect = CGRect(origin: CGPoint.zero, size: size)
        //1. 开启上下文
        UIGraphicsBeginImageContext(size)
        //2. 设置颜色
//                backgroundColor.setFill()
        //3. 颜色填充
//                UIRectFill(rect)
        //4. 图像绘制
        //切回角
        UIColor.lightGray.setStroke()
        let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        path.addClip()
        self.draw(in: rect)
        //5. 获取图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        //6 关闭上下文
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    
    func compress(qualty:CGFloat) -> UIImage?{
        guard qualty > 0,qualty < 1 else{
            return nil
        }
        if let compressedData = self.jpegData(compressionQuality: qualty){
            return UIImage(data: compressedData)
        }
        return nil
        
    }

}
