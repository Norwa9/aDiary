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
}
