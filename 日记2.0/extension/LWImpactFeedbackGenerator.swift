//
//  LWImpactFeedbackGenerator.swift
//  日记2.0
//
//  Created by 罗威 on 2022/5/1.
//

import Foundation
import UIKit

class LWImpactFeedbackGenerator{
    /// 产生震动
    static func impactOccurred(style:UIImpactFeedbackGenerator.FeedbackStyle = .light){
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
