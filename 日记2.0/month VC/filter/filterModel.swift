//
//  filterModel.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/20.
//

import Foundation
import UIKit

class filterModel {
    static let shared = filterModel()
    
    var searchText:String = ""
    var selectedTags = [String]()
    var selectedSortstyle:sortStyle = .dateDescending
    
    func clear(){
        self.searchText = ""
        self.selectedTags.removeAll()
        self.selectedSortstyle = .dateDescending
    }
}
