//
//  Results+.swift
//  日记2.0
//
//  Created by 罗威 on 2021/7/9.
//

import Foundation
import RealmSwift

extension Results {
    ///将Results转为系统数组
    func toArray() -> [Element] {
      return compactMap {
        $0
      }
    }
 }
