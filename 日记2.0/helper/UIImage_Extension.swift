//
//  UIImage_Extension.swift
//  日记2.0
//
//  Created by 罗威 on 2021/2/2.
//

import Foundation
import UIKit

extension UIImage{
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
    
    public static func emptyImage(with size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            if #available(iOS 11.0, *) {
                let border = UIColor.black
                ctx.cgContext.setStrokeColor(border.cgColor)
                ctx.cgContext.setLineWidth(1)

                let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                ctx.cgContext.addRect(rectangle)
                ctx.cgContext.drawPath(using: .stroke)
                ctx.cgContext.setFillColor(UIColor.lightGray.cgColor)
                ctx.cgContext.fill(rectangle)
            }
        }
        return img
    }
    
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
    }
    
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
        let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        path.addClip()
        self.draw(in: rect)
        //5. 获取图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        //6 关闭上下文
        UIGraphicsEndImageContext()
        
        return image!
    }

}
