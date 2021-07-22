//
//  diaryInfo+emoji.swift
//  日记2.0
//
//  Created by yy on 2021/7/22.
//

import Foundation

extension diaryInfo{
    var emojis:[String]{
        get {
          return realmEmojis.map { $0.stringValue }
        }
        set {
            realmEmojis.removeAll()
            realmEmojis.append(objectsIn: newValue.map({ RealmString(value: [$0]) }))
        }
    }
}
