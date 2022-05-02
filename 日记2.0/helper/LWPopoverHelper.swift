//
//  LWPopoverHelper.swift
//  日记2.0
//
//  Created by 罗威 on 2022/5/1.
//

import Foundation
import Popover


class LWPopoverHelper{
    static let shared = LWPopoverHelper()
    
    func getCalendarPopover()->Popover{
        let options = [
            .type(.auto),
            .cornerRadius(10),
            .animationIn(0.3),
            .arrowSize(CGSize(width: 5, height: 5)),
            .springDamping(0.7),
          ] as [PopoverOption]
        let popover = Popover(options: options, showHandler: nil, dismissHandler: nil)
        return popover
    }
    
    func getFilterPopover()->Popover{
        let options = [
            .type(.auto),
            .cornerRadius(10),
            .animationIn(0.3),
            .arrowSize(CGSize(width: 5, height: 5)),
            .springDamping(0.7),
          ] as [PopoverOption]
        let popover = Popover(options: options, showHandler: nil, dismissHandler: nil)
        return popover
    }
}
