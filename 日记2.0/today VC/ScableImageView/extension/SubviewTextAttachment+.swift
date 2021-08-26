//
//  SubviewTextAttachment+.swift
//  subViewTextView_demo
//
//  Created by 罗威 on 2021/8/25.
//

import Foundation
import UIKit
import SubviewAttachingTextView

extension SubviewTextAttachment{
    ///直接获取其上的视图
    var view:UIView{
        get{
            return self.viewProvider.instantiateView(for: self, in: SubviewAttachingTextViewBehavior.init())
        }
    }
}
