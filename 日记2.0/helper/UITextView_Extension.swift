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
        let savedContentOffset = contentOffset
        let savedFrame = frame
        defer {
            contentOffset = savedContentOffset
            frame = savedFrame
        }

        contentOffset = .zero
        frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)

        let image = UIGraphicsImageRenderer(bounds: CGRect(origin: .zero, size: contentSize)).image { renderer in
            let context = renderer.cgContext
            layer.render(in: context)
        }

        return image
    }
}
