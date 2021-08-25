//
//  CGRect+.swift
//  subViewTextView_demo
//
//  Created by yy on 2021/8/25.
//

import Foundation
import UIKit

extension CGRect {
    
    init?(string: String?) {
        guard let string = string else {
            return nil
        }
        
        let components: [CGFloat] = string.components(separatedBy: ",").compactMap {
            guard let value = Float($0) else { return nil }
            return CGFloat(value)
        }
        
        guard components.count == 4 else {
            return nil
        }
        
        self =  CGRect(x: components[0],
                      y: components[1],
                      width: components[2],
                      height: components[3])
    }
    
}
