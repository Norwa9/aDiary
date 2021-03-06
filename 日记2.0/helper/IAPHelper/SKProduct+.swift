//
//  SKProduct+.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/7.
//

import Foundation
import StoreKit

//MARK:-本地化价格
extension SKProduct{
    var regularPrice:String?{
        // SKProductsRequest返回的数据是根据测试账号所在地区决定的
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)
        // https://link.medium.com/wQrhCVUIwib
    }
}
