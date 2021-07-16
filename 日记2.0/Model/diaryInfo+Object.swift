//
//  diaryInfo+Object.swift
//  日记2.0
//
//  Created by yy on 2021/7/16.
//

import Foundation
import UIKit
import RealmSwift

//MARK:-wrapper class
class RealmString: Object,Codable {
    @objc dynamic var stringValue:String = ""
}

class RealmTuple:Object,Codable{
    @objc dynamic var location:Int = 0 //attribute的下标
    @objc dynamic var value:Int = 0 //attribute的值
}


//MARK:-diaryInfo + Object
extension diaryInfo{
    var tags: [String] {
      get {
        return realmTags.map { $0.stringValue }
      }
      set {
        realmTags.removeAll()
        realmTags.append(objectsIn: newValue.map({ RealmString(value: [$0]) }))
      }
    }
}


extension diaryInfo{
    ///元组数组：存储所有.image属性的下标以及对应的值
    var imageAttributesTuples:[(Int,Int)]{
        get{
            return realmImageAttrTuples.map { realmTuple in
                return (realmTuple.location,realmTuple.value)
            }
        }
        set{
            realmImageAttrTuples.removeAll()
            realmImageAttrTuples.append(objectsIn: newValue.map({ tuple in
                return RealmTuple(value: [tuple.0,tuple.1])
            }))
        }
    }
    
    ///元组数组：存储所有.todo属性的下标以及对应的值
    //value=1表示checked
    //value=0表示unchecked
    var todoAttributesTuples:[(Int,Int)]{
        get{
            return realmTodoAttrTuples.map { realmTuple in
                return (realmTuple.location,realmTuple.value)
            }
        }
        set{
            realmTodoAttrTuples.removeAll()
            realmTodoAttrTuples.append(objectsIn: newValue.map({ tuple in
                return RealmTuple(value: [tuple.0,tuple.1])
            }))
        }
    }
}

