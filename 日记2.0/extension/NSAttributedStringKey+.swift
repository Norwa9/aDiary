//
//  File.swift
//  日记2.0
//
//  Created by 罗威 on 2021/7/15.
//

import Foundation

let todoAttributeKey = "co.LuoWei.aDiary.image.todo"
let imageAttributeKey = "co.LuoWei.aDiary.image.image"
public extension NSAttributedString.Key {
    static var todo: NSAttributedString.Key {
        return NSAttributedString.Key(rawValue: todoAttributeKey)
    }
    
    static var image: NSAttributedString.Key {
        return NSAttributedString.Key(rawValue: imageAttributeKey)
    }
}
