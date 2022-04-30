//
//  String+.swift
//  LWWidgetExtension
//
//  Created by 罗威 on 2022/4/29.
//

import Foundation

extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}
