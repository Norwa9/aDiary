//
//  UIScrollView+.swift
//  Pods
//
//  Created by 罗威 on 2021/6/16.
//

import Foundation
import UIKit

extension UIScrollView{
    /*
     自从用snapKit代替frame布局scrollview后，这个方法就对scrollview失效了。
     print("image() contentSize:\(contentSize)")打印出来的高度正确，但是宽度为0.
     唯一的解释就是snapkit带来这个问题，但是原理未知。
     */
    func image() -> UIImage {
        let savedContentOffset = contentOffset
        let savedFrame = frame
        defer {
            contentOffset = savedContentOffset
            frame = savedFrame
        }

        contentOffset = .zero
        frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
        print("image() contentSize:\(contentSize)")
        let image = UIGraphicsImageRenderer(bounds: CGRect(origin: .zero, size: contentSize)).image { renderer in
            let context = renderer.cgContext
            layer.render(in: context)
        }

        return image
    }
    
}
