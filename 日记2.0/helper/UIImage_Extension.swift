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
            }
        }
        return img
    }
}
