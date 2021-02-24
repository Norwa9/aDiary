//
//  classWrapper.swift
//  日记2.0
//
//  Created by 罗威 on 2021/2/23.
//

import Foundation
import UIKit

//MARK:-将NSAttributedString包装到AttributedString类中去
class AttributedStringWrapper : Codable {
    var attributedString : NSAttributedString

    init(nsAttributedString : NSAttributedString) {
        let mutableAttributedString = NSMutableAttributedString(attributedString: nsAttributedString)
        print("AttributedStringWrapper init,mutableAttributedString.length:\(mutableAttributedString.length)")
        mutableAttributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Noto Sans S Chinese", size: 20)!, range: NSMakeRange(0,mutableAttributedString.length))
        
        self.attributedString = mutableAttributedString
    }

    public required init(from decoder: Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        guard let attributedString = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(singleContainer.decode(Data.self)) as? NSAttributedString else {
            throw DecodingError.dataCorruptedError(in: singleContainer, debugDescription: "Data is corrupted")
        }
        self.attributedString = attributedString
    }

    public func encode(to encoder: Encoder) throws {
        var singleContainer = encoder.singleValueContainer()
        try singleContainer.encode(NSKeyedArchiver.archivedData(withRootObject: attributedString, requiringSecureCoding: false))
    }
}

